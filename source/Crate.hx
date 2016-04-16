package;

import flixel.tweens.FlxTween;

class Crate extends MapObject {
  public function new(mapX: Int, mapY: Int) {
    super(mapX, mapY, 8, 1);
  }

  public function moveTo(mapX: Int, mapY: Int) {
    this.mapX = mapX;
    this.mapY = mapY;
    FlxTween.tween(this, {x: Level.TILE_SIZE * mapX, y: Level.TILE_SIZE * mapY}, 0.2);
  }
}

