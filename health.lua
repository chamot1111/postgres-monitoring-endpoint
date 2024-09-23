if GetMethod() ~= 'GET' then
    return ServeError(405, "Method Not Allowed")
end

if not verifyAuth() then
    SetHeader("WWW-Authenticate", "Basic realm=\"Restricted Area\"")
    return ServeError(401, "Unauthorized")
end
local allParams = GetParams()
local monitorParam, dbParam = nil, nil
for _, param in ipairs(allParams) do
    if param[1] == "monitor" then
        monitorParam = param[2]
    elseif param[1] == "db" then
        dbParam = param[2]
    end
end

if not monitorParam then
    return ServeError(400, "Missing 'monitor' parameter")
end

if not dbParam then
    return ServeError(400, "Missing 'db' parameter")
end

if not monitorParam:match("^[%a%d_-]+$") then
    return ServeError(400, "Invalid 'monitor' parameter")
end

if not dbParam:match("^[%a%d_-]+$") then
    return ServeError(400, "Invalid 'db' parameter")
end

local pg, err = pgConnect(dbParam)
if not pg then
    return ServeError(400, "Invalid database: " .. err)
end

local res, err = assert(pg:query("select monitoring." .. monitorParam .. "();"))

if res == nil then
    SetStatus(500)
    SetHeader("Content-Type", "application/json")
    return EncodeJson({status = "error", error = err}, {useoutput = true})
end

SetHeader("Content-Type", "application/json")
return EncodeJson({status = "success", result = res}, {useoutput = true})
