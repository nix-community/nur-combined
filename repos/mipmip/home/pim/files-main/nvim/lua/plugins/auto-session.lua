return {
  'rmagatti/auto-session',
  enabled = false,
  config = function()
    require("auto-session").setup {
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "/"},
    }
  end
}
