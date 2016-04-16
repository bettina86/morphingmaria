package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEventManager;

class GameState extends FlxState {

  private var level: Level;

  override public function create(): Void {
    level = new Level(1);
    add(level);
  }
}
