package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;
import flixel.graphics.frames.FlxTileFrames;
import flixel.util.FlxColor;

class Intro extends FlxState {

  private var texts = new FlxGroup();

  public override function create() {
    var background = new FlxSprite(0, 0, "assets/images/background.png");
    background.y = 256 - background.height;
    background.alpha = 0;

    var princess = new FlxSprite();
    princess.x = (320 - Level.TILE_SIZE) / 2;
    princess.y = 256 - 40;
    princess.frames = FlxTileFrames.fromRectangle("assets/images/human.png", Level.TILE_SIZE_POINT);
    princess.animation.add("run", [6, 7, 8, 9], 10);
    princess.animation.add("walk", [6, 7, 8, 9], 3);
    princess.animation.add("stand", [5], 10);
    princess.animation.play("run");
    princess.alpha = 0;

    add(background);
    add(princess);
    add(texts);
    
    addText("After many adventures, Princess Maria", 2, 1000);
    addText("and Plumber Pete were finally together.", 3, 3000);
    addText("They were getting married!", 4, 5000);

    addText("But on the day before their wedding,", 6, 7000);
    addText("an evil monster kidnapped the plumber!", 7, 9000);

    addText("Fearlessly, Princess Maria chases after them...", 9, 11000);

    haxe.Timer.delay(function() {
      for (obj in texts) {
        FlxTween.tween(obj, {alpha: 0.0}, 1.0);
      }
      FlxTween.tween(background, {alpha: 1.0}, 1.0);
      FlxTween.tween(princess, {alpha: 1.0}, 1.0);
      FlxTween.tween(background, {y: 0.0}, 9.0, {ease: FlxEase.cubeOut});
    }, 13000);
    haxe.Timer.delay(function() {
      princess.animation.play("walk");
    }, 18000);
    haxe.Timer.delay(function() {
      princess.animation.play("stand");
    }, 21000);
    haxe.Timer.delay(function() {
      princess.animation.play("walk");
      FlxTween.tween(princess, {y: 200}, 4.0);
    }, 24000);
    haxe.Timer.delay(function() {
      princess.animation.play("walk");
      FlxTween.tween(princess, {alpha: 0}, 1.0);
    }, 27000);
    haxe.Timer.delay(function() {
      FlxTween.tween(background, {alpha: 0}, 1.0);
    }, 29000);
    haxe.Timer.delay(function() {
      FlxG.switchState(new GameState());
    }, 30000);
  }

  private function addText(str: String, y: Float, delay: Int) {
    var text = new FlxText(0, 16*y, 256+64, str);
    text.alignment = CENTER;
    text.borderStyle = SHADOW;
    text.alpha = 0;
    texts.add(text);
    haxe.Timer.delay(function() {
      FlxTween.tween(text, {alpha: 1.0}, 1.0);
    }, delay);
  }
}
