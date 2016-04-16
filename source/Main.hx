package;

import flixel.FlxGame;
import flixel.FlxG;
import openfl.display.Sprite;

class Main extends Sprite {

	public function new() {
		super();

		addChild(new FlxGame(320, 256, GameState, true));

    FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();
    FlxG.camera.pixelPerfectRender = true;
    FlxG.mouse.useSystemCursor = true;
	}
}
