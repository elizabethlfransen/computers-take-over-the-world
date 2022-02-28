local installDir = arg[1]
local installFile = installDir .. "/" .. "install.lua"
local startupFile = installDir .. "/" .. "startup.lua"
shell.run(installFile, "--install-dir", installDir)
shell.run(startupFile, installDir)