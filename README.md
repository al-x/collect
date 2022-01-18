# Simple Analytics Service

## Challenge

Write a simple analytics service that accepts analytics reports as
GET requests of the form:

```
/collect?cid=<UUID>
```

where cid is a unique client ID. The response should be 200 OK with
an empty body.

The service should track daily and monthly active users (unique
cid's seen) and support queries of the form:

```
/daily_uniques?d=<ISO 8601 date>
```

which should return the number of unique users seen for the given GMT day;

and of the form:

```
/monthly_uniques?d=<ISO 8601 date>
```

which should return the number of unique users seen in the month
prior to and including the given GMT day. 

For testing purposes, the collect endpoint should accept an optional
query parameter `d=<UNIX timestamp>`, which can be used to override
the timestamp associated with a given analytics report.

Design for high performance on a single machine with low operational cost.

The system should be robust to restarts, but it is not necessary
to retain data or support queries for dates older than 60 days.
Unique user counts may be approximate rather than precise if you
can reason about accuracy. 


## Solution
* orchestration: docker-compose
* webserver: nginx with lua integration (OpenResty)
* data store: redis
* unique visitor counting strategy: [HyperLogLog](https://en.wikipedia.org/wiki/HyperLogLog)
* testing: mock requests with python

## Usage
A self-documenting Makefile is available for convenience.

#### Display all possible make "target" commands
```
make help
```

#### Start the server containers
```
make compose-up
```

#### Generate test client traffic
```
make mock-requests
```

#### Clean up containers
```
make compose-down
```

#### Clear out redis data
```
make uniques-clean
```

#### Check today's uniques
```
make uniques-daily        
```

#### Check specific date's uniques
```
make uniques-daily-<YYYYMMDD>
```

example:
```
uniques-daily-20211225
```

#### Check last 30 days uniques
```
make uniques-monthly
```

#### Check 30 days before a specific date
```
make uniques-monthly-<YYYYMMDD>
```

example:
```
uniques-monthly-20211225
```
