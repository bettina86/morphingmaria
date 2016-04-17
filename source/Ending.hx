package;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class Ending extends Level {

  public function new() {
    super("ending");

    player.slow = true;
    player.moveTo(player.mapX, player.mapY - 4);
  }

  public override function update(elapsed: Float) {
    super.update(elapsed);

    if (player.walking && player.canStop) {
      player.walking = false;
      player.refresh();
      addText("Thank you Maria!", 40, 1000);
      addText("But our plumber is in another castle!", 56, 3000);
      addText("THE END", 184, 7000);
      addText("Thank you for playing!", 200, 9000);
    }
  }

  private function addText(str: String, y: Float, delay: Int) {
    var text = new FlxText(0, y, 240, str);
    text.borderStyle = SHADOW;
    text.alpha = 0;
    text.alignment = CENTER;
    add(text);
    haxe.Timer.delay(function() {
      FlxTween.tween(text, {alpha: 1.0}, 1.0);
    }, delay);
  }
}
