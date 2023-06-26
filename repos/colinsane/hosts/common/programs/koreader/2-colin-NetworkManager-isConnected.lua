-- as of 2023.05.1, koreader FTP browser always fails to load.
-- it's convinced that it's offline, and asks to connect to wifi.
-- this seems to be because of the following in <frontend/device/sdl/device.lua>:
--
-- function Device:initNetworkManager(NetworkMgr)
--     function NetworkMgr:isWifiOn() return true end
--     function NetworkMgr:isConnected()
--         -- Pull the default gateway first, so we don't even try to ping anything if there isn't one...
--         local default_gw = Device:getDefaultRoute()
--         if not default_gw then
--             return false
--         end
--         return 0 == os.execute("ping -c1 -w2 " .. default_gw .. " > /dev/null")
--     end
-- end
--
-- specifically, `os.execute` is not *expected* to return 0. it returns `true` on success:
-- <https://www.lua.org/manual/5.3/manual.html#pdf-os.execute>
-- this apparently changed from 5.1 -> 5.2
--
-- XXX: this same bug likely applies to `isCommand` and `runCommand` in <frontend/device/sdl/device.lua>
-- - that would manifest as wikipedia links failing to open in external application (xdg-open)

local logger = require("logger")
logger.info("applying colin patch")

local Device = require("device")
logger.info("Device:" .. tostring(Device))

local orig_initNetworkManager = Device.initNetworkManager
Device.initNetworkManager = function(self, NetworkMgr)
  logger.info("Device:initNetworkManager")
  orig_initNetworkManager(self, NetworkMgr)
  function NetworkMgr:isConnected()
    logger.info("mocked `NetworkMgr:isConnected` to return true")
    return true
    -- unpatch to show that the boolean form works
    -- local rc = os.execute("ping -c1 -w2 10.78.79.1 > /dev/null")
    -- logger.info("ping rc: " .. tostring(rc))
    -- return rc
  end
end
