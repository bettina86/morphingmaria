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
import flixel.system.FlxSound;

class GameState extends FlxState {

  public inline static var NUM_LEVELS = 10;

  private var world: FlxGroup;
  private var hud: FlxGroup;
  private var levelButtons: Array<FlxButton> = [];

  private var currentLevel: Int = 1;
  private var levelReached: Int = 1;
  private var level: Level;
  private var endingLevel: Bool;

  private var buttonDownSound: FlxSound;
  private var buttonUpSound: FlxSound;
  private var enterLevelSound: FlxSound;
  private var exitLevelSound: FlxSound;

  override public function create() {
    buttonDownSound = FlxG.sound.load("assets/sounds/click.ogg");
    buttonUpSound = FlxG.sound.load("assets/sounds/click2.ogg");
    enterLevelSound = FlxG.sound.load("assets/sounds/enter.ogg");
    exitLevelSound = FlxG.sound.load("assets/sounds/exit.ogg");

    world = new FlxGroup();
    add(world);
    hud = new FlxGroup();
    add(hud);
    addRestartButton();

    load();

    switchLevel(currentLevel);
    level.fadeIn();
  }

  private function addRestartButton() {
    var button = new FlxButton(256, 0, function() {
      switchLevelWithFade(currentLevel);
    });
    button.loadGraphic("assets/images/level_button.png");
    button.label = new FlxText(0, 0, 64, "Restart");
    button.label.alignment = CENTER;
    button.labelOffsets = [new FlxPoint(0, 1), new FlxPoint(0, 1), new FlxPoint(1, 2)];
    button.onDown.sound = buttonDownSound;
    button.onUp.sound = buttonUpSound;
    hud.add(button);
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
        button.onDown.sound = buttonDownSound;
        button.onUp.sound = buttonUpSound;

        levelButtons[number] = button;
        hud.add(button);
      }
      button.label.borderStyle = number == currentLevel ? SHADOW : NONE;
    }
  }

  private function switchLevel(number: Int) {
    if (level != null) {
      world.remove(level);
      level = null;
    }
    currentLevel = number;
    if (number > levelReached) {
      levelReached = number;
    }
    if (number <= NUM_LEVELS) {
      level = new Puzzle(number);
    } else {
      level = new Ending();
    }
    world.add(level);
    updateLevelButtons();
    save();
    enterLevelSound.play();
  }

  private function switchLevelWithFade(number: Int, ?delay: Int = 0) {
    if (endingLevel) {
      return;
    }
    endingLevel = true;
    haxe.Timer.delay(function() {
      level.fadeOut(function() {
        switchLevel(number);
        endingLevel = false;
        level.fadeIn();
      });
    }, delay);
  }

  override public function update(elapsed: Float) {
    super.update(elapsed);

    if (level.finished) {
      if (!endingLevel) {
        exitLevelSound.play();
      }
      switchLevelWithFade(currentLevel + 1, 500);
    }
  }

  private function load() {
    var currentLevel: Null<Int> = FlxG.save.data.currentLevel;
    if (currentLevel != null) {
      this.currentLevel = currentLevel;
    }
    var levelReached: Null<Int> = FlxG.save.data.levelReached;
    if (levelReached != null) {
      this.levelReached = levelReached;
    }
  }

  private function save() {
    FlxG.save.data.currentLevel = currentLevel;
    FlxG.save.data.levelReached = levelReached;
    FlxG.save.flush();
  }
}
