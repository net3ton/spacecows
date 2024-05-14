package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

class StateGame extends FlxState
{
	private var labelSpice: FlxText;
	private var labelTurn: FlxText;

	private var labelComplete: TextLabel;
	private var labelCompleteText: TextLabel;

	private var cowSound: FlxSound;
	private var fireSound: FlxSound;
	private var noneSound: FlxSound;

	private var map: HexMap;
	private var hints: Array<TextHint> = [];
	private var hintsMaxCount = 10;

	override public function create():Void
	{
#if !mobile
		FlxG.mouse.useSystemCursor = true;
#end
		//FlxG.debugger.drawDebug = true;

		labelSpice = new TextLabel(15, 10, "spice: 000");
		labelTurn = new TextLabel(510, 10, "months: 000");
		labelTurn.x = FlxG.width - labelTurn.fieldWidth - 10;

		cowSound = FlxG.sound.load("assets/sounds/cow.wav");
		fireSound = FlxG.sound.load("assets/sounds/fire.wav");
		noneSound = FlxG.sound.load("assets/sounds/none.wav");

		add(labelSpice);
		add(labelTurn);
		
		map = new HexMap();
		map.createMap(new FlxPoint(FlxG.width/2, FlxG.height/2), this);
	
		initHints();
		updateLabels();

		FlxG.sound.load("assets/sounds/start.wav").play();
		super.create();
	}

	public function updateLabels(): Void
	{
		labelSpice.text = "spice: " + map.spiceCount;
		labelTurn.text = "months: " + map.turn;
	}

	private function initComplete(): Void
	{
		labelComplete = new TextLabel(0, 80, "").hcenter();
		labelComplete.setBorderStyle(flixel.text.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
		labelComplete.visible = false;
		add(labelComplete);

		labelCompleteText = new TextLabel(0, 110, "").hcenter();
		labelCompleteText.setBorderStyle(flixel.text.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
		labelCompleteText.visible = false;
		add(labelCompleteText);
	}

	private function showComplete(title: String, text: String): Void
	{
		initComplete();

		labelComplete.text = title;
		labelComplete.hcenter();
		labelComplete.visible = true;

		labelCompleteText.text = text;
		labelCompleteText.hcenter();
		labelCompleteText.visible = true;
	}

	public function showGameOver(): Void
	{
		showComplete("Game over", "Dark times has come!");
		FlxG.sound.load("assets/sounds/gameover.wav").play();
	}

	public function showGameWin(): Void
	{
		showComplete("You win", "Praise the sun!");
		FlxG.sound.load("assets/sounds/win.wav").play();
	}

	private function initHints(): Void
	{
		for (i in 0...hintsMaxCount)
		{
			var hint = new TextHint(0, 0, 0, "", 16);
			hint.visible = false;
			hints.push(hint);
			add(hint);
		}
	}

	private function getFreeHint(): TextHint
	{
		for (hint in hints)
		{
			if (!hint.visible)
				return hint;
		}

		return hints[0];
	}

	public function showHint(x: Float, y: Float, text: String): Void
	{
		getFreeHint().setup(x, y, text);
	}

	public function clearHints(): Void
	{
		for (hint in hints)
			hint.visible = false;
	}

	public function playCow(): Void
	{
		cowSound.play();
	}

	public function playFire(): Void
	{
		fireSound.play();
	}

	public function playNone(): Void
	{
		noneSound.play();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		map.update(elapsed);

		for (hint in hints)
			hint.process(elapsed);
	}
}
