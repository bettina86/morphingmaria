package;

import flixel.FlxState;
import flixel.FlxG;

class StartState extends FlxState {
  public override function create() {
    if (FlxG.save.data.currentLevel == null) {
      FlxG.switchState(new Intro());
    } else {
      FlxG.switchState(new GameState());
    }
  }
}
