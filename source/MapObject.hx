package;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxTileFrames;

class MapObject extends FlxSprite {

  public var mapX: Int;
  public var mapY: Int;

  public function new(mapX: Int, mapY: Int) {
    super(Level.TILE_SIZE * mapX, Level.TILE_SIZE * mapY);

    this.mapX = mapX;
    this.mapY = mapY;
  }

  public function setFrameIndices(start: Int, count: Int) {
    var x = start % 10 * Level.TILE_SIZE;
    var y = Math.floor(start / 10) * Level.TILE_SIZE;
    var width = count * Level.TILE_SIZE;
    var height = Level.TILE_SIZE;
    var region = new FlxRect(x, y, width, height);
    frames = FlxTileFrames.fromRectangle("assets/images/tileset.png", Level.TILE_SIZE_POINT, region);
  }
}
