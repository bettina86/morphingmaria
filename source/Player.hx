package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxObject;

class Player extends MapObject {

  public var tweening: Bool;

  public function new(mapX: Int, mapY: Int) {
    super(mapX, mapY, 20, 9);
    addAnimation("stand_left", [0], true);
    addAnimation("walk_left", [1, 2], true);
    addAnimation("stand_right", [0]);
    addAnimation("walk_right", [1, 2]);
    addAnimation("stand_up", [3]);
    addAnimation("walk_up", [4, 5]);
    addAnimation("stand_down", [6]);
    addAnimation("walk_down", [7, 8]);
    facing = FlxObject.DOWN;
    setStillFrame();
  }

  public function moveTo(mapX: Int, mapY: Int) {
    var dx = mapX - this.mapX;
    var dy = mapY - this.mapY;
    this.mapX = mapX;
    this.mapY = mapY;
    this.tweening = true;
    FlxTween.tween(this, {x: Level.TILE_SIZE * mapX, y: Level.TILE_SIZE * mapY}, 0.2, {
      onComplete: function(tween: FlxTween) {
        setStillFrame();
        this.tweening = false;
      }
    });

    if (dx > 0) {
      facing = FlxObject.RIGHT;
    } else if (dx < 0) {
      facing = FlxObject.LEFT;
    } else if (dy < 0) {
      facing = FlxObject.UP;
    } else if (dy > 0) {
      facing = FlxObject.DOWN;
    }

    animation.play("walk_" + facingSuffix());
  }

  private function setStillFrame() {
    animation.play("stand_" + facingSuffix());
  }

  private function facingSuffix(): String {
    switch (facing) {
      case FlxObject.LEFT:
        return "left";
      case FlxObject.RIGHT:
        return "right";
      case FlxObject.UP:
        return "up";
      case FlxObject.DOWN:
        return "down";
    }
  }
}
