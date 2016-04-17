package;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import haxe.io.Path;

class Level extends FlxGroup {

  public inline static var TILE_SIZE = 16;
  public static var TILE_SIZE_POINT = new FlxPoint(TILE_SIZE, TILE_SIZE);

  public var finished: Bool;

  private var map: FlxTilemap;
  private var wires: FlxTilemap;
  private var player: Player;
  private var keys: FlxTypedGroup<Key> = new FlxTypedGroup<Key>();
  private var doors: FlxTypedGroup<Door> = new FlxTypedGroup<Door>();
  private var crates: FlxTypedGroup<Crate> = new FlxTypedGroup<Crate>();
  private var exits: FlxTypedGroup<Exit> = new FlxTypedGroup<Exit>();
  private var shadows: FlxGroup = new FlxGroup();
  private var shifters: FlxTypedGroup<Shifter> = new FlxTypedGroup<Shifter>();
  private var hints: FlxGroup = new FlxGroup();
  private var overlay: FlxSprite;

  private var takeKeySound: FlxSound;
  private var dropKeySound: FlxSound;
  private var hintSound: FlxSound;

  public function new(basename: String) {
    super();

    loadSounds();

    var filename = "assets/levels/" + basename + ".tmx";
    var map = new TiledMap(filename);
    createTiles(cast map.getLayer("base"));
    createWires(cast map.getLayer("wires"));
    add(shadows);
    add(exits);
    add(crates);
    createObjects(this.map);
    add(doors);
    add(keys);
    add(shifters);
    add(hints);
    addOverlay();

    updateWires();
  }

  private function loadSounds() {
    takeKeySound = FlxG.sound.load("assets/sounds/take_key.ogg");
    dropKeySound = FlxG.sound.load("assets/sounds/drop_key.ogg");
    hintSound = FlxG.sound.load("assets/sounds/hint.ogg");
  }

  public function fadeIn(onComplete: Void -> Void = null) {
    FlxTween.tween(overlay, {alpha: 0.0}, 0.5, {onComplete: function(tween: FlxTween) {
      if (onComplete != null) {
        onComplete();
      }
    }});
  }

  public function fadeOut(onComplete: Void -> Void = null) {
    overlay.alpha = 0;
    FlxTween.tween(overlay, {alpha: 1.0}, 0.5, {onComplete: function(tween: FlxTween) {
      if (onComplete != null) {
        onComplete();
      }
    }});
  }

  private function addOverlay() {
    overlay = new FlxSprite();
    overlay.makeGraphic(256, 256, FlxColor.BLACK);
    add(overlay);
  }

  private function createTiles(layer: TiledTileLayer) {
    var tilemap: FlxTilemap = new FlxTilemap();
    tilemap.loadMapFromArray(layer.tileArray, layer.width, layer.height,
        "assets/images/tileset.png", TILE_SIZE, TILE_SIZE, OFF, 1);
    map = tilemap;
    add(tilemap);
  }

  private function createWires(layer: TiledTileLayer) {
    var tilemap: FlxTilemap = new FlxTilemap();
    if (layer != null) {
      tilemap.loadMapFromArray(layer.tileArray, layer.width, layer.height,
          "assets/images/tileset.png", TILE_SIZE, TILE_SIZE, OFF, 1);
    }
    wires = tilemap;
    add(tilemap);
  }

  private function createObjects(map: FlxTilemap) {
    for (y in 0...map.heightInTiles) {
      for (x in 0...map.widthInTiles) {
        var tile = map.getTile(x, y);
        if (createObject(tile, x, y)) {
          map.setTile(x, y, 1, false);
        }
      }
    }
    map.setDirty(true);
  }

