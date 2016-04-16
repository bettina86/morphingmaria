package;

import flixel.FlxGame;
import flixel.FlxG;
import openfl.display.Sprite;

class Main extends Sprite {

	public function new() {
		super();
		addChild(new FlxGame(800, 600, GameState, true));
    FlxG.mouse.useSystemCursor = true;
	}
}
