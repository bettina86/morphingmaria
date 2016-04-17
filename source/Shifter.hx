package;

class Shifter extends MapObject {

  public var shape: Shape;

  public function new(mapX: Int, mapY: Int, shapeIndex: Int) {
    super(mapX, mapY, MapObject.tilesetFrames(13, 4));

    switch (shapeIndex) {
      case 0:
        shape = Shape.HUMAN;
      case 1:
        shape = Shape.BEAR;
      case 2:
        shape = Shape.SNAKE;
      case 3:
        shape = Shape.UNKNOWN;
    }

    addAnimation("default", [shapeIndex]);
    animation.play("default");
  }
}
