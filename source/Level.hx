package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
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
  private var shifters: FlxTypedGroup<Shifter> = new FlxTypedGroup<Shifter>();
  private var overlay: FlxSprite;

  public function new(number: Int) {
    super();

    var filename = "assets/levels/level" + number + ".tmx";
    var map = new TiledMap(filename);
    createTiles(cast map.getLayer("base"));
    createWires(cast map.getLayer("wires"));
    add(doors);
    add(exits);
    add(crates);
    createObjects(this.map);
    add(keys);
    add(shifters);
    addOverlay();
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
      case 12:
        var exit = new Exit(mapX, mapY);
        exits.add(exit);
      case 13:
        var key = new Key(mapX, mapY);
        keys.add(key);
      case 14|15|16|17:
        var shifter = new Shifter(mapX, mapY, type - 14);
        shifters.add(shifter);
      default:
        return false;
    }
    return true;
  }

  override public function update(elapsed: Float): Void {
    super.update(elapsed);

    if (finished) {
      return;
    }

    var dx = 0;
    var dy = 0;
    if (FlxG.keys.anyPressed([LEFT, A, O])) {
      dx--;
    }
    if (FlxG.keys.anyPressed([RIGHT, D, U])) {
      dx++;
    }
    if (FlxG.keys.anyPressed([UP, W, PERIOD])) {
      dy--;
    }
    if (FlxG.keys.anyPressed([DOWN, S, E])) {
      dy++;
    }
    if (dx != 0 && dy == 0 || dx == 0 && dy != 0) {
      move(dx, dy);
    }
  }

  private function move(dx: Int, dy: Int): Void {
    if (player.walking) {
      return;
    }
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

    player.moveTo(newX, newY);

    if (player.shape == Shape.HUMAN) {
      for (key in keys) {
        if (key.mapX == newX && key.mapY == newY) {
          player.pickUp(key);
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
      if (shifter.isAt(newX, newY)) {
        player.shiftShape(shifter.shape);
        if (player.shape != Shape.HUMAN) {
          for (obj in player.carried) {
            obj.setMapPosition(oldX, oldY);
            player.carried.remove(obj);
          }
        }
      }
    }

    updateWires();

    for (exit in exits) {
      if (newX == exit.mapX && newY == exit.mapY) {
        finished = true;
      }
    }
  }

  private function tryMove(mapX: Int, mapY: Int, dx: Int, dy: Int) {
    openAnyDoors(mapX, mapY);
    if (player.shape == Shape.BEAR) {
      pushAnyCrates(mapX, mapY, dx, dy);
    }
    return isFree(mapX, mapY, player.shape == Shape.SNAKE);
  }

  private function openAnyDoors(mapX: Int, mapY: Int) {
    var key = player.getCarriedKey();
    if (key == null) {
      return;
    }
    for (door in doors) {
      if (door.mapX == mapX && door.mapY == mapY && !door.open) {
        player.carried.remove(key);
        keys.remove(key);
        door.setOpen(true);
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

  private function isFree(mapX: Int, mapY: Int, ignoreDoors: Bool = false) {
    var tile = map.getTile(mapX, mapY);
    if (tile != 1) {
      return false;
    }
    if (!ignoreDoors) {
      for (door in doors) {
        if (door.isAt(mapX, mapY) && !door.open) {
          return false;
        }
      }
    }
    for (crate in crates) {
      if (crate.isAt(mapX, mapY)) {
        return false;
      }
    }
    return true;
  }
}

class Coords {
  public var x: Int;
  public var y: Int;
  public function new(x: Int, y: Int) { this.x = x; this.y = y; }
}
