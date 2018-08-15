package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.math.FlxVector;

class MenuState extends FlxState
{
    private var labelStart1: FlxText;
    private var labelStart2: FlxText;
    private var labelStart3: FlxText;
    private var labelHint: FlxText;

    private var labelLD42: FlxText;
    private var labelCredits: FlxText;

    private var map: HexMap;

	override public function create():Void
	{
        FlxG.mouse.useSystemCursor = true;

        labelStart1 = new FlxText(10, 10, 0, "Shadow is coming! Space cows are the only salvation.", 16);
        labelStart1.color = 0xA0A0A0;
        labelStart2 = new FlxText(10, 40, 0, "Rise cows on land, place fire on sand.", 16);
        labelStart2.color = 0x808080;
        labelStart3 = new FlxText(10, 70, 0, "Get rid of Shadow!", 16);
        labelStart3.color = 0x606060;

        labelLD42 = new FlxText(470, 415, 0, "#LudumDare 42", 16);
        labelLD42.color = 0x606060;
        labelCredits = new FlxText(470, 435, 0, "@net3ton", 16);
        labelCredits.color = 0x606060;

        labelHint = new FlxText(10, 430, 0, "Click to start", 16);
        labelHint.x = (FlxG.width - labelHint.fieldWidth) / 2;

        map = new HexMap();
		map.createPatch(new FlxVector(FlxG.width/2, FlxG.height/2), this);
        map.expandMap(this);

        add(labelStart1);
        add(labelStart2);
        add(labelStart3);
        add(labelLD42);
        add(labelCredits);
        add(labelHint);

        super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

        if (FlxG.mouse.justPressed)
        {
            FlxG.switchState(new PlayState());
        }
	}
}
