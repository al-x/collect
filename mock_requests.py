#!/usr/bin/env python3

from random import randrange
from uuid import uuid4
import datetime
import requests

scheme = 'http://'
host = '0.0.0.0'
port = '8080'
path = '/collect'
cid_uniq_min = 15
cid_uniq_max = 345
cid_hits_min = 1
cid_hits_max = 10
days = 60
now = datetime.datetime.now()
sample_seconds = 60 * 60 * 24 * days
url = scheme + host + ':' + port + path
params = []

# generate a random number of client IDs
cid_list = [ str(uuid4()) for i in range(cid_uniq_min, randrange(cid_uniq_min, cid_uniq_max)) ]

# per client ID, generate a random number of hits offset at random over the sampling period
for cid in cid_list:
    for i in range(1, randrange(cid_hits_min, cid_hits_max)):
        ts_offset = abs(datetime.timedelta(seconds=randrange(-sample_seconds, sample_seconds)))
        params.append( { "cid": cid, "d": int(datetime.datetime.timestamp(now - ts_offset)) } )

# sort in place by timestamp
params.sort(key=lambda k : k['d'])

# make the HTTP requests
for p in params:
    requests.get(url, params=p)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4 :
