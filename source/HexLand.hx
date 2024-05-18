package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;

enum LandType 
{
    Random;
    Base;

    Sand;
    Field;
    Water;
    Stone;
}

enum LandNeighbour
{
    Top;
    RightTop;
    RightBottom;
    Bottom;
    LeftBottom;
    LeftTop;
}

class HexLand extends FlxSprite
{
    public var landType: LandType = Random;
    public var landPos: FlxPoint;

    // hex resources
    private var spice = 20;
    private var stone = 5;

    private var cows: Array<Cow> = [];
    private var raft: Raft;
    private var bonfire: Bonfire;
    private var light = 0;
    private var locust = false;

    public function new(x: Float, y: Float, type: LandType)
    {
        super(x, y);

        initTile(type);
        scale.set(Main.gscale, Main.gscale);

        antialiasing = false;
        //pixelPerfectRender = true;

        landPos = new FlxPoint(x, y);
        setPosition(x - width/2, y - height/2);
    }

    private function initTile(type: LandType)
    {
        removeAllCows();

        if (type == Random)
            landType = getRandomType();
        else
            landType = type;

        if (landType == Base)
        {
            loadGraphic("assets/images/hexbase.png", false, 32, 32);
        }
        else if (landType == Sand)
        {
            loadGraphic("assets/images/hex01.png", true, 32, 32);
            var random: FlxRandom = new FlxRandom();
            animation.frameIndex = random.int(0, animation.numFrames - 1);
            flipX = random.int(0, 99) >= 50;
        }
        else if (landType == Field)
        {
            loadGraphic("assets/images/hex04.png", true, 32, 32);
            var random: FlxRandom = new FlxRandom();
            animation.frameIndex = random.int(0, animation.numFrames - 1);
            flipX = random.int(0, 99) >= 50;
        }
        else if (landType == Water)
        {
            loadGraphic("assets/images/hex03.png", true, 32, 32);
            animation.add("idle", [0, 1], 2, true);
            animation.play("idle");
        }
        else if (landType == Stone)
        {
            loadGraphic("assets/images/hex05.png", false, 32, 32);
        }
    }

    private function removeAllCows()
    {
        for (cow in cows)
            cow.kill();
        cows = [];
    }

    private function getRandomType(): LandType
    {
        var random: FlxRandom = new FlxRandom();
        var rand = random.int(0, 99);

        if (rand < 10)
            return Sand;
        if (rand < 20)
            return Water;
        if (rand < 30)
            return Stone;

        return Field;
    }

    public function getNeighbourPos(pos: LandNeighbour): FlxPoint
    {
        if (pos == Top)
            return landPos.addNew(HexMap.hexDeltas[0]);
        if (pos == RightTop)
            return landPos.addNew(HexMap.hexDeltas[1]);
        if (pos == RightBottom)
            return landPos.addNew(HexMap.hexDeltas[2]);
        if (pos == Bottom)
            return landPos.addNew(HexMap.hexDeltas[3]);
        if (pos == LeftBottom)
            return landPos.addNew(HexMap.hexDeltas[5]);
        if (pos == LeftTop)
            return landPos.addNew(HexMap.hexDeltas[4]);

        return new FlxPoint(landPos.x, landPos.y);
    }

    public function harvestSpice(): Int
    {
        if (landType == Field && cows.length > 0)
        {
            var count = cows.length;
            if (count > spice)
                count = spice;

            spice -= count;

            if (spice <= 0)
            {
                initTile(Sand);
            }

            return count;
        }

        return 0;
    }

    public function harvestStone(): Int
    {
        if (landType == Stone && cows.length > 0)
        {
            var count = cows.length;
            if (count > stone)
                count = stone;

            stone -= count;

            if (stone <= 0)
            {
                initTile(Field);
            }

            return count;
        }
        
        return 0;
    }

    public function setLocust(on: Bool)
    {
        locust = on;

        if (on)
            alpha = 0.5;
        else
            alpha = 1;
    }

    public function isLocust(): Bool
    {
        return locust;
    }

    public function hasFire(): Bool
    {
        return light > 0;
    }

    public function hasRaft(): Bool
    {
        return raft != null;
    }

    public function hitCowByLocust()
    {
        if (cows.length > 0)
        {
           var cow = cows.pop();
           cow.kill();
        }
    }

    public function decreaseLight()
    {
        if (light > 0)
        {
            bonfire.nextFrame();

            light -= 1;
            if (light <= 0)
            {
                bonfire.kill();
                bonfire = null;

                //initTile(Sea);
            }
        }
    }

    public function addCow(to: FlxState): Bool
    {
        if (isCowsFull())
            return false;

        var nextCowInd = cows.length;
        var cow = null;

        if (landType == Field)
            cow = Cow.create(landPos.x, landPos.y, Normal, nextCowInd);
        else if (landType == Stone)
            cow = Cow.create(landPos.x, landPos.y, Stoned, nextCowInd);

        if (cow != null)
        {
            cows.push(cow);
            to.add(cow);
        }

        return true;
    }

    public function isCowsFull(): Bool
    {
        if (landType == Field)
            return cows.length >= Cow.MAX_NORMAL;
        if (landType == Stone)
            return cows.length >= Cow.MAX_STONED;

        return true;
    }

    public function createBonfire(to: FlxState): Bool
    {
        if (bonfire == null)
        {
            light = 5;
            bonfire = new Bonfire(landPos.x - 8, landPos.y - 8);
            to.add(bonfire);
            return true;
        }

        return false;
    }

    public function createRaft(to: FlxState): Bool
    {
        if (raft == null)
        {
            raft = new Raft(landPos.x - 8, landPos.y - 8);
            to.add(raft);
            return true;
        }

        return false;
    }

    public function addCows(to: FlxState, count: Int): HexLand
    {
        for (i in 0...count)
        {
            addCow(to);
        }

        return this;
    }

    public function addBonefireAndPlayAnim(to: FlxState)
    {
        createBonfire(to);
        if (bonfire != null)
            bonfire.playIdleAnim();
    }
}