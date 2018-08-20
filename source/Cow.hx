package;

import flixel.FlxSprite;
import flixel.math.FlxRandom;

class Cow extends FlxSprite
{
    public function new(x: Float, y: Float)
    {
        super(x, y);
        initTile();
        scale.set(3, 3);
    }

    private function initTile()
    {
        var random: FlxRandom = new FlxRandom();
        var rand = random.int(0, 99);

        if (rand < 33)
            loadGraphic(AssetPaths.cow01__png, true, 6, 4);
        else if (rand < 66)
            loadGraphic(AssetPaths.cow02__png, true, 6, 4);
        else
            loadGraphic(AssetPaths.cow03__png, true, 6, 4);

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