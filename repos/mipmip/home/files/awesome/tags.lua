--      ████████╗ █████╗  ██████╗ ███████╗
--      ╚══██╔══╝██╔══██╗██╔════╝ ██╔════╝
--         ██║   ███████║██║  ███╗███████╗
--         ██║   ██╔══██║██║   ██║╚════██║
--         ██║   ██║  ██║╚██████╔╝███████║
--         ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝

-- ===================================================================
-- Imports
-- ===================================================================


local dir = os.getenv("HOME") .. "/.config/awesome/icons/tags/"


-- ===================================================================
-- Define tags
-- ===================================================================

-- define module table
local tags = {
   {
      icon = dir .. "terminal.png",
      layout = 2
   },
   {
      icon = dir .. "notepad.png",
      layout = 2
   },
   {
      icon = dir .. "firefox.png",
      layout = 1
   },
   {
      icon = dir .. "mail.png",
      layout = 1
   },
   {
      icon = dir .. "star.png",
      layout = 1
   },
--   {
      --icon = dir .. "star.png",
      --layout = 2
   --},
   --{
      --icon = dir .. "star.png",
      --layout = 2
   --},
   --{
      --icon = dir .. "star.png",
      --layout = 1
   --},
   {
      icon = dir .. "terminal.png",
      layout = 2
   }
}

return tags
