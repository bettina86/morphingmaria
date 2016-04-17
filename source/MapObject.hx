package;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxTileFrames;

class MapObject extends FlxSprite {

  public var mapX: Int;
  public var mapY: Int;

  public function new(mapX: Int, mapY: Int, frames: FlxTileFrames) {
    super(Level.TILE_SIZE * mapX, Level.TILE_SIZE * mapY);

    this.mapX = mapX;
    this.mapY = mapY;
    this.frames = frames;
  }

  public static function tilesetFrames(frameStart: Int, frameCount: Int): FlxTileFrames {
    var x = frameStart % 10 * Level.TILE_SIZE;
    var y = Math.floor(frameStart / 10) * Level.TILE_SIZE;
    var nx = frameCount > 10 ? 10 : frameCount;
    var ny = Math.ceil(frameCount / nx);
    var width = nx * Level.TILE_SIZE;
    var height = ny * Level.TILE_SIZE;
    var region = new FlxRect(x, y, width, height);
    return FlxTileFrames.fromRectangle("assets/images/tileset.png", Level.TILE_SIZE_POINT, region);
  }

  private function addAnimation(name: String, frames: Array<Int>, flipX: Bool = false, frameRate: Int = 10) {
    animation.add(name, frames, frameRate, true, flipX);
  }

  public function setMapPosition(mapX: Int, mapY: Int) {
    this.mapX = mapX;
    this.mapY = mapY;
    this.setPosition(mapX * Level.TILE_SIZE, mapY * Level.TILE_SIZE);
  }

  public function isAt(x: Int, y: Int): Bool {
    return mapX == x && mapY == y;
  }
}
