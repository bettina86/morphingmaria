package;

import flixel.FlxObject;

class Door extends MapObject {

  public var open: Bool;

  public function new(mapX: Int, mapY: Int, horizontal: Bool) {
    super(mapX, mapY, 2, 4);
    this.facing = horizontal ? FlxObject.DOWN : FlxObject.RIGHT;

    animation.add("closed_vertical", [0]);
    animation.add("open_vertical", [1]);
    animation.add("closed_horizontal", [2]);
    animation.add("open_horizontal", [3]);

    refresh();
  }

  public function setOpen(open: Bool) {
    this.open = open;
    refresh();
  }

  public function refresh() {
    animation.play((open ? "open_" : "closed_") + (this.facing == FlxObject.DOWN ? "horizontal" : "vertical"));
  }
}
