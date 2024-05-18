package;

import flixel.FlxG;
import flixel.FlxState;

class StateWin extends FlxState
{
    private var labelInfo: TextLabel;
    private var labelScore: TextLabel;
    private var labelEnter: TextLabel;
    private var labelName: TextLabel;

    private var pname = "Player";
    private var pscore = 0;

    private var nameCharacters = "-_.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    private var nameMaxLen = 16;

    private static inline var ENTER_TIMER = 0.3;
    private var pnameEnter = "";
    private var pnameEnterTimer: Float = ENTER_TIMER;

	override public function create():Void
	{
#if !mobile
		FlxG.mouse.useSystemCursor = true;
#end

        labelInfo = new TextLabel(10, 70, "You've made it in:").hcenter();
        labelInfo.color = 0xA0A0A0;
        labelScore = new TextLabel(10, 120, "" + pscore + " months").enlarge().hcenter();
        labelScore.color = 0xFFFFFF;
    
        labelEnter = new TextLabel(10, 180, "Enter your name, brave cow master:").hcenter();
        labelEnter.color = 0xA0A0A0;
        labelName = new TextLabel(10, 230, "").enlarge().hcenter();
        labelName.color = 0xFFFFFF;

        add(labelInfo);
        add(labelScore);
        add(labelEnter);
        add(labelName);

        var labelNext = new TextLabel(10, 445, "Click / Press Enter to continue").hcenter().vpos(3);
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

        var land21 = makeNeighbour(land, Water, RightBottom);
        var land22 = makeNeighbour(land21, Field, RightTop).addCows(this, cowsTwo1);
        makeNeighbour(land22, Sand, RightBottom).addBonefireAndPlayAnim(this);

        var land11 = makeNeighbour(land, Water, LeftBottom);
        var land12 = makeNeighbour(land11, Field, LeftTop).addCows(this, cowsTwo2);
        makeNeighbour(land12, Sand, LeftBottom).addBonefireAndPlayAnim(this);
    }

    private function makeNeighbour(hex: HexLand, type: HexLand.LandType, dir: HexLand.LandNeighbour): HexLand
    {
        var pos = hex.getNeighbourPos(dir);
        var land = new HexLand(pos.x, pos.y, type);
        add(land);
        return land;
    }

    public function setScore(score: Int): StateWin
    {
        pscore = score;
        return this;
    }

    private function updateName()
    {
        labelName.text = pname;
        labelName.hcenter();
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

#if mobile
        var gonext = FlxG.touches.justReleased().length > 0;
#else
        var gonext = FlxG.mouse.justPressed || FlxG.keys.justReleased.ENTER;
#end
        if (gonext && pname != "")
        {
            FlxG.sound.load("assets/sounds/click.wav").play();
            FlxG.switchState(new StateLeaders().init(pname, pscore));
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
