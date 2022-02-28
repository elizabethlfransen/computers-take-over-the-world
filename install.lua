local baseUrl = "https://api.github.com/repos/elizabethlfransen/computers-take-over-the-world"
local branch = "main"
local installDir = "computers-take-over-the-world"
local branchFile = "branch.json"
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

local function getLocalContents()
    local path = installDir .. "/" .. branchFile
    if ~fs.exists(path) then
        return nil
    end
    local file = fs.open(path, "r")
    local result = file.readAll()
    file.close()
    return result
end

local function updateLocalContents(contents)
    local serializedContents = textutils.serializeJSON(contents)
    local path = installDir .. "/" .. branchFile
    local file = fs.open(path, "w")
    file.write(serializedContents)
    file.close()
end

local function install()
    print("Getting branch contents...")
    local localContents = getLocalContents()
    local remoteContents = getRemoteContents()
    updateLocalContents(remoteContents)
end

if fs.exists(installDir) then
    print("Updating")
    install()
else
    print("Installing first time")
    print("Creating directory " .. installDir)
    fs.makeDir(installDir)
    install()
end
