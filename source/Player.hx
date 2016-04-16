package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxObject;

class Player extends MapObject {

  public var walking: Bool;
  public var carried: Array<MapObject> = [];
  public var shape: Shape = Shape.HUMAN;

  public function new(mapX: Int, mapY: Int) {
    super(mapX, mapY, 60, 40);
    addAnimation("stand_left", [0], true);
    addAnimation("walk_left", [1, 2], true);
    addAnimation("stand_right", [0]);
    addAnimation("walk_right", [1, 2]);
    addAnimation("stand_up", [3]);
    addAnimation("walk_up", [4, 5]);
    addAnimation("stand_down", [6]);
    addAnimation("walk_down", [7, 8]);
    facing = FlxObject.DOWN;
    refresh();
  }

  private override function addAnimation(name: String, frames: Array<Int>, ?flipX: Bool) {
    var f = function(offset: Int) {
      var ret = [];
      for (frame in frames) {
        ret.push(offset + frame);
      }
      return ret;
    }
    super.addAnimation("human_" + name, f(0), flipX);
    super.addAnimation("bear_" + name, f(10), flipX);
    super.addAnimation("snake_" + name, f(20), flipX);
    super.addAnimation("unknown_" + name, f(30), flipX);
  }

  public function moveTo(mapX: Int, mapY: Int) {
    var dx = mapX - this.mapX;
    var dy = mapY - this.mapY;
    this.mapX = mapX;
    this.mapY = mapY;
    this.walking = true;
    FlxTween.tween(this, {x: Level.TILE_SIZE * mapX, y: Level.TILE_SIZE * mapY}, 0.2, {
      onComplete: function(tween: FlxTween) {
        this.walking = false;
        refresh();
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

    refresh();
  }

  public function shiftShape(shape: Shape) {
    this.shape = shape;
    refresh();
  }

  private function refresh() {
    if (walking) {
      animation.play(shapePrefix() + "_walk_" + facingSuffix());
    } else {
      animation.play(shapePrefix() + "_stand_" + facingSuffix());
    }
  }

  private function shapePrefix(): String {
    switch (shape) {
      case Shape.HUMAN: return "human";
      case Shape.BEAR: return "bear";
      case Shape.SNAKE: return "snake";
      case Shape.UNKNOWN: return "unknown";
      default: return "";
    }
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
      default:
        return "ERROR";
    }
  }

  public override function update(elapsed: Float) {
    super.update(elapsed);
    var offset = 0;
    for (obj in carried) {
      obj.x = this.x + 3 + offset;
      obj.y = this.y - 7 - offset;
      offset += 2;
    }
  }

  public function pickUp(obj: MapObject) {
    obj.mapX = -1;
    obj.mapY = -1;
    carried.push(obj);
  }

  public function getCarriedKey(): Key {
    for (obj in carried) {
      if (Std.is(obj, Key)) {
        return cast obj;
      }
    }
    return null;
  }
}
