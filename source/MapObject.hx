package;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxTileFrames;

class MapObject extends FlxSprite {

  public var mapX: Int;
  public var mapY: Int;

  public function new(mapX: Int, mapY: Int, frameStart: Int, frameCount: Int) {
    super(Level.TILE_SIZE * mapX, Level.TILE_SIZE * mapY);

    this.mapX = mapX;
    this.mapY = mapY;

    var x = frameStart % 10 * Level.TILE_SIZE;
    var y = Math.floor(frameStart / 10) * Level.TILE_SIZE;
    var width = frameCount * Level.TILE_SIZE;
    var height = Level.TILE_SIZE;
    var region = new FlxRect(x, y, width, height);
    frames = FlxTileFrames.fromRectangle("assets/images/tileset.png", Level.TILE_SIZE_POINT, region);
  }

  private function addAnimation(name: String, frames: Array<Int>, ?flipX: Bool) {
    animation.add(name, frames, 10, true, flipX != null && flipX);
  }
}
