package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

typedef BoardLine = {
    var pos: FlxText;
    var name: FlxText;
    var score: FlxText;
}

class LeadersState extends FlxState
{
    private var leaders = new Leaders();
    private var lines: Array<BoardLine> = [];
    private var linesCount = 15;

    private var labelTitle: FlxText;

    private var pname = "";
    private var pscore = 0;

	override public function create()
	{
        labelTitle = new FlxText(10, 20, 0, "Leaders", 18);
        labelTitle.x = (FlxG.width - labelTitle.fieldWidth) / 2;
        labelTitle.color = 0xFFFFFF;
        add(labelTitle);

        for (i in 0...linesCount)
        {
            var line: BoardLine = { pos: null, name: null, score: null };
            var ypos = 60 + i * (FlxG.height - 100)/linesCount;
            var color = (i % 2) == 1 ? 0x606060 : 0xA0A0A0;

            line.pos = new FlxText(150, ypos, 0, "", 16);
            line.name = new FlxText(200, ypos, 0, "", 16);
            line.score = new FlxText(450, ypos, 0, "", 16);
            lines.push(line);

            updateLineColor(line, color);

            add(line.pos);
            add(line.name);
            add(line.score);
        }

        leaders.onUpdate = updateLeaderboard;
        leaders.sendResults(pname, pscore);

        super.create();
	}

    public function init(name: String, score: Int): LeadersState
    {
        pname = name;
        pscore = score;
        return this;
    }

    private function updateLine(line: BoardLine, pos: Int, name: String, score: Int)
    {
        line.pos.text = "" + pos + ".";
        line.name.text = name;
        line.score.text = "" + score;
    }

    private function updateLineColor(line: BoardLine, color: FlxColor)
    {
        line.pos.color = color;
        line.name.color = color;
        line.score.color = color;
    }

    private function updateLeaderboard(board: Leaders.LeadersData)
    {
        if (board.pos < 0)
        {
            updateLine(lines[0], 1, pname, pscore);
            return;
        }

        var topCount = board.leaders.length;
        var botCount = board.around.length;
        var freeLines = linesCount;

        if (botCount > 0)
        {
            for (i in 0...botCount)
            {
                var ind = linesCount - botCount + i;

                var line = lines[ind];
                var boardInfo = board.around[i];
        
                updateLine(line, boardInfo.pos + 1, boardInfo.name, boardInfo.score);
                if (boardInfo.pos == board.pos)
                    updateLineColor(line, 0xFFFFFF);
            }

            freeLines -= (botCount + 1);
        }

        for (ind in 0...topCount)
        {
            if (ind >= freeLines)
                break;
    
            var line = lines[ind];
            var boardInfo = board.leaders[ind];
    
            updateLine(line, boardInfo.pos + 1, boardInfo.name, boardInfo.score);
            if (boardInfo.pos == board.pos)
                updateLineColor(line, 0xFFFFFF);
        }
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

        if (FlxG.keys.justReleased.ENTER || FlxG.mouse.justPressed)
        {
            FlxG.switchState(new MenuState());
        }
	}
}
