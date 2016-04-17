package;

import flixel.FlxGame;
import flixel.FlxG;
import openfl.display.Sprite;
import flixel.FlxState;

class Main extends Sprite {

	public function new() {
		super();

		addChild(new FlxGame(320, 256, StartState, true));

    FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();
    FlxG.camera.pixelPerfectRender = true;
    FlxG.mouse.useSystemCursor = true;
	}
}
