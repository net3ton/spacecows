package;

import flixel.FlxG;
import flixel.math.FlxRandom;

class HexGame
{
    public var turn = 0;
    public var spiceCount = 0;
    public var stoneCount = 0;

    private var gameOver = false;
    private var gameWin = false;

    private var state: StateGame;
    private var map: HexMap;
    private var hexBase: HexLand;

    private var locusts: Array<HexLand> = [];

    public function new(x: Float, y: Float, to: StateGame)
    {
        state = to;

        map = new HexMap(to);
        hexBase = map.createBaseHex(x, y);
        map.expandMap();
        map.expandMap();
        map.expandMap();

        /// init enemy
        var random: FlxRandom = new FlxRandom();
        var locust: HexLand = null;
        while (locust == null)
        {
            var rand = random.int(0, 17);
            locust = map.lands[map.lands.length - rand - 1];
            if (locust.landType == Water)
                locust = null;
        }

        locust.setLocust(true);
        locusts.push(locust);
    }

    private function spreadLocust()
    {
        var next: Array<HexLand> = [];

        for (hex in locusts)
        {
            var nears = map.getNearbyHexes(hex);
            for (sideHex in nears)
            {
                if (!sideHex.isLocust() && next.indexOf(sideHex) < 0)
                {
                    if (sideHex.landType == Water)
                        continue;

                    var sideRound = map.getNearbyHexes(sideHex);
                    var can = true;
                    for (rhex in sideRound)
                    {
                        if (rhex.hasFire())
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
            hex.hitCowByLocust();
        }
    }

    private function nextTurn()
    {
        state.clearHints();

        turn += 1;
        gameWin = true;

        for (land in map.lands)
        {
            if (land.isLocust())
                gameWin = false;
            
            var addSpice = land.harvestSpice();
            if (addSpice > 0)
            {
                state.showHint(land.landPos.x, land.landPos.y - 15, "+" + addSpice);
                spiceCount += addSpice;
            }

            var addStone = land.harvestStone();
            if (addStone > 0)
            {
                state.showHint(land.landPos.x, land.landPos.y - 15, "+" + addStone);
                stoneCount += addStone;
            }
            
            land.decreaseLight();
        }

        if (hexBase.isLocust())
        {
            gameOver = true;
            state.showGameOver();
        }

        if (gameWin)
        {
            state.showGameWin();
        }
    }

    private function tryAddLight(land: HexLand): Bool
    {
        if (spiceCount < Bonfire.PRICE)
            return false;

        if (!land.createBonfire(state))
            return false;

        spiceCount -= Bonfire.PRICE;

        var nears = map.getNearbyHexes(land);
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

    private function tryAddRaft(land: HexLand): Bool
    {
        if (spiceCount < Raft.PRICE_SPICE || stoneCount < Raft.PRICE_STONE)
            return false;

        if (!land.createRaft(state))
            return false;

        spiceCount -= Raft.PRICE_SPICE;
        stoneCount -= Raft.PRICE_STONE;
        return true;
    }

    private function clickOnLand(land: HexLand)
    {
        if (land.isLocust())
        {
            state.playNone();
            return;
        }

        if (land.landType == Field || land.landType == Stone)
        {
            if (land.addCow(state))
            {
                state.playCow();
                return;
            }
        }

        if (land.landType == Sand)
        {
            if (tryAddLight(land))
            {
                state.playFire();
                return;
            }
        }

        if (land.landType == Water)
        {
            if (tryAddRaft(land))
            {
                state.playFire();
                return;
            }

            if (land.hasRaft() && tryAddLight(land))
            {
                state.playFire();
                return;
            }
        }

        state.playNone();
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
            var hexUnderMouse = map.hittestLand(mousePos);
            if (hexUnderMouse != null)
            {
                clickOnLand(hexUnderMouse);

                spreadLocust();
                processLocust();

                nextTurn();
                state.updateLabels();
            }
        }

        updateMouseCursor();
    }

    private function updateMouseCursor()
    {
#if !mobile
        var mousePos = FlxG.mouse.getScreenPosition();
        var hexUnderMouse = map.hittestLand(mousePos);

        if (hexUnderMouse == null)
        {
            FlxG.mouse.useSystemCursor = true;
            return;
        }

        FlxG.mouse.useSystemCursor = false;

        if (hexUnderMouse.isLocust())
        {
            state.setMouseCursorSkip();
            return;
        }

        if (!hexUnderMouse.isCowsFull())
        {
            if (hexUnderMouse.landType == Field)
            {
                state.setMouseCursorCow();
                return;
            }

            if (hexUnderMouse.landType == Stone)
            {
                state.setMouseCursorStone();
                return;
            }
        }

        if (!hexUnderMouse.hasFire())
        {
            if (hexUnderMouse.landType == Sand || (hexUnderMouse.landType == Water && hexUnderMouse.hasRaft()))
            {
                if (spiceCount >= Bonfire.PRICE)
                {
                    state.setMouseCursorBonefire();
                    return;
                }
            }
        }

        if (hexUnderMouse.landType == Water && !hexUnderMouse.hasRaft())
        {
            if (spiceCount >= Raft.PRICE_SPICE && stoneCount >= Raft.PRICE_STONE)
            {
                state.setMouseCursorRaft();
                return;
            }
        }

        state.setMouseCursorSkip();
#end
    }
}