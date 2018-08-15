package;

import flixel.FlxSprite;
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

class HexLand extends FlxSprite
{
    public var landType: LandType = Random;
    public var landPos: FlxVector;

    private var cows: Array<Cow> = [];
    private var cowsPoses: Array<FlxVector> = [
        new FlxVector(-5, -5),
        new FlxVector(-18, -18),
        new FlxVector(-18, 13),
        new FlxVector(13, 13),
        new FlxVector(13, -18),
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
        scale.set(3, 3);

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

    public function hitCowByLocust(): Bool
    {
        if (cows.length > 0)
        {
           var cow = cows.pop();
           cow.kill();
           return true;
        }

        return false;
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
        if (cows.length >= cowsPoses.length)
            return null;

        var posOffset = cowsPoses[cows.length];
        var cow = new Cow(landPos.x + posOffset.x, landPos.y + posOffset.y);
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
}