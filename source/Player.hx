package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.graphics.frames.FlxTileFrames;
import flixel.FlxObject;

class Player extends MapObject {

  public var walking: Bool;
  public var canStop: Bool = true;
  public var carried: Array<MapObject> = [];
  public var shape: Shape = Shape.HUMAN;
  public var slow: Bool;

  public function new(mapX: Int, mapY: Int) {
    super(mapX, mapY, makeFrames());
    for (i in 0...2) {
      var suffix = i == 0 ? "" : "_slow";
      var frameRate = i == 0 ? 10 : 4;
      addAnimation("stand_left" + suffix, [10], true, frameRate);
      addAnimation("walk_left" + suffix, [11, 12, 13, 14], true, frameRate);
      addAnimation("stand_right" + suffix, [10], false, frameRate);
      addAnimation("walk_right" + suffix, [11, 12, 13, 14], false, frameRate);
      addAnimation("stand_up" + suffix, [5], false, frameRate);
      addAnimation("walk_up" + suffix, [6, 7, 8, 9], false, frameRate);
      addAnimation("stand_down" + suffix, [0], false, frameRate);
      addAnimation("walk_down" + suffix, [1, 2, 3, 4], false, frameRate);
    }
    facing = FlxObject.DOWN;
    refresh();
  }

  private static function makeFrames(): FlxTileFrames {
    return FlxTileFrames.combineTileFrames([
      FlxTileFrames.fromRectangle("assets/images/human.png", Level.TILE_SIZE_POINT),
      FlxTileFrames.fromRectangle("assets/images/bear.png", Level.TILE_SIZE_POINT),
      FlxTileFrames.fromRectangle("assets/images/snake.png", Level.TILE_SIZE_POINT),
      FlxTileFrames.fromRectangle("assets/images/human.png", Level.TILE_SIZE_POINT),
    ]);
  }

  private override function addAnimation(name: String, frames: Array<Int>, flipX: Bool = false, frameRate: Int = 10) {
    var f = function(offset: Int) {
      var ret = [];
      for (frame in frames) {
        ret.push(offset + frame);
      }
      return ret;
    }
    super.addAnimation("human_" + name, f(0), flipX, frameRate);
    super.addAnimation("bear_" + name, f(15), flipX, frameRate);
    super.addAnimation("snake_" + name, f(30), flipX, frameRate);
    super.addAnimation("unknown_" + name, f(45), flipX, frameRate);
  }

  public function moveTo(mapX: Int, mapY: Int) {
    var dx = mapX - this.mapX;
    var dy = mapY - this.mapY;
    var d = Math.abs(dx) + Math.abs(dy);
    this.mapX = mapX;
    this.mapY = mapY;
    this.walking = true;
    this.canStop = false;
    var duration = slow ? 1.0 * d : 0.2 * d;
    FlxTween.tween(this, {x: Level.TILE_SIZE * mapX, y: Level.TILE_SIZE * mapY}, duration, {
      onComplete: function(tween: FlxTween) {
        this.canStop = true;
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
    haxe.Timer.delay(this.refresh, 100);
  }

  public function refresh() {
    var slowSuffix = slow ? "_slow" : "";
    var name;
    if (walking) {
      name = shapePrefix() + "_walk_" + facingSuffix() + slowSuffix;
    } else {
      name = shapePrefix() + "_stand_" + facingSuffix() + slowSuffix;
    }
    animation.play(name);
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
