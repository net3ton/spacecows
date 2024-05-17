package;

import flixel.FlxSprite;

class Raft extends FlxSprite
{
    public static inline var PRICE_SPICE = 10;
    public static inline var PRICE_STONE = 5;

    public function new(x: Float, y: Float)
    {
        super(x, y);
        
        initTile();
        scale.set(Main.gscale, Main.gscale);
    }

    private function initTile()
    {
        loadGraphic("assets/images/raft.png", false, 12, 12);
    }
}