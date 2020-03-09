package;

import flixel.FlxG;
import flixel.text.FlxText;

class GameLabel extends FlxText
{
	public function new(x:Float, y:Float, text:String)
	{
		super(x, y, 0, text, Main.fsize);

		//antialiasing = false;
        //pixelPerfectRender = true;
	}

	public function enlarge(): GameLabel
	{
		this.size = Main.fsize + 2;
		return this;
	}

	public function hcenter(): GameLabel
	{
		this.x = (FlxG.width - this.fieldWidth) / 2;
		return this;
	}

	public function vpos(ypos:Int): GameLabel
	{
		this.y = FlxG.height * 0.5 + (20 * Main.gscale) * ypos;
		return this;
	}
}
