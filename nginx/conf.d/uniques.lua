local redis = require "resty.redis"
local redis_host = "redis"

-- get the query string
local request_args, err = ngx.req.get_uri_args(1)

-- are we requesting 'daily' or 'monthly'?
local request_path = ngx.var.request_uri:match("([^%?]+)")
local time_period = request_path:match("/([^_]-)_.*")

-- set up connection
local r = redis:new()
r:set_timeouts(1000, 1000, 1000) -- 1 sec
local ok, err = r:connect(redis_host, 6379)
if ok then

    ngx.header["Content-type"] = "text/plain"

    -- screwy lua ternary for:
    --   "if URI query string d is set, use it; otherwise use today's YYYYMMDD date"
    local ts_iso = (request_args.d ~= nil and request_args.d or os.date("%Y%m%d", os.time()))
    local bucket = tostring(ts_iso) .. '_' .. time_period

    -- read the daily or monthly count from redis
    local count = assert(r:pfcount(bucket, cid))

    -- report the count
    ngx.say(count)

    -- clean up redis connection
    r = nil

end
