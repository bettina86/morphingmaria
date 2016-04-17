package;

import flixel.tweens.FlxTween;

class Exit extends MapObject {
  public function new(mapX: Int, mapY: Int) {
    super(mapX, mapY, MapObject.tilesetFrames(11, 1));
  }
}

