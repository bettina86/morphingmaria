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

  private inline static var TILE_SIZE = 16;

  private var map: TiledMap;

  public function new(number: Int) {
    super();

    var filename = "assets/levels/level" + number + ".tmx";
    map = new TiledMap(filename);

    FlxG.camera.focusOn(new FlxPoint(map.fullWidth / 2, map.fullHeight / 2));

    for (layer in map.layers) {
      if (layer.type != TiledLayerType.TILE) continue;
      var tileLayer: TiledTileLayer = cast layer;

      var tilemap: FlxTilemap = new FlxTilemap();
      tilemap.loadMapFromArray(tileLayer.tileArray, tileLayer.width, tileLayer.height,
          "assets/images/tileset.png", TILE_SIZE, TILE_SIZE, OFF, 1);

      add(tilemap);

      // loadObjects(state);

      // if (tileLayer.properties.contains("nocollide")) {
      //   backgroundLayer.add(tilemap);
      // } else {
      //   if (collidableTileLayers == null) {
      //     collidableTileLayers = new Array<FlxTilemap>();
      //   }

      //   foregroundTiles.add(tilemap);
      //   collidableTileLayers.push(tilemap);
      // }
    }
  }
}
