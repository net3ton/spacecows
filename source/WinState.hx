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

        updateName();
        FlxG.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);

        super.create();
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
            FlxG.switchState(new LeadersState().init(pname, pscore));
        }
	}
}