  private function createObject(type: Int, mapX: Int, mapY: Int): Bool {
    switch (type) {
      case 3|5:
        var door = new Door(mapX, mapY, type == 5);
        doors.add(door);
      case 9:
        var crate = new Crate(mapX, mapY);
        crates.add(crate);
      case 11:
        player = new Player(mapX, mapY);
        add(player);
        return false; // Keep tile.
      case 12:
        var exit = new Exit(mapX, mapY);
        exits.add(exit);
      case 13:
        var key = new Key(mapX, mapY);
        keys.add(key);
      case 14|15|16|17:
        var shadow = new MapObject(mapX, mapY, MapObject.tilesetFrames(type + 3, 1));
        shadows.add(shadow);
        var shifter = new Shifter(mapX, mapY, type - 14);
        shifters.add(shifter);
      default:
        return false;
    }
    return true;
  }

  private function move(dx: Int, dy: Int): Void {
    var oldX = player.mapX;
    var oldY = player.mapY;
    var newX = player.mapX + dx;
    var newY = player.mapY + dy;
    if (newX < 0 || newX >= map.width || newY < 0 || newY >= map.height) {
      return;
    }
    if (!tryMove(newX, newY, dx, dy)) {
      return;
    }

    for (exit in exits) {
      if (newX == exit.mapX && newY == exit.mapY) {
        finished = true;
        player.slow = true;
      }
    }

    player.moveTo(newX, newY);

    for (key in keys) {
      if (key.mapX == newX && key.mapY == newY) {
        if (player.shape == Shape.HUMAN) {
          player.pickUp(key);
          takeKeySound.play();
        } else if (player.shape == Shape.BEAR) {
          showHint("Your paws are too big to hold this key");
        } else if (player.shape == Shape.SNAKE) {
          showHint("You have no hands to hold this key");
        }
      }
    }

    if (player.shape == Shape.BEAR) {
      for (crate in crates) {
        if (crate.mapX == newX && crate.mapY == newY) {
          crate.moveTo(newX + dx, newY + dy);
        }
      }
    }

    for (shifter in shifters) {
      if (shifter.isAt(newX, newY) && player.shape != shifter.shape) {
        player.shiftShape(shifter.shape);
        shifter.hide();
        addSmoke(newX, newY);
        if (player.shape != Shape.HUMAN) {
          var droppedAnything = false;
          for (obj in player.carried) {
            obj.setMapPosition(oldX, oldY);
            droppedAnything = true;
          }
          player.carried = [];
          if (droppedAnything) {
            dropKeySound.play();
          }
        }
      } else {
        shifter.show();
      }
    }

    updateWires();
  }

  private function tryMove(mapX: Int, mapY: Int, dx: Int, dy: Int) {
    openAnyDoors(mapX, mapY);
    if (player.shape == Shape.BEAR) {
      pushAnyCrates(mapX, mapY, dx, dy);
    }
    return isFree(mapX, mapY, true);
  }

  private function openAnyDoors(mapX: Int, mapY: Int) {
    var key = player.getCarriedKey();
    if (key == null) {
      return;
    }
    for (door in doors) {
      if (door.mapX == mapX && door.mapY == mapY && !door.open) {
        if (!isWire(mapX, mapY)) {
          player.carried.remove(key);
          keys.remove(key);
          door.setOpen(true);
        }
      }
    }
  }

  private function pushAnyCrates(mapX: Int, mapY: Int, dx: Int, dy: Int) {
    for (crate in crates) {
      if (crate.isAt(mapX, mapY)) {
        var newX = mapX + dx;
        var newY = mapY + dy;
        if (isFree(newX, newY)) {
          crate.moveTo(newX, newY);
          updateWires();
        }
      }
    }
  }

  private function addSmoke(mapX: Int, mapY: Int) {
    for (i in 0...3) {
      var smoke = new MapObject(mapX, mapY, MapObject.tilesetFrames(7, 1));
      smoke.flipX = Math.random() > 0.5;
      smoke.flipY = Math.random() > 0.5;
      smoke.alpha = 0.5;
      var dx = 4 * (Math.random() - 0.5);
      var dy = 2 * Math.random();
      smoke.x += dx;
      smoke.y += dy;
      FlxTween.tween(smoke, {x: smoke.x + dx, y: smoke.y + dy, alpha: 0}, 2.0, {
        onComplete: function(tween: FlxTween) { remove(smoke); },
        ease: FlxEase.quadOut
      });
      add(smoke);
    }
  }

