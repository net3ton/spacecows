package;

import flixel.FlxSprite;
import flixel.math.FlxRandom;

class Cow extends FlxSprite
{
    public function new(x: Float, y: Float)
    {
        super(x, y);
        initTile();
        scale.set(Main.gscale, Main.gscale);
    }

    private function initTile()
    {
        var random: FlxRandom = new FlxRandom();
        var rand = random.int(0, 99);

        if (rand < 33)
            loadGraphic("assets/images/cow01.png", true, 6, 4);
        else if (rand < 66)
            loadGraphic("assets/images/cow02.png", true, 6, 4);
        else
            loadGraphic("assets/images/cow03.png", true, 6, 4);

        animation.add("idle", [0, 1, 2], 1, true);
        animation.play("idle", false, false, -1);
    }

    override public function destroy()
    {
        kill();
    }

    public static var cowsPool: Array<Cow> = [];

    public static function create(x: Float, y: Float): Cow
    {
        for (cow in cowsPool)
        {
            if (!cow.alive)
            {
                cow.reset(x, y);
                return cow;
            }
        }

        var cow = new Cow(x, y);
        cowsPool.push(cow);
        return cow;
    }
}