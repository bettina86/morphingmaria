package;

import flixel.FlxSprite;

class MapObject extends FlxSprite {

  public var mapX: Int;
  public var mapY: Int;

  public function new(mapX: Int, mapY: Int) {
    super(Level.TILE_SIZE * mapX, Level.TILE_SIZE * mapY);

    this.mapX = mapX;
    this.mapY = mapY;
  }
}
