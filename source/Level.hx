package;

import flixel.FlxG;
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
        if (tile != null) {
          createObject(tile, x, y);
        }
      }
    }
  }

  private function createObject(type: Int, mapX: Int, mapY: Int) {
    switch (type) {
      case 0:
        return;
      case 11:
        player = new Player(mapX, mapY);
        add(player);
      case 12:
        exit = new MapObject(mapX, mapY);
        exit.setFrameIndices(11, 1);
        add(exit);
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

    if (newX == exit.mapX && newY == exit.mapY) {
      finished = true;
    }
  }

  private function isPassable(mapX: Int, mapY: Int) {
    var tile = map.getTile(mapX, mapY);
    return tile == 1;
  }
}
