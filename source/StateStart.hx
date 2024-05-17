package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;

class StateStart extends FlxState
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
#if !mobile
		FlxG.mouse.useSystemCursor = true;
#end

        labelStart1 = new TextLabel(10, 10, "Shadow is coming! Space cows are the only salvation.");
        labelStart1.color = 0xA0A0A0;
        labelStart2 = new TextLabel(10, 40, "Rise cows on land, place fire on sand.");
        labelStart2.color = 0x808080;
        labelStart3 = new TextLabel(10, 70, "Get rid of Shadow!");
        labelStart3.color = 0x606060;

        labelLD42 = new TextLabel(470, 415, "#LudumDare 42");
        labelLD42.color = 0x606060;
        labelLD42.x = FlxG.width - labelLD42.fieldWidth - 15;
        labelLD42.y = FlxG.height - 60;

        labelCredits = new TextLabel(470, 435, "@net3ton");
        labelCredits.color = 0x606060;
        labelCredits.x = labelLD42.x;
        labelCredits.y = FlxG.height - 35;

        labelHint = new TextLabel(10, 430, "Click to start").hcenter().vpos(3);

        map = new HexMap();
		map.createLandsAround(FlxG.width/2, FlxG.height/2, this);
        map.expandMap(this);

        var random: FlxRandom = new FlxRandom();
        for (land in map.getLands())
        {
            if (land.landType == Field && random.int(0, 99) < 30)
            {
                land.addCows(this, random.int(0, 5));
            }
        }

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

#if mobile
        if (FlxG.touches.justReleased().length > 0)
#else
        if (FlxG.mouse.justPressed)
#end
        {
            FlxG.switchState(new StateGame());
        }
	}
}
