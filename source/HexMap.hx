package;

import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;

class HexMap
{
    public var lands: Array<HexLand> = [];

    public static var hexDeltas: Array<FlxPoint> = [
        new FlxPoint(0, -22).scale(Main.gscale),
        new FlxPoint(20, -11).scale(Main.gscale),
        new FlxPoint(20, 11).scale(Main.gscale),
        new FlxPoint(0, 22).scale(Main.gscale),
        new FlxPoint(-20, -11).scale(Main.gscale),
        new FlxPoint(-20, 11).scale(Main.gscale)
    ];

    private var state: FlxState;

    public function new(to: FlxState)
	{
        state = to;
    }

    public function createLandsAround(x: Float, y: Float)
	{
        for (delta in hexDeltas)
        {
            createLandIfNeeded(x + delta.x, y + delta.y, Random);
        }
	}

    public function expandMap()
    {
        for (hex in lands.copy())
            createLandsAround(hex.landPos.x, hex.landPos.y);
    }

    public function createBaseHex(x: Float, y: Float)
    {
        createLandIfNeeded(x, y, Base);
    }

    private function getLandByPos(x: Float, y: Float, dist: Float): HexLand
    {
        for (land in lands)
        {
            var diff = Math.abs(land.landPos.x - x) + Math.abs(land.landPos.y - y);
            if (diff < dist)
                return land;
        }

        return null;
    }

    private function getLand(x: Float, y: Float): HexLand
    {
        return getLandByPos(x, y, 10);
    }

    private function createLandIfNeeded(x: Float, y: Float, type: HexLand.LandType)
    {
        if (getLand(x, y) == null)
        {
            //trace("hex in:" + x + ", " + y);
            var hex = new HexLand(x, y, type);

            lands.push(hex);
            state.add(hex);
        }
    }

    public function hittestLand(pos: FlxPoint): HexLand
    {
        return getLandByPos(pos.x, pos.y, 40);
    }

    public function getNearbyHexes(hex: HexLand): Array<HexLand>
    {
        var nearby: Array<HexLand> = [];

        for (delta in hexDeltas)
        {
            var sideHex = getLand(hex.landPos.x + delta.x, hex.landPos.y + delta.y);
            if (sideHex != null)
                nearby.push(sideHex);
        }

        return nearby;
    }
}