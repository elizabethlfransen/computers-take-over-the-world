local installDir = arg[1]
local installFile = installDir .. "/" .. "install.lua"
local startupFile = installDir .. "/" .. "startup.lua"
os.run({}, installFile, installDir)
os.run({}, installFile, installDir)