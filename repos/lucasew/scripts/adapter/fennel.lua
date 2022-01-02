package.path = package.path .. ";/nix/store/y70p2il6znsqz87prm2ln72shvkavcgg-fennel-1.0.0/share/lua/5.4.3/?.lua"

local fennel = require'fennel'

function getCurrentFile()
    return debug.getinfo(2, "S").source
end

-- print(getCurrentFile())
newFile = getCurrentFile():gsub("fennel.lua$", "index.fnl"):sub(2)
-- print(newFile)
return fennel.dofile(newFile)
