-- https://moonbingbing.gitbooks.io/openresty-best-practices/content/redis/auth_connect.html
local redis =  require "resty.redis"
local red = redis:new()

red:set_timeout(1000) -- 1 sec

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local count, err = red:get_reused_times()
ngx.log(ngx.ERR, "get_reused_times: " .. count)

local ok, err = red:set("dog", "an animal")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

local res, err = red:get("dog")
if not res then
    ngx.say("failed to get dog: ", err)
    return
end

if res == ngx.null then
    ngx.say("dog not found.")
    return
end

ngx.say("dog: ", res)

-- 在 code_cache off 的情况下，连接池是不生效的（此时 LuaJIT 的 VM 每请求都会重新初始化了）
local ok, err = red:set_keepalive(10000, 1)
if not ok then
    ngx.say("failed to set keepalive ", err)
    return
end
