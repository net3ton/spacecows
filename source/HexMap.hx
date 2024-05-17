package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;

class HexMap
{
    public var turn = 0;
    public var spiceCount = 0;
    public var stoneCount = 0;

    private var gameOver = false;
    private var gameWin = false;

    private var lands: Array<HexLand> = [];
    private var locusts: Array<HexLand> = [];
    private var level: StateGame;

    private var cursorCow: FlxSprite;
    private var cursorStone: FlxSprite;
    private var cursorFire: FlxSprite;
    private var cursorSkip: FlxSprite;

    public static var hexDeltas: Array<FlxPoint> = [
        new FlxPoint(0, -22).scale(Main.gscale),
        new FlxPoint(20, -11).scale(Main.gscale),
        new FlxPoint(20, 11).scale(Main.gscale),
        new FlxPoint(0, 22).scale(Main.gscale),
        new FlxPoint(-20, -11).scale(Main.gscale),
        new FlxPoint(-20, 11).scale(Main.gscale)
    ];


    public function new()
	{
        cursorCow = new FlxSprite();
        cursorCow.loadGraphic("assets/images/cursor-cow.png");
        cursorStone = new FlxSprite();
        cursorStone.loadGraphic("assets/images/cursor-stone.png");
        cursorFire = new FlxSprite();
        cursorFire.loadGraphic("assets/images/cursor-fire.png");
        cursorSkip = new FlxSprite();
        cursorSkip.loadGraphic("assets/images/cursor-skip.png");
    }

    public function getLands(): Array<HexLand>
    {
        return lands;
    }

    public function createLandsAround(x: Float, y: Float, to: FlxState)
	{
        for (delta in hexDeltas)
        {
            createLandIfNeeded(x + delta.x, y + delta.y, to);
        }
	}

    public function expandMap(to: FlxState)
    {
        for (hex in lands.copy())
            createLandsAround(hex.landPos.x, hex.landPos.y, to);
    }

    public function createMap(x: Float, y: Float, to: StateGame)
    {
        level = to;

        var baseHex = new HexLand(x, y, Base);
        lands.push(baseHex);
		level.add(baseHex);

        createLandsAround(x, y, level);
        expandMap(level);
        expandMap(level);

        //trace("hex count:" + lands.length);

        /// init enemy
        var random: FlxRandom = new FlxRandom();
        var locust: HexLand = null;
        while (locust == null)
        {
            var rand = random.int(0, 17);
            locust = lands[lands.length - rand - 1];
            if (locust.landType == Water)
                locust = null;
        }

        locust.setLocust(true);
        locusts.push(locust);
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
        return getLandByPos(x, y, 10);
    }

