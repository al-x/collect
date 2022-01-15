local redis = require "resty.redis"

local redis_host = "redis"
local request_args, err = ngx.req.get_uri_args(2)
local ts_unix = os.time()
local day_s = 60^2 * 24

if request_args ~= nil then
    for k, v in pairs(request_args) do
        if k == "cid" then
            cid = v
        elseif k == "d" then
            ts_unix = v
        end
    end
end

-- set up connection
local r = redis:new()
r:set_timeouts(1000, 1000, 1000) -- 1 sec

local ok, err = r:connect(redis_host, 6379)
if ok then

    -- developed from a design I read about here: https://stackoverflow.com/a/63935590

    ---- add to daily count
    bucket = tostring(os.date('%Y%m%d', ts_unix )) .. "_daily"
    assert(r:pfadd(bucket, cid))

    ---- add to monthly counts for 30 days from ts_unix
    for day_offset = 0,30 do
        bucket = tostring(os.date('%Y%m%d', ts_unix + (day_s * day_offset))) .. "_monthly"
        assert(r:pfadd(bucket, cid))
    end

  --  close connection
  r = nil

else

  msg = "redis connection failed: "
  ngx.say(msg .. err)

end
