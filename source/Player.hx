package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Player extends MapObject {

  public var tweening: Bool;

  public function new(mapX: Int, mapY: Int) {
    super(mapX, mapY);

    setFrameIndices(10, 1);
  }

  public function moveTo(mapX: Int, mapY: Int) {
    this.mapX = mapX;
    this.mapY = mapY;
    this.tweening = true;
    FlxTween.tween(this, {x: Level.TILE_SIZE * mapX, y: Level.TILE_SIZE * mapY}, 0.2, { onComplete: moveComplete });
  }

  private function moveComplete(tween: FlxTween) {
    this.tweening = false;
  }
}
