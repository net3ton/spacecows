package;

import flixel.FlxSprite;
import flixel.math.FlxVector;
import flixel.math.FlxRandom;
import flixel.FlxG;

class Camp extends FlxSprite
{
    public static inline var PRICE = 5;

    public function new(?X:Float=0, ?Y:Float=0)
    {
        super(X, Y);
        initTile();
        scale.set(3, 3);
    }

    private function initTile(): Void
    {
        loadGraphic("assets/images/camp.png", true, 13, 11);
        animation.add("idle", [3, 2, 1], 5, true);
        animation.frameIndex = 0;
    }

    public function nextFrame(): Void
    {
        animation.frameIndex += 1;
    }
}