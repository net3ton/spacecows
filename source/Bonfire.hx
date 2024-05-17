package;

import flixel.FlxSprite;

class Bonfire extends FlxSprite
{
    public static inline var PRICE = 5;

    public function new(x: Float, y: Float)
    {
        super(x, y);

        initTile();
        scale.set(Main.gscale, Main.gscale);
    }

    private function initTile()
    {
        loadGraphic("assets/images/bonfire.png", true, 13, 11);
        animation.add("idle", [3, 2, 1], 5, true);
        animation.frameIndex = 0;
    }

    public function playIdleAnim()
    {
        animation.play("idle", false, false, -1);
    }

    public function nextFrame()
    {
        animation.frameIndex += 1;
    }
}