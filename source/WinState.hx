package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class WinState extends FlxState
{
    private var labelInfo: FlxText;
    private var labelScore: FlxText;
    private var labelEnter: FlxText;
    private var labelName: FlxText;

    private var pname = "Player";
    private var pscore = 0;

    private var nameCharacters = "-_.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    private var nameMaxLen = 16;

    private static inline var ENTER_TIMER = 0.3;
    private var pnameEnter = "";
    private var pnameEnterTimer: Float = ENTER_TIMER;

	override public function create():Void
	{
        FlxG.mouse.useSystemCursor = true;

        labelInfo = new FlxText(10, 70, 0, "You've made it in:", 16);
        labelInfo.x = (FlxG.width - labelInfo.fieldWidth) / 2;
        labelInfo.color = 0xA0A0A0;
        labelScore = new FlxText(10, 120, 0, "" + pscore + " months", 18);
        labelScore.x = (FlxG.width - labelScore.fieldWidth) / 2;
        labelScore.color = 0xFFFFFF;
    
        labelEnter = new FlxText(10, 180, 0, "Enter your name, brave cow master:", 16);
        labelEnter.x = (FlxG.width - labelEnter.fieldWidth) / 2;
        labelEnter.color = 0xA0A0A0;
        labelName = new FlxText(10, 230, 0, "", 18);
        labelName.color = 0xFFFFFF;

        add(labelInfo);
        add(labelScore);
        add(labelEnter);
        add(labelName);

        var labelNext = new FlxText(10, 445, 0, "Click / Press Enter to continue", 16);
        labelNext.x = (FlxG.width - labelNext.fieldWidth) / 2;
        add(labelNext);

        prepareCompo(pscore);

        updateName();
        FlxG.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);

        super.create();
	}

    private function prepareCompo(score: Int)
    {
        var minScore = Std.int(Math.max(score - 25, 0));
        var cowsTop = Std.int(5 - Math.min(minScore / 20, 5));
        var cowsTwo = Std.int(10 - Math.min(minScore / 30, 10));
        var cowsTwo1 = Std.int(cowsTwo / 2);
        var cowsTwo2 = cowsTwo - cowsTwo1;

        var land = new HexLand(FlxG.width/2, 340, Field);
        add(land);
        land.addCows(this, cowsTop);

        var land21 = makeNeighbour(land, Sea, RightBottom);
        var land22 = makeNeighbour(land21, Field, RightTop).addCows(this, cowsTwo1);
        makeNeighbour(land22, Sand, RightBottom).addFire(this);

        var land11 = makeNeighbour(land, Sea, LeftBottom);
        var land12 = makeNeighbour(land11, Field, LeftTop).addCows(this, cowsTwo2);
        makeNeighbour(land12, Sand, LeftBottom).addFire(this);
    }

    private function makeNeighbour(hex: HexLand, type: HexLand.LandType, dir: HexLand.LandNeighbour): HexLand
    {
        var pos = hex.getNeighbourPos(dir);
        var land = new HexLand(pos.x, pos.y, type);
        add(land);
        return land;
    }

    public function setScore(score: Int): WinState
    {
        pscore = score;
        return this;
    }

    private function updateName()
    {
        labelName.text = pname;
        labelName.x = (FlxG.width - labelName.fieldWidth) / 2;
        labelName.text += pnameEnter;
    }

    private function onKeyDown(evt: flash.events.KeyboardEvent)
    {
        if (evt.charCode == flixel.input.keyboard.FlxKey.BACKSPACE)
        {
            pname = pname.substr(0, pname.length - 1);
            updateName();
            return;
        }

        if (pname.length < nameMaxLen)
        {
            var char = String.fromCharCode(evt.charCode);
            if (nameCharacters.indexOf(char) > -1)
            {
                pname += char;
                updateName();
            }
        }
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

        var gonext = FlxG.mouse.justPressed || FlxG.keys.justReleased.ENTER;
        if (gonext && pname != "")
        {
            FlxG.sound.load("assets/sounds/click.wav").play();
            FlxG.switchState(new LeadersState().init(pname, pscore));
        }

        pnameEnterTimer -= elapsed;
        if (pnameEnterTimer <= 0)
        {
            pnameEnterTimer = ENTER_TIMER;
            pnameEnter = (pnameEnter == "") ? "_" : "";
            updateName();
        }
	}
}
