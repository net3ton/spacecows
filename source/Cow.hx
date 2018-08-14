package;

import flixel.FlxSprite;
import flixel.math.FlxVector;
import flixel.math.FlxRandom;
import flixel.FlxG;

class Cow extends FlxSprite
{
    public function new(?X:Float=0, ?Y:Float=0)
    {
        super(X, Y);
        initTile();
        scale.set(3, 3);
    }

    private function initTile(): Void
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
        animation.play("idle");
    }
}