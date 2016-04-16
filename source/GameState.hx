package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxPoint;

class GameState extends FlxState {

  private inline static var NUM_LEVELS = 10;

  private var world: FlxGroup;
  private var hud: FlxGroup;
  private var levelButtons: Array<FlxButton> = [];

  private var levelReached: Int = 1;
  private var level: Level;
  private var endingLevel: Bool;

  override public function create() {
    world = new FlxGroup();
    add(world);
    hud = new FlxGroup();
    add(hud);

    switchLevel(levelReached);
  }

  private function updateLevelButtons() {
    for (number in 1...NUM_LEVELS+1) {
      if (levelReached < number) {
        continue;
      }
      var button = levelButtons[number];
      if (button == null) {
        button = new FlxButton(256, 256 - 16 * number, function(n: Int) {
          return function() {
            switchLevelWithFade(n);
          }
        }(number));
        button.loadGraphic("assets/images/level_button.png");
        button.label = new FlxText(0, 0, 64, "Level " + number);
        button.label.alignment = CENTER;
        button.labelOffsets = [new FlxPoint(0, 1), new FlxPoint(0, 1), new FlxPoint(1, 2)];

        levelButtons[number] = button;
        hud.add(button);
      }
      button.label.borderStyle = level != null && level.number == number ? SHADOW : NONE;
    }
  }

  private function switchLevel(number: Int) {
    if (level != null) {
      world.remove(level);
      level = null;
    }
    if (number > 0) {
      if (number > levelReached) {
        levelReached = number;
      }
      if (number <= NUM_LEVELS) {
        level = new Level(number);
        world.add(level);
      } else {
        addEndScreen();
      }
    }
    updateLevelButtons();
  }

  private function switchLevelWithFade(number: Int, ?delay: Int = 0) {
    if (endingLevel) {
      return;
    }
    haxe.Timer.delay(function() {
      FlxG.camera.fade(FlxColor.BLACK, 1.0, false, function() {
        switchLevel(number);
        endingLevel = false;
        FlxG.camera.fade(FlxColor.BLACK, 1.0, true);
      });
    }, delay);
  }

  override public function update(elapsed: Float) {
    super.update(elapsed);

    if (level.finished) {
      switchLevelWithFade(level.number + 1, 500);
    }
  }

  private function addEndScreen() {
  }
}
