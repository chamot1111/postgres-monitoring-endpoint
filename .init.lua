local pgmoon = require("pgmoon")

HidePath('/usr/share/zoneinfo/')
HidePath('/usr/share/ssl/')
HidePath('/tmpl/')
envs = unix.environ()

local databases = {}

local pgSecret

for _, value in ipairs(envs) do
    local key, val = value:match("^([^=]+)=(.*)$")
    if key == "PGM_SECRET" then
        pgSecret = val
    else
        local configKey, dbName = key:match("^PGM_DB_(%w+)_(.+)$")
        if dbName and configKey then
            databases[dbName] = databases[dbName] or {}
            databases[dbName][configKey:lower()] = val
        end
    end
end

Log(kLogInfo, "Database connection info parsed from environment variables")
for dbName, config in pairs(databases) do
    Log(kLogInfo, string.format("Database: %s", dbName))
    Log(kLogInfo, string.format("  Host: %s", config.host or "Not set"))
    Log(kLogInfo, string.format("  Port: %s", config.port or "Not set"))
    Log(kLogInfo, string.format("  Database: %s", config.database or "Not set"))
    Log(kLogInfo, string.format("  User: %s", config.user or "Not set"))
    Log(kLogInfo, string.format("  Password: %s", config.password and "Set" or "Not set"))
end


if not pgSecret then
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local length = 32
    local secret = ""
    for i = 1, length do
        local rand = math.random(1, #charset)
        secret = secret .. string.sub(charset, rand, rand)
    end
    pgSecret = secret
    print("Generated pgSecret: " .. pgSecret)
end

local authUser <const> = "pgm"
local authPass <const> = pgSecret

function verifyAuth()
    local pass, user = GetPass(), GetUser()
    if not pass or not user  then return false end
    return user == authUser and pass == authPass
end
function pgConnect(dbName)
    if not databases[dbName] then
        error("Database configuration not found for: " .. dbName)
    end

    local config = databases[dbName]
    local pg = pgmoon.new({
      host = config.host,
      port = config.port,
      database = config.database,
      user = config.user,
      password = config.password
    })

    assert(pg:connect())
    return pg
end

collectgarbage() -- clean up no longer used memory to reduce image size
