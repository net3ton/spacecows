package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;

class HexMap
{
    public var turn = 0;
    public var spiceCount = 0;

    private var gameOver = false;
    private var gameWin = false;

    private var lands: Array<HexLand> = [];
    private var locusts: Array<HexLand> = [];
    private var level: PlayState;

    private var cursorCow: FlxSprite;
    private var cursorLight: FlxSprite;
    private var cursorSkip: FlxSprite;

    private var hexDeltas: Array<FlxVector> = [
        new FlxVector(0, -21),
        new FlxVector(20, -11),
        new FlxVector(20, 10),
        new FlxVector(0, 21),
        new FlxVector(-20, -11),
        new FlxVector(-20, 10),
    ];

    public function new()
	{
        cursorCow = new FlxSprite();
        cursorCow.loadGraphic("assets/images/cursor-cow.png", false, 6, 4);

        //FlxG.mouse.load(cursorCow.pixels);
    }

    public function createPatch(pos: FlxVector, to: FlxState): Void
	{
        var hexScale = 3;

        for (delta in hexDeltas)
        {
            createIfNeeded(pos.x + delta.x * hexScale, pos.y + delta.y * hexScale, to);
        }
	}

    public function createMap(pos: FlxVector, to: PlayState): Void
    {
        level = to;

        var baseHex = new HexLand(pos.x, pos.y, Base);
        lands.push(baseHex);
		level.add(baseHex);

        createPatch(pos, level);
        expandMap(level);
        expandMap(level);

        /// init enemy
        var random: FlxRandom = new FlxRandom();
        var rand = random.int(0, 17);
        var locust = lands[lands.length - rand - 1];

        locust.setLocust(true);
        locusts.push(locust);
    }

    public function expandMap(to: FlxState): Void
    {
        for (hex in lands.copy())
            createPatch(hex.landPos, to);
    }

    private function getLand(x: Float, y: Float): HexLand
    {
        for (land in lands)
        {
            var diff = Math.abs(land.landPos.x - x) + Math.abs(land.landPos.y - y);
            if (diff < 5)
                return land;
        }

        return null;
    }

    private function createIfNeeded(x: Float, y: Float, to: FlxState): Void
    {
        if (getLand(x, y) != null)
            return;

        var hex = new HexLand(x, y, Random);
        lands.push(hex);
		to.add(hex);
    }

    private function hittestLand(pos: FlxPoint): HexLand
    {
        for (land in lands)
        {
            var landPos = land.landPos;
            var dist = Math.pow((pos.x - landPos.x), 2) + Math.pow((pos.y - landPos.y), 2);

            if (dist < 700)
                return land;
        }

        return null;
    }

    private function getNearbyHexes(hex: HexLand): Array<HexLand>
    {
        var nearby: Array<HexLand> = [];

        for (delta in hexDeltas)
        {
            var sideHex = getLand(hex.landPos.x + delta.x * 3, hex.landPos.y + delta.y * 3);
            if (sideHex != null)
                nearby.push(sideHex);
        }

        return nearby;
    }

    private function spreadLocust(): Void
    {
        var next: Array<HexLand> = [];

        for (hex in locusts)
        {
            var nears = getNearbyHexes(hex);
            for (sideHex in nears)
            {
                if (!sideHex.isLocust() && next.indexOf(sideHex) < 0)
                {
                    if (sideHex.landType == Sea)
                        continue;

                    var some1 = getNearbyHexes(sideHex);
                    var can = true;

                    for (some in some1)
                    {
                        if (some.isLight())
                        {
                            can = false;
                            break;
                        }
                    }

                    if (can)
                        next.push(sideHex);

                    //if (!sideHex.isLight())
                    //    next.push(sideHex);
                }
            }
        }

        if (next.length == 0)
            return;

        var random: FlxRandom = new FlxRandom();
        var rand = random.int(0, next.length - 1);
        var locust = next[rand];

        //if (checkProtection(locust))
        //    return;

        locust.setLocust(true);
        locusts.push(locust);
    }

    /*
    private function checkProtection(locust: HexLand): Bool
    {
        var nearLocust = getNearbyHexes(locust);
        nearLocust.push(locust);

        for (sideHex in nearLocust)
        {
            if (sideHex.hitLight())
            {
                level.addHint(sideHex.landPos.x, sideHex.landPos.y, "-1");
                level.addHint(locust.landPos.x, locust.landPos.y, "protected");
                return true;
            }
        }

        return false;
    }
    */

    private function processLocust(): Void
    {
        for (hex in locusts)
        {
            if (hex.hitCowByLocust())
            {
                level.addHint(hex.landPos.x, hex.landPos.y, "-1");
            }
        }
    }

    private function nextTurn(): Void
    {
        turn += 1;
        gameWin = true;

        for (land in lands)
        {
            if (land.isLocust())
                gameWin = false;

            if (land.landType == Field)
            {
                spiceCount += land.harvest();
            }

            if (land.landType == Sand)
            {
                var count = land.hitLight();
                if (count > 0)
                    level.addHint(land.landPos.x, land.landPos.y, "" + count);
            }
        }

        if (lands[0].isLocust())
        {
            gameOver = true;
            level.showGameOver();
        }

        if (gameWin)
        {
            level.showGameWin();
        }
    }

    private function addCow(hex: HexLand): Void
    {
        var cow = hex.addCow();
        if (cow != null)
        {
            level.add(cow);
        }
    }

    private function addLight(hex: HexLand): Void
    {
        var camp = hex.addLight();
        if (camp!= null)
        {
            level.add(camp);

            var nears = getNearbyHexes(hex);
            for (nearHex in nears)
            {
                if (nearHex.isLocust())
                {
                    /*
                    hex.hitLight();

                    level.addHint(hex.landPos.x, hex.landPos.y, "-1");
                    level.addHint(nearHex.landPos.x, nearHex.landPos.y, "protected");
                    */

                    locusts.remove(nearHex);
                    nearHex.setLocust(false);
                }
            }
        }
    }

    public function update(elapsed: Float): Void 
    {
        if (FlxG.mouse.justPressed)
        {
            if (gameOver || gameWin)
            {
                FlxG.switchState(new MenuState());
                return;
            }

            var mousePos = FlxG.mouse.getScreenPosition();
            var land = hittestLand(mousePos);
            if (land != null)
            {
                if (!land.isLocust())
                {
                    if (land.landType == Field)
                    {
                        addCow(land);
                        level.playCow();
                    }
                    else if (land.landType == Sand)
                    {
                        if (spiceCount >= 5)
                        {
                            spiceCount -= 5;
                            addLight(land);
                            level.playCamp();
                        }
                    }
                    else 
                    {
                        level.playNone();
                    }
                }
                else
                {
                    level.playNone();
                }

                spreadLocust();
                processLocust();

                nextTurn();
                level.updateLabels();
            }
        }


    }
}