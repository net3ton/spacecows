package;

import flixel.FlxG;
import flixel.text.FlxText;

class TextLabel extends FlxText
{
	public function new(x:Float, y:Float, text:String)
	{
		super(x, y, 0, text, Main.fsize);

		//antialiasing = false;
        //pixelPerfectRender = true;
	}

	public function enlarge(): TextLabel
	{
		this.size = Main.fsize + 2;
		return this;
	}

	public function hcenter(): TextLabel
	{
		this.x = (FlxG.width - this.fieldWidth) / 2;
		return this;
	}

	public function vpos(ypos:Int): TextLabel
	{
		this.y = FlxG.height * 0.5 + (20 * Main.gscale) * ypos;
		return this;
	}
}
