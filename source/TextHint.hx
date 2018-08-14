package;

import flixel.text.FlxText;

class TextHint extends FlxText
{
	private var time: Float = 0;

	public function resetTime(): Void
	{
		time = 0.5;
	}

	public function process(elapsed: Float): Bool
	{
		y -= 100 * elapsed;
		time -= elapsed;

		return (time <= 0);
	}
}