package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var gscale = 3;
	public static var fsize = 16;

	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, StateStart));

		// to test leaderboards
		//flixel.FlxG.switchState(new StateWin().setScore(250));
	}
}