    private function createLandIfNeeded(x: Float, y: Float, to: FlxState)
    {
        if (getLand(x, y) == null)
        {
            //trace("hex in:" + x + ", " + y);
            var hex = new HexLand(x, y, Random);

            lands.push(hex);
            to.add(hex);
        }
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

    private function spreadLocust()
    {
        var next: Array<HexLand> = [];

        for (hex in locusts)
        {
            var nears = getNearbyHexes(hex);
            for (sideHex in nears)
            {
                if (!sideHex.isLocust() && next.indexOf(sideHex) < 0)
                {
                    if (sideHex.landType == Water)
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

    private function processLocust()
    {
        for (hex in locusts)
        {
            var cow = hex.hitCowByLocust();
            if (cow != null)
            {
                level.remove(cow);
                //level.addHint(hex.landPos.x, hex.landPos.y, "-1");
            }
        }
    }

    private function nextTurn()
    {
        level.clearHints();

        turn += 1;
        gameWin = true;

        for (land in lands)
        {
            if (land.isLocust())
                gameWin = false;
            
            var addSpice = land.harvestSpice();
            if (addSpice > 0)
            {
                level.showHint(land.landPos.x, land.landPos.y - 15, "+" + addSpice);
                spiceCount += addSpice;
            }

            var addStone = land.harvestStone();
            if (addStone > 0)
            {
                level.showHint(land.landPos.x, land.landPos.y - 15, "+" + addStone);
                stoneCount += addStone;
            }
            
            land.decreaseLight();
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

    private function addLight(land: HexLand): Bool
    {
        if (spiceCount < Bonfire.PRICE)
            return false;

        var fire = land.createBonfire();

        if (fire == null)
            return false;

        spiceCount -= Bonfire.PRICE;

        level.add(fire);

        var nears = getNearbyHexes(land);
        for (nearHex in nears)
        {
            if (nearHex.isLocust())
            {
                locusts.remove(nearHex);
                nearHex.setLocust(false);
            }
        }

        return true;
    }

    private function addRaft(land: HexLand): Bool
    {
        if (spiceCount < Raft.PRICE_SPICE || stoneCount < Raft.PRICE_STONE)
            return false;

        var raft = land.createRaft();

        if (raft == null)
            return false;

        spiceCount -= Raft.PRICE_SPICE;
        stoneCount -= Raft.PRICE_STONE;

        level.add(raft);
        return true;
    }

    private function clickOnLand(land: HexLand)
    {
        if (land.isLocust())
        {
            level.playNone();
            return;
        }

        if (land.landType == Field || land.landType == Stone)
        {
            var cow = land.createCow();
            if (cow != null)
            {
                level.add(cow);
                level.playCow();
                return;
            }
        }

        if (land.landType == Sand)
        {
            if (addLight(land))
            {
                level.playFire();
                return;
            }
        }

        if (land.landType == Water)
        {
            if (addRaft(land))
            {
                level.playFire();
                return;
            }

            if (land.isRaft() && addLight(land))
            {
                level.playFire();
                return;
            }
        }

        level.playNone();
    }

    public function update(elapsed: Float)
    {
#if mobile
        if (FlxG.touches.justReleased().length > 0)
#else
        if (FlxG.mouse.justPressed)
#end
        {
            if (gameOver)
            {
                FlxG.switchState(new StateStart());
                return;
            }

            if (gameWin)
            {
                FlxG.switchState(new StateWin().setScore(turn));
                return;
            }

#if mobile
            var mousePos = FlxG.touches.justReleased()[0].justPressedPosition;
#else
            var mousePos = FlxG.mouse.getScreenPosition();
#end
            var hexUnderMouse = hittestLand(mousePos);
            if (hexUnderMouse != null)
            {
                clickOnLand(hexUnderMouse);

                spreadLocust();
                processLocust();

                nextTurn();
                level.updateLabels();
            }
        }

        updateMouseCursor();
    }

    private function updateMouseCursor()
    {
#if !mobile
        var mousePos = FlxG.mouse.getScreenPosition();
        var hexUnderMouse = hittestLand(mousePos);

        if (hexUnderMouse == null)
        {
            FlxG.mouse.useSystemCursor = true;
            return;
        }
    
        FlxG.mouse.useSystemCursor = false;

        if (hexUnderMouse.isLocust())
        {
            FlxG.mouse.load(cursorSkip.pixels, 3.0, -18, -18);
        }
        else if (hexUnderMouse.landType == Field && !hexUnderMouse.isCowsFull())
        {
            FlxG.mouse.load(cursorCow.pixels, 4.0, -12, -8);
        }
        else if (hexUnderMouse.landType == Stone && !hexUnderMouse.isCowsFull())
        {
            FlxG.mouse.load(cursorStone.pixels, 4.0, -12, -8);
        }
        else if (hexUnderMouse.landType == Sand && !hexUnderMouse.isLight() && spiceCount >= Bonfire.PRICE)
        {
            FlxG.mouse.load(cursorFire.pixels, 3.0, -18, -15);
        }
        else
        {
            FlxG.mouse.load(cursorSkip.pixels, 3.0, -18, -18);
        }
#end
    }
}