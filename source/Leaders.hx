package;

import haxe.Json;

#if js
import js.html.WebSocket;
#else
import haxe.Http;
#end

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
    public static inline var SNAME = "spacecows.ga";
    public static inline var SPORT = 610;

    public function new()
    {
    }

    public function sendResults(name: String, scores: Int)
    {
#if js
        var query = "name=" + name + "&score=" + scores;
        var sock = new WebSocket("wss://" + SNAME + ":" + SPORT);
        sock.onopen = function()
        {
            sock.send(query);
        }
        sock.onclose = function(event)
        {
            //event.code
            //event.reason
        }
        sock.onmessage = function(event)
        {
            onResultData(event.data);
        }
        sock.onerror = function(error)
        {
            onResultError(error.message);
        }
#else
        var request = new Http("https://" + SNAME + ":" + SPORT);
        request.addParameter("score", "" + scores);
        request.addParameter("name", name);
        request.addHeader("Content-Type", "text/plain");

        request.onData = onResultData;
        request.onError = onResultError;
        request.cnxTimeout = 1.0;

        request.request();
#end
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