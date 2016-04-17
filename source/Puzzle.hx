package;

import flixel.FlxG;

class Puzzle extends Level {

  public function new(number: Int) {
    super("level" + number);

    if (number == 1) {
      showHint("Use the arrow keys to move");
    }
  }

  override public function update(elapsed: Float): Void {
    super.update(elapsed);

    if (finished) {
      return;
    }

    var dx = 0;
    var dy = 0;
    if (FlxG.keys.anyPressed([LEFT, A, O])) {
      dx--;
    }
    if (FlxG.keys.anyPressed([RIGHT, D, U])) {
      dx++;
    }
    if (FlxG.keys.anyPressed([UP, W, PERIOD])) {
      dy--;
    }
    if (FlxG.keys.anyPressed([DOWN, S, E])) {
      dy++;
    }
    if (dx != 0 && dy == 0 || dx == 0 && dy != 0) {
      if (player.canStop) {
        move(dx, dy);
      }
    }
    if (player.walking && player.canStop) {
      player.walking = false;
      player.refresh();
    }
  }
}
