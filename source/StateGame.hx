package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

class StateGame extends FlxState
{
	private var labelSpice: FlxText;
	private var labelStone: FlxText;
	private var labelTurn: FlxText;

	private var labelComplete: TextLabel;
	private var labelCompleteText: TextLabel;

	private var cowSound: FlxSound;
	private var fireSound: FlxSound;
	private var noneSound: FlxSound;

	private var cursorCow: FlxSprite;
	private var cursorStone: FlxSprite;
	private var cursorFire: FlxSprite;
	private var cursorSkip: FlxSprite;

	private var game: HexGame;
	private var hints: Array<TextHint> = [];
	private var hintsMaxCount = 10;

	override public function create()
	{
#if !mobile
		FlxG.mouse.useSystemCursor = true;
#end
		//FlxG.debugger.drawDebug = true;

		labelSpice = new TextLabel(10, 10, "spice: 000");
		labelStone = new TextLabel(110, 10, "stone: 000");
		labelTurn = new TextLabel(510, 10, "months: 000");
		labelTurn.x = FlxG.width - labelTurn.fieldWidth - 10;

		cowSound = FlxG.sound.load("assets/sounds/cow.wav");
		fireSound = FlxG.sound.load("assets/sounds/fire.wav");
		noneSound = FlxG.sound.load("assets/sounds/none.wav");

		cursorCow = new FlxSprite();
		cursorCow.loadGraphic("assets/images/cursor-cow.png");
		cursorStone = new FlxSprite();
		cursorStone.loadGraphic("assets/images/cursor-stone.png");
		cursorFire = new FlxSprite();
		cursorFire.loadGraphic("assets/images/cursor-fire.png");
		cursorSkip = new FlxSprite();
		cursorSkip.loadGraphic("assets/images/cursor-skip.png");

		add(labelSpice);
		add(labelStone);
		add(labelTurn);
		
		game = new HexGame(FlxG.width/2, FlxG.height/2, this);
	
		initHints();
		updateLabels();

		FlxG.sound.load("assets/sounds/start.wav").play();
		super.create();
	}

	public function updateLabels()
	{
		labelSpice.text = "spice: " + game.spiceCount;
		labelStone.text = "stone: " + game.stoneCount;
		labelTurn.text = "months: " + game.turn;
	}

	private function initComplete()
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

	private function showComplete(title: String, text: String)
	{
		initComplete();

		labelComplete.text = title;
		labelComplete.hcenter();
		labelComplete.visible = true;

		labelCompleteText.text = text;
		labelCompleteText.hcenter();
		labelCompleteText.visible = true;
	}

	public function showGameOver()
	{
		showComplete("Game over", "Dark times has come!");
		FlxG.sound.load("assets/sounds/gameover.wav").play();
	}

	public function showGameWin()
	{
		showComplete("You win", "Praise the sun!");
		FlxG.sound.load("assets/sounds/win.wav").play();
	}

	private function initHints()
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

	public function showHint(x: Float, y: Float, text: String)
	{
		getFreeHint().setup(x, y, text);
	}

	public function clearHints()
	{
		for (hint in hints)
			hint.visible = false;
	}

	public function playCow()
	{
		cowSound.play();
	}

	public function playFire()
	{
		fireSound.play();
	}

	public function playNone()
	{
		noneSound.play();
	}

#if !mobile
	public function setMouseCursorSkip()
	{
		FlxG.mouse.load(cursorSkip.pixels, 3.0, -18, -18);
	}

	public function setMouseCursorBonefire()
	{
		FlxG.mouse.load(cursorFire.pixels, 3.0, -18, -15);
	}

	public function setMouseCursorCow()
	{
		FlxG.mouse.load(cursorCow.pixels, 4.0, -12, -8);
	}

	public function setMouseCursorStone()
	{
		FlxG.mouse.load(cursorStone.pixels, 4.0, -12, -8);
	}
#end

	override public function update(elapsed: Float)
	{
		super.update(elapsed);
		game.update(elapsed);

		for (hint in hints)
			hint.process(elapsed);
	}
}
