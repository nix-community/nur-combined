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

function invoke_paused(in_terminal, args)
  mp.commandv("set", "pause", "yes")
  for k, v in ipairs(args) do
    if v == "@FILE@" then
      args[k] = mp.get_property("stream-open-filename")
    end
  end
  subprocess(in_terminal, args)
end


mp.add_key_binding(nil, "audio-cast", function() subprocess(true, { "sane-cast", "--verbose" }) end)
mp.add_key_binding(nil, "sane-cast", function() invoke_paused(true, { "sane-cast", "--verbose", "@FILE@" }) end)

msg.trace("load: complete")
