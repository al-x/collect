local redis = require "resty.redis"
local redis_host = "redis"

-- are we requesting 'daily' or 'monthly'?
local request_path = ngx.var.request_uri:match("([^%?]+)")
local time_period = request_path:match("/([^_]-)_.*")
local days = (time_period == "monthly" and 30 or 1)

-- get the query string
local request_args, err = ngx.req.get_uri_args(1)

-- the user input should match the ISO 8601 format
-- I haven't handled this error if the user input is malformed (ie. "202201")
local today = os.date("%Y%m%d", os.time())
local isodate = tostring((request_args.d ~= nil and request_args.d or today))

-- build up a list of date buckets, working backwards from the first date
local buckets = {}
for day = 1, days do
    table.insert(buckets, isodate)

    -- decrement to the previous day
    year, month, day = isodate:match("(%d%d%d%d)(%d%d)(%d%d)")
    isodate = os.date("%Y%m%d", os.time{year = year, month = month, day = day - 1})
end

-- set up connection
local r = redis:new()
r:set_timeouts(1000, 1000, 1000) -- 1 sec
local ok, err = r:connect(redis_host, 6379)
if ok then
    ngx.header["Content-type"] = "text/plain"

    -- read the daily or monthly count from redis; table.unpack() was the secret sauce
    local count = assert(r:pfcount(table.unpack(buckets)))

    -- report the count
    ngx.say(count)

    -- clean up redis connection
    r = nil
end
