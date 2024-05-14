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

    private var cows: Array<Cow> = [];
    private var cowsPoses: Array<FlxPoint> = [
        new FlxPoint(-2, -2),
        new FlxPoint(-6, -6),
        new FlxPoint(-6, 4),
        new FlxPoint(4, 4),
        new FlxPoint(4, -6),
    ];
    private var spice = 20;

    private var bonfire: Bonfire;
    private var light = 0;
    private var locust = false;

    public function new(x:Float, y:Float, type: LandType)
    {
        super(x, y);

        if (type == Random)
            landType = getRandomType();
        else
            landType = type;

        initTile();
        scale.set(Main.gscale, Main.gscale);

        antialiasing = false;
        //pixelPerfectRender = true;

        landPos = new FlxPoint(x, y);
        setPosition(x - width/2, y - height/2);
    }

    private function initTile()
    {
        var random: FlxRandom = new FlxRandom();

        if (landType == Base)
        {
            loadGraphic("assets/images/hexbase.png", false, 32, 32);
            return;
        }

        if (landType == Sand)
        {
            loadGraphic("assets/images/hex01.png", true, 32, 32);
            animation.frameIndex = random.int(0, animation.numFrames - 1);
            flipX = random.int(0, 99) >= 50;
            return;
        }

        if (landType == Field)
        {
            loadGraphic("assets/images/hex04.png", true, 32, 32);
            animation.frameIndex = random.int(0, animation.numFrames - 1);
            flipX = random.int(0, 99) >= 50;
            return;
        }

        if (landType == Water)
        {
            loadGraphic("assets/images/hex03.png", true, 32, 32);
            animation.add("idle", [0, 1], 2, true);
            animation.play("idle");
            return;
        }
    }

    private function getRandomType(): LandType
    {
        var random: FlxRandom = new FlxRandom();
        var rand = random.int(0, 99);

        if (rand < 10)
            return Sand;
        if (rand < 20)
            return Water;

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

    public function harvest(): Int
    {
        var res = cows.length;
        if (res > spice)
            res = spice;

        spice -= res;

        if (spice <= 0)
        {
            landType = Sand;
            initTile();

            for (cow in cows)
                cow.kill();
            cows = [];
        }

        return res;
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

    public function isLight(): Bool
    {
        return light > 0;
    }

    public function hitCowByLocust(): Cow
    {
        if (cows.length > 0)
        {
           var cow = cows.pop();
           cow.kill();
           return cow;
        }

        return null;
    }

    public function hitLight(): Int
    {
        if (light > 0)
        {
            bonfire.nextFrame();
            light -= 1;
            if (light <= 0)
            {
                bonfire.kill();
                bonfire = null;

                //landType = Sea;
                //initTile();
            }

            return light;
        }

        return -1;
    }

    public function createCow(): Cow
    {
        if (isCowsFull())
            return null;

        var posOffset = cowsPoses[cows.length].scaleNew(Main.gscale);
        var cow = Cow.create(landPos.x + posOffset.x, landPos.y + posOffset.y);
        cows.push(cow);

        return cow;
    }

    public function isCowsFull(): Bool
    {
        return cows.length >= cowsPoses.length;
    }

    public function createBonfire(): Bonfire
    {
        if (bonfire == null)
        {
            light = 5;
            bonfire = new Bonfire(landPos.x - 8, landPos.y - 8);
            return bonfire;
        }

        return null;
    }

    public function addBonfire(to: FlxState): HexLand
    {
        var fire = createBonfire();
        if (fire != null)
        {
            fire.animation.play("idle", false, false, -1);
            to.add(fire);
        }

        return this;
    }

    public function addCows(to: FlxState, count: Int): HexLand
    {
        for (i in 0...count)
        {
            var cow = createCow();
            if (cow != null)
                to.add(cow);
        }

        return this;
    }
}