  private function updateWires() {
    for (y in 0...wires.heightInTiles) {
      for (x in 0...wires.widthInTiles) {
        setWireActive(x, y, false);
      }
    }

    var queue: Array<Coords> = [];
    for (crate in crates) {
      if (isPlate(crate.mapX, crate.mapY)) {
        queue.push(new Coords(crate.mapX, crate.mapY));
      }
    }
    if ((player.shape == Shape.HUMAN || player.shape == Shape.BEAR) && isPlate(player.mapX, player.mapY)) {
      queue.push(new Coords(player.mapX, player.mapY));
    }

    while (queue.length > 0) {
      var coords = queue.pop();
      if (!isWire(coords.x, coords.y)) {
        continue;
      }
      if (isWireActive(coords.x, coords.y)) {
        continue;
      }
      setWireActive(coords.x, coords.y, true);
      if (coords.x > 0) {
        queue.push(new Coords(coords.x - 1, coords.y));
      }
      if (coords.x < wires.widthInTiles - 1) {
        queue.push(new Coords(coords.x + 1, coords.y));
      }
      if (coords.y > 0) {
        queue.push(new Coords(coords.x, coords.y - 1));
      }
      if (coords.y < wires.heightInTiles - 1) {
        queue.push(new Coords(coords.x, coords.y + 1));
      }
    }

    wires.setDirty(true);

    for (door in doors) {
      if (isWire(door.mapX, door.mapY)) {
        door.setOpen(isWireActive(door.mapX, door.mapY));
      } 
    }
  }

  private function isPlate(mapX: Int, mapY: Int) {
    var tile = wires.getTile(mapX, mapY);
    return tile == 21 || tile == 31;
  }

  private function isWire(mapX: Int, mapY: Int) {
    var tile = wires.getTile(mapX, mapY);
    return tile >= 21 && tile < 41;
  }

  private function isWireActive(mapX: Int, mapY: Int) {
    var tile = wires.getTile(mapX, mapY);
    return tile >= 31 && tile < 41;
  }
  
  private function setWireActive(mapX: Int, mapY: Int, active: Bool) {
    var tile = wires.getTile(mapX, mapY);
    if (tile >= 21 && tile < 31 && active) {
      wires.setTile(mapX, mapY, tile + 10, false);
    } else if (tile >= 31 && tile < 41 && !active) {
      wires.setTile(mapX, mapY, tile - 10, false);
    }
  }

  private function isFree(mapX: Int, mapY: Int, forPlayer: Bool = false) {
    var tile = map.getTile(mapX, mapY);
    if (tile != 1) {
      return false;
    }
    for (door in doors) {
      if (door.isAt(mapX, mapY) && !door.open) {
        if (forPlayer) {
          if (player.shape != Shape.SNAKE) {
            if (player.getCarriedKey() != null && isWire(mapX, mapY)) {
              showHint("This door is controlled by a pressure plate");
            } else {
              showHint("You are too big to fit under the door");
            }
            return false;
          }
        } else {
          return false;
        }
      }
    }
    for (crate in crates) {
      if (crate.isAt(mapX, mapY)) {
        if (forPlayer) {
          if (player.shape != Shape.BEAR) {
            showHint("You are not strong enough to move this crate");
          }
        }
        return false;
      }
    }
    return true;
  }

  private function showHint(hint: String) {
    hints.clear();

    var margin = 8;
    var text = new FlxText(margin, 256 - margin - 8, 256 - 2 * margin, hint);
    text.alignment = CENTER;
    text.borderStyle = SHADOW;
    hints.add(text);
    haxe.Timer.delay(function() {
      FlxTween.tween(text, {alpha: 0.0}, 1.0, {onComplete: function(tween: FlxTween) { hints.remove(text); }});
    }, 2000);

    hintSound.play();
  }
}

class Coords {
  public var x: Int;
  public var y: Int;
  public function new(x: Int, y: Int) { this.x = x; this.y = y; }
}
