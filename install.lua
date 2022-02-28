local baseUrl = "https://api.github.com/repos/elizabethlfransen/computers-take-over-the-world"
local branch = "main"
local installDir = (arg[1] == "--install-dir" and arg[2]) or shell.dir() .. "/" .. "computers-take-over-the-world"
local branchFile = "branch.json"
local createStartup = true
local function getRemoteHash()
    local response = http.get(baseUrl .. "/branches/" .. branch)
    local body = textutils.unserialiseJSON(response.readAll())
    return body["commit"]["sha"]
end

local function mapContentsToTable(contents)
    local result = {}
    for _, v in ipairs(contents) do
        result[v["path"]] = v
    end
    return result
end

local function getRemoteContents()
    local response = http.get(baseUrl .. "/contents?ref=" .. branch)
    local body = textutils.unserialiseJSON(response.readAll())
    return mapContentsToTable(body)
end

local function getLocalContents()
    local path = installDir .. "/" .. branchFile
    if not fs.exists(path) then
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

local function updateFile(file)
    local path = installDir .. "/" .. file["path"]
    local response = http.get(file["download_url"])
    local body = response.readAll()
    local localFile = fs.open(path, "w")
    localFile.write(body)
    localFile.close()
end

local function removeFile(file)
    local path = installDir .. "/" .. file["path"]
    fs.delete(path)
end

local function removeOldFiles(localContents, remoteContents)
    if localContents == nil then
        return
    end
    for k,v in pairs(localContents) do
        if remoteContents[k] == nil then
            removeFile(v)
        end
    end
end

local function updateFiles(localContents, remoteContents)
    for k, v in pairs(remoteContents) do
        if localContents == nil or localContents[k] == nil or localContents[k]["sha"] ~= v["sha"] then
            updateFile(v)
        end
    end
end

local function createStartupFile()
    -- TODO append to the startup file in case they have something
    local file = fs.open("startup.lua", "w")
    local startupPath = installDir .. "/launch.lua"
    local execLine = "os.run({},\"" .. startupPath .. "\", \"" .. installDir .. "\")"
    file.write(execLine)
    file.close()
end

local function install()
    print("Getting branch contents...")
    local localContents = getLocalContents()
    local remoteContents = getRemoteContents()
    updateFiles(localContents, remoteContents)
    removeOldFiles(localContents, remoteContents)
    updateLocalContents(remoteContents)
    if createStartup then
        createStartupFile()
    end
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
