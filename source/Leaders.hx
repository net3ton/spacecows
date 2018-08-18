package;

import haxe.Http;
import haxe.Json;

typedef LeaderItem = {
    var pos: Int;
    var name: String;
    var score: Int;
}

typedef LeadersData = {
    var pos: Int;
    var leaders: Array<LeaderItem>;
    var around: Array<LeaderItem>;
}

class Leaders
{
    public function new()
    {
    }

    public function sendResults(name: String, scores: Int)
    {
        var request = new Http("http://some-url:port/");
        request.addParameter("score", "" + scores);
        request.addParameter("name", name);

        request.onData = onResultData;
        request.onError = onResultError;

        request.request();
    }

    public dynamic function onUpdate(board: LeadersData)
    {
    }

    private function onResultData(data: String)
    {
        var board: LeadersData = Json.parse(data);
        onUpdate(board);
    }

    private function onResultError(message: String)
    {
        var board: LeadersData = { pos: -1, leaders: [], around: [] };
        onUpdate(board);
    }
}