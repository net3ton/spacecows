package;

import flixel.FlxSprite;
import flixel.math.FlxVector;
import flixel.math.FlxRandom;
import flixel.FlxG;

class Camp extends FlxSprite
{
    public function new(?X:Float=0, ?Y:Float=0)
    {
        super(X, Y);
        initTile();
        scale.set(3, 3);
    }

    private function initTile(): Void
    {
        loadGraphic("assets/images/camp.png", true, 13, 11);
        animation.add("idle", [0, 1], 2, true);
        animation.play("idle");
    }
}