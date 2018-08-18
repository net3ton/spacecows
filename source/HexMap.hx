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
        new FlxVector(0, -63),
        new FlxVector(60, -33),
        new FlxVector(60, 30),
        new FlxVector(0, 63),
        new FlxVector(-60, -33),
        new FlxVector(-60, 30),
    ];

    public function new()
	{
        cursorCow = new FlxSprite();
        cursorCow.loadGraphic("assets/images/cursor-cow.png");
        cursorLight = new FlxSprite();
        cursorLight.loadGraphic("assets/images/cursor-camp.png");
        cursorSkip = new FlxSprite();
        cursorSkip.loadGraphic("assets/images/cursor-skip.png");
    }

    public function createPatch(pos: FlxVector, to: FlxState): Void
	{
        for (delta in hexDeltas)
        {
            createIfNeeded(pos.x + delta.x, pos.y + delta.y, to);
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
        var locust: HexLand = null;
        while (locust == null)
        {
            var rand = random.int(0, 17);
            locust = lands[lands.length - rand - 1];
            if (locust.landType == Sea)
                locust = null;
        }

        locust.setLocust(true);
        locusts.push(locust);
    }

    public function expandMap(to: FlxState): Void
    {
        for (hex in lands.copy())
            createPatch(hex.landPos, to);
    }

    private function getLandByPos(x: Float, y: Float, dist: Float): HexLand
    {
        for (land in lands)
        {
            var diff = Math.abs(land.landPos.x - x) + Math.abs(land.landPos.y - y);
            if (diff < dist)
                return land;
        }

        return null;
    }

    private function getLand(x: Float, y: Float): HexLand
    {
        return getLandByPos(x, y, 5);
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
        return getLandByPos(pos.x, pos.y, 40);
    }

    private function getNearbyHexes(hex: HexLand): Array<HexLand>
    {
        var nearby: Array<HexLand> = [];

        for (delta in hexDeltas)
        {
            var sideHex = getLand(hex.landPos.x + delta.x, hex.landPos.y + delta.y);
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

                    var sideRound = getNearbyHexes(sideHex);
                    var can = true;
                    for (rhex in sideRound)
                    {
                        if (rhex.isLight())
                        {
                            can = false;
                            break;
                        }
                    }

                    if (can)
                        next.push(sideHex);
                }
            }
        }

        if (next.length == 0)
            return;

        var random: FlxRandom = new FlxRandom();
        var rand = random.int(0, next.length - 1);
        var locust = next[rand];

        locust.setLocust(true);
        locusts.push(locust);
    }

    private function processLocust(): Void
    {
        for (hex in locusts)
        {
            if (hex.hitCowByLocust())
            {
                //level.addHint(hex.landPos.x, hex.landPos.y, "-1");
            }
        }
    }

    private function nextTurn(): Void
    {
        level.clearHints();

        turn += 1;
        gameWin = true;

        for (land in lands)
        {
            if (land.isLocust())
                gameWin = false;

            if (land.landType == Field)
            {
                var count = land.harvest();
                if (count > 0)
                {
                    level.addHint(land.landPos.x, land.landPos.y - 15, "+" + count);
                    spiceCount += count;
                }
            }

            if (land.landType == Sand)
            {
                land.hitLight();

                //var count = land.hitLight();
                //if (count > 0)
                //{
                //    level.addHint(land.landPos.x, land.landPos.y, "" + count);
                //}
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
            if (gameOver)
            {
                FlxG.switchState(new MenuState());
                return;
            }

            if (gameWin)
            {
                flixel.FlxG.switchState(new WinState().setScore(turn));
                return;
            }

            var mousePos = FlxG.mouse.getScreenPosition();
            var land = hittestLand(mousePos);
            if (land != null)
            {
                if (!land.isLocust())
                {
                    if (land.landType == Field && !land.isCowsFull())
                    {
                        addCow(land);
                        level.playCow();
                    }
                    else if (land.landType == Sand && !land.isLight() && spiceCount >= Camp.PRICE)
                    {
                        spiceCount -= Camp.PRICE;
                        addLight(land);
                        level.playCamp();
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

        updateMouseCursor();
    }

    private function updateMouseCursor(): Void
    {
        FlxG.mouse.useSystemCursor = true;

        var mousePos = FlxG.mouse.getScreenPosition();
        var land = hittestLand(mousePos);
        if (land != null)
        {
            FlxG.mouse.useSystemCursor = false;
            if (land.landType == Field && !land.isLocust() && !land.isCowsFull())
            {
                FlxG.mouse.load(cursorCow.pixels, 4.0, -12, -8);
            }
            else if (land.landType == Sand && spiceCount >= Camp.PRICE && !land.isLight() && !land.isLocust())
            {
                FlxG.mouse.load(cursorLight.pixels, 3.0, -18, -15);
            }
            else 
            {
                FlxG.mouse.load(cursorSkip.pixels, 3.0, -18, -18);
            }
        }
    }
}