local redis = require "resty.redis"
local request_args, err = ngx.req.get_uri_args(2)

if request_args ~= nil and request_args.cid ~= nil then

    -- it would be a good idea to do input validation on 'cid' and 'd'
    local cid = request_args.cid
    local today = os.time()
    local ts_unix = (request_args.d ~= nil and request_args.d or today)
    local bucket = tostring(os.date("%Y%m%d", ts_unix))

    -- set up connection
    local redis_host = "redis"
    local r = redis:new()
    r:set_timeouts(1000, 1000, 1000) -- 1 second
    local ok, err = r:connect(redis_host, 6379)

    if ok then
        assert(r:pfadd(bucket, cid))
        r = nil --  close connection
    else
        msg = "redis connection failed: "
        ngx.log(ngx.STDERR, msg .. err)
    end
else
    msg = "no client ID seen"
    ngx.log(ngx.STDERR, msg)
end
