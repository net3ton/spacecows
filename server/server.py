import re
import json
import redis
from gevent.pywsgi import WSGIServer

REG_INPUT = re.compile("name=([A-z0-9\-\_\.]*)&score=([0-9]*)")
COUNT_LEADERS = 15

REDIS = redis.StrictRedis(host='localhost', port=6379, db=0)
REDIS_KEY = "spacecows"

print("space cows server...")

def make_pkey(pid, name):
    return "%08X:%s" % (pid, name)

def get_name_from_pkey(pkey):
    ind = pkey.find(":")
    if ind >= 0:
        return pkey[ind+1:]
    return pkey

def prepare_result(name, score):
    pid = REDIS.zcard(REDIS_KEY)
    pkey = make_pkey(pid, name)

    REDIS.zadd(REDIS_KEY, score, pkey)
    REDIS.save()

    leaders = REDIS.zrange(REDIS_KEY, 0, COUNT_LEADERS-1, withscores=True)
    around = []

    pos = REDIS.zrank(REDIS_KEY, pkey)
    if pos >= COUNT_LEADERS:
        around = REDIS.zrange(REDIS_KEY, pos-1, pos+1, withscores=True)

    # prepare
    data = {}
    data['pos'] = pos

    itemsLeaders = []
    for ind, (itemkey, itemscore) in enumerate(leaders):
        itemdata = {}
        itemdata['pos'] = ind
        itemdata['name'] = get_name_from_pkey(itemkey)
        itemdata['score'] = itemscore
        itemsLeaders.append(itemdata)

    itemsAround = []
    if around:
        pind = -1
        for ind, (itemkey, itemscore) in enumerate(around):
            if itemkey == pkey:
                pind = ind
                break

        if pind == -1:
            pind = len(around)
            around.append((pkey, score))

        for ind, (itemkey, itemscore) in enumerate(around):
            itemdata = {}
            itemdata['pos'] = pos + (ind - pind)
            itemdata['name'] = get_name_from_pkey(itemkey)
            itemdata['score'] = itemscore
            itemsAround.append(itemdata)

    data['leaders'] = itemsLeaders
    data['around'] = itemsAround
    return data


def application(env, start_response):
    if 'QUERY_STRING' in env:
        pinfo = REG_INPUT.search(env['QUERY_STRING'])
        if pinfo:
            pname, pscore = pinfo.groups()
            pscoreInt = int(pscore)

            if len(pname) > 0 and pscoreInt > 0:
                result = prepare_result(pname, pscoreInt)
                start_response('200 OK', [('Content-Type', 'text/html')])
                return json.dumps(result)

    empty = {}
    empty['pos'] = -1
    empty['leaders'] = []
    empty['around'] = []

    start_response('404 Not Found', [('Content-Type', 'text/html')])
    return json.dumps(empty)

WSGIServer(('0.0.0.0', 610), application).serve_forever()
