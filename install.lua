local baseUrl = "https://api.github.com/repos/elizabethlfransen/computers-take-over-the-world"
local branch = "main"
local installDir = "computers-take-over-the-world"
local createStartup = true

local function getRemoteHash()
    local response = http.get(baseUrl .. "/branches/" .. branch)
    local body = textutils.unserialiseJSON(response.readAll())
    return body["commit"]["sha"]
end

local function getRemoteContents()
    local response = http.get(baseUrl .. "/contents?ref=" .. branch)
    return textutils.unserialiseJSON(response.readAll())
end

local function install()
    print("Installing first time")
end

local function update()
    print("Updating")
end

if fs.exists(installDir) then
    install()
else
    update()
end
