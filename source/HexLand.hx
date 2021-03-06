package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxVector;
import flixel.math.FlxRandom;

enum LandType 
{
    Random;
    Base;

    Sand;
    Field;
    Sea;
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
    public var landPos: FlxVector;

    private var cows: Array<Cow> = [];
    private var cowsPoses: Array<FlxVector> = [
        new FlxVector(-2, -2),
        new FlxVector(-6, -6),
        new FlxVector(-6, 4),
        new FlxVector(4, 4),
        new FlxVector(4, -6),
    ];
    private var spice = 20;

    private var camp: Camp;
    private var light = 0;
    private var locust = false;

    public function new(X:Float, Y:Float, type: LandType)
    {
        super(X, Y);

        if (type == Random)
            landType = getRandomType();
        else
            landType = type;

        initTile();
        scale.set(Main.gscale, Main.gscale);

        antialiasing = false;
        //pixelPerfectRender = true;

        landPos = new FlxVector(X, Y);
        setPosition(X - width/2, Y - height/2);
    }

    private function initTile(): Void
    {
        if (landType == Base)
        {
            loadGraphic("assets/images/hexbase.png", false);
            return;
        }

        if (landType == Sand)
        {
            loadGraphic("assets/images/hex01.png", false);
            return;
        }

        if (landType == Field)
        {
            loadGraphic("assets/images/hex04.png", false);
            return;
        }

        if (landType == Sea)
        {
            loadGraphic("assets/images/hex03.png", true, 32, 32);
            //setFacingFlip(flixel.FlxObject.LEFT, false, false);
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
            return Sea;

        return Field;
    }

    public function getNeighbourPos(pos: LandNeighbour): FlxVector
    {
        if (pos == Top)
            return landPos.addPoint(HexMap.hexDeltas[0]);
        if (pos == RightTop)
            return landPos.addPoint(HexMap.hexDeltas[1]);
        if (pos == RightBottom)
            return landPos.addPoint(HexMap.hexDeltas[2]);
        if (pos == Bottom)
            return landPos.addPoint(HexMap.hexDeltas[3]);
        if (pos == LeftBottom)
            return landPos.addPoint(HexMap.hexDeltas[5]);
        if (pos == LeftTop)
            return landPos.addPoint(HexMap.hexDeltas[4]);

        return new FlxVector(landPos.x, landPos.y);
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

    public function setLocust(on: Bool): Void 
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
            camp.nextFrame();
            light -= 1;
            if (light <= 0)
            {
                camp.kill();
                camp = null;

                //landType = Sea;
                //initTile();
            }

            return light;
        }

        return -1;
    }

    public function addCow(): Cow
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

    public function addLight(): Camp
    {
        if (camp == null)
        {
            light = 5;
            camp = new Camp(landPos.x - 8, landPos.y - 8);
            return camp;
        }

        return null;
    }

    public function addFire(to: FlxState): HexLand
    {
        var fire = addLight();
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
            var cow = addCow();
            if (cow != null)
                to.add(cow);
        }

        return this;
    }
}