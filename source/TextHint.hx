package;

import flixel.text.FlxText;

class TextHint extends FlxText
{
	private var time: Float = 0;

	public function setup(hx: Float, hy: Float, htext: String): Void
	{
		text = htext;
		setPosition(hx - fieldWidth/2, hy);
		visible = true;
		alpha = 1;
		time = 0.5;
	}

	public function process(elapsed: Float): Void
	{
		if (visible)
		{
			y -= 100 * elapsed;
			time -= elapsed;
			alpha = Math.min((time*2) / 0.5, 1);

			if (time <= 0)
				visible = false;
		}
	}
}