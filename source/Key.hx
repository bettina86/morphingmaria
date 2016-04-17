package;

class Key extends MapObject {
  public function new(mapX: Int, mapY: Int) {
    super(mapX, mapY, MapObject.tilesetFrames(12, 1));
  }
}
