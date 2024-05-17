package;

import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;

enum CowType 
{
    Normal;
    Stoned;
}

class Cow extends FlxSprite
{
    private var cowType: CowType;

    public function new(x: Float, y: Float, type: CowType)
    {
        super(x, y);

        initTile(type);
        scale.set(Main.gscale, Main.gscale);
    }

    private function initTile(type: CowType)
    {
        cowType = type;

        if (type == Normal)
        {
            var random: FlxRandom = new FlxRandom();
            var rand = random.int(0, 99);

            if (rand < 33)
                loadGraphic("assets/images/cow01.png", true, 6, 4);
            else if (rand < 66)
                loadGraphic("assets/images/cow02.png", true, 6, 4);
            else
                loadGraphic("assets/images/cow03.png", true, 6, 4);
        }
        else if (type == Stoned)
        {
            loadGraphic("assets/images/cow05.png", true, 6, 4);
        }

        animation.add("idle", [0, 1, 2], 1, true);
        animation.play("idle", false, false, -1);
    }

    override public function destroy()
    {
        kill();
    }

    private static var cowsPool: Array<Cow> = [];

    private static var cowsOffsetsInsideHex: Array<FlxPoint> = [
        new FlxPoint(-2, -2),
        new FlxPoint(-6, -6),
        new FlxPoint(-6, 4),
        new FlxPoint(4, 4),
        new FlxPoint(4, -6),
    ];

    public static inline var MAX_NORMAL = 5;
    public static inline var MAX_STONED = 2;

    public static function create(x: Float, y: Float, type: CowType, posInd: Int): Cow
    {
        if (posInd < 0 || posInd >= cowsOffsetsInsideHex.length)
            return null;

        var posOffset = cowsOffsetsInsideHex[posInd].scaleNew(Main.gscale);

        for (cow in cowsPool)
        {
            if (!cow.alive)
            {
                cow.reset(x + posOffset.x, y + posOffset.y);
                cow.initTile(type);
                return cow;
            }
        }

        var cow = new Cow(x + posOffset.x, y + posOffset.y, type);
        cowsPool.push(cow);
        return cow;
    }
}