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

  public var number: Int;
  public var finished: Bool;

  private var map: FlxTilemap;
  private var player: Player;
  private var keys: Array<Key> = [];
  private var doors: Array<Door> = [];
  private var exit: MapObject;

  public function new(number: Int) {
    super();

    this.number = number;

    var filename = "assets/levels/level" + number + ".tmx";
    var map = new TiledMap(filename);

    createTiles(cast map.getLayer("base"));
    createObjects(cast map.getLayer("objects"));

    // FlxG.camera.focusOn(new FlxPoint(map.fullWidth / 2, map.fullHeight / 2));
  }

  public function fadeIn(onComplete: Void -> Void = null) {
    var overlay = makeOverlay();
    FlxTween.tween(overlay, {alpha: 0.0}, 1.0, {onComplete: function(tween: FlxTween) {
      remove(overlay);
      if (onComplete != null) {
        onComplete();
      }
    }});
  }

  public function fadeOut(onComplete: Void -> Void = null) {
    var overlay = makeOverlay();
    overlay.alpha = 0;
    FlxTween.tween(overlay, {alpha: 1.0}, 1.0, {onComplete: function(tween: FlxTween) {
      remove(overlay);
      if (onComplete != null) {
        onComplete();
      }
    }});
  }

  private function makeOverlay(): FlxSprite {
    var overlay = new FlxSprite();
    overlay.makeGraphic(256, 256, FlxColor.BLACK);
    // add(overlay);
    members.push(overlay);
    length++;
    return overlay;
  }

  private function createTiles(layer: TiledTileLayer) {
    var tilemap: FlxTilemap = new FlxTilemap();
    tilemap.loadMapFromArray(layer.tileArray, layer.width, layer.height,
        "assets/images/tileset.png", TILE_SIZE, TILE_SIZE, OFF, 1);
    map = tilemap;
    add(tilemap);
  }

  private function createObjects(layer: TiledTileLayer) {
    for (y in 0...layer.height) {
      for (x in 0...layer.width) {
        var tile = layer.tileArray[y * layer.height + x];
        createObject(tile, x, y);
      }
    }
  }

  private function createObject(type: Int, mapX: Int, mapY: Int) {
    switch (type) {
      case 0:
        return;
      case 3:
      case 5:
        var door = new Door(mapX, mapY, type == 5);
        add(door);
        doors.push(door);
      case 11:
        player = new Player(mapX, mapY);
        add(player);
      case 12:
        exit = new MapObject(mapX, mapY, 11, 1);
        add(exit);
      case 13:
        var key = new Key(mapX, mapY);
        add(key);
        keys.push(key);
      default:
        trace("Don't know what to do with tile ID " + type);
    }
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
    if (player.tweening) {
      return;
    }
    var newX = player.mapX + dx;
    var newY = player.mapY + dy;
    if (newX < 0 || newX >= map.width || newY < 0 || newY >= map.height) {
      return;
    }
    if (!isPassable(newX, newY)) {
      return;
    }
    player.moveTo(newX, newY);

    for (key in keys) {
      if (key.mapX == newX && key.mapY == newY) {
        keys.remove(key);
        player.pickUp(key);
      }
    }

    if (newX == exit.mapX && newY == exit.mapY) {
      finished = true;
    }
  }

  private function isPassable(mapX: Int, mapY: Int) {
    var tile = map.getTile(mapX, mapY);
    if (tile != 1) {
      return false;
    }
    for (door in doors) {
      if (door.mapX == mapX && door.mapY == mapY && !door.open) {
        var key = player.getCarriedKey();
        if (key == null) {
          return false;
        }
        player.carried.remove(key);
        remove(key);
        door.setOpen(true);
      }
    }
    return true;
  }
}
