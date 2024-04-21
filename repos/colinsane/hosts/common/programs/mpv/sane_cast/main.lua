msg = require("mp.msg")
msg.trace("load: begin")

function subprocess(in_terminal, args)
  if in_terminal then
    args = { "xdg-terminal-exec", table.unpack(args) }
  end
  msg.info(table.concat(args, " "))
  mp.command_native({
    name = "subprocess",
    args = args,
    detach = false,
    capture_stdout = false,
    capture_stderr = false,
    -- capture_size=0,
    passthrough_stdin = false,
    playback_only = false,
  })
end

function invoke_go2tv(in_terminal, args)
  mp.commandv("set", "pause", "yes")
  subprocess(in_terminal, { "go2tv", table.unpack(args) })
end

function invoke_go2tv_on_open_file(mode)
  msg.trace("invoke_go2tv_on_open_file")
  local path = mp.get_property("stream-open-filename")
  msg.trace("path:", path)
  invoke_go2tv(true, { mode, path })
end

mp.add_key_binding(nil, "blast", function() subprocess(false, { "blast-to-default" }) end)
mp.add_key_binding(nil, "go2tv-gui", function() invoke_go2tv(false, {}) end)
mp.add_key_binding(nil, "go2tv-video", function() invoke_go2tv_on_open_file("-v") end)
mp.add_key_binding(nil, "go2tv-stream", function() invoke_go2tv_on_open_file("-s") end)

msg.trace("load: complete")
