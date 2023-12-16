local logger = require("logger")
logger.info("applying colin patch colin-impl-clipboard")

-- source: <https://github.com/ncopa/lua-shell/blob/master/shell.lua>
local function shescape(arg)
  if arg:match("[^A-Za-z0-9_/:=-]") then
    arg = "'"..arg:gsub("'", "'\\''").."'"
  end
  return arg
end

-- 2023/12/15: the default setClipboardText doesn't do anything
-- frontend/device/sdl/device.lua calls frontend/device/input.lua is noop
local input = require("ffi/input")
input.setClipboardText = function(text)
  logger.info("input.setClipboardText")
  local cmd = "wl-copy " .. shescape(text)
  logger.info("invoke: " .. cmd)
  os.execute(cmd)
end

-- 2023/12/15: the default ReaderLink "Copy" option (when clicking a URL) doesn't do anything
-- patch so it calls `setClipboardText`
local ReaderLink = require("apps/reader/modules/readerlink")
local UIManager = require("ui/uimanager")
local _ = require("gettext")
local orig_ReaderLink_init = ReaderLink.init;
ReaderLink.init = function(self)
  orig_ReaderLink_init(self)
  self._external_link_buttons["10_copy"] = function(this, link_url)
    return {
      text = _("Copy"),
      callback = function()
          UIManager:close(this.external_link_dialog)
          input.setClipboardText(link_url)
      end,
    }
  end
end

