package;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.FlxObject;

class Door extends MapObject {

  public var open: Bool = false;

  private var openSound: FlxSound;
  private var closeSound: FlxSound;

  public function new(mapX: Int, mapY: Int, horizontal: Bool) {
    super(mapX, mapY, MapObject.tilesetFrames(2, 4));
    this.facing = horizontal ? FlxObject.DOWN : FlxObject.RIGHT;

    animation.add("closed_vertical", [0]);
    animation.add("open_vertical", [1]);
    animation.add("closed_horizontal", [2]);
    animation.add("open_horizontal", [3]);

    openSound = FlxG.sound.load("assets/sounds/door_open.ogg", 0.2);
    closeSound = FlxG.sound.load("assets/sounds/door_close.ogg", 0.2);

    refresh();
  }

  public function setOpen(open: Bool) {
    if (this.open == open) {
      return;
    }
    this.open = open;
    refresh();
    if (open) {
      openSound.play();
    } else {
      closeSound.play();
    }
  }

  public function refresh() {
    animation.play((open ? "open_" : "closed_") + (this.facing == FlxObject.DOWN ? "horizontal" : "vertical"));
  }
}
