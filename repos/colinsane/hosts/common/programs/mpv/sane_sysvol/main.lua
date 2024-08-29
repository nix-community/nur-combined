msg = require("mp.msg")
msg.trace("load: begin")

non_blocking_popen = require("non_blocking_popen")

RD_SIZE = 65536

function startswith(superstring, substring)
  return superstring:sub(1, substring:len()) == substring
end
function strip_prefix(superstring, substring)
  assert(startswith(superstring, substring))
  return superstring:sub(1 + substring:len())
end

function ltrim(s)
  -- remove all leading whitespace from `s`
  local i = 1
  while s:sub(i, i) == " " or s:sub(i, i) == "\t" do
    i = i + 1
  end
  return s:sub(i)
end

function subprocess(args)
  mp.command_native({
    name = "subprocess",
    args = args,
    -- these arguments below probably don't matter: copied from sane_cast
    detach = false,
    capture_stdout = false,
    capture_stderr = false,
    passthrough_stdin = false,
    playback_only = false,
  })
end

function sysvol_new()
  return {
    -- sysvol is pipewire-native volume
    -- it's the cube of the equivalent 0-100% value represented inside mpv
    sysvol = nil,
    sysmute = nil,
    change_sysvol = function(self, mpv_vol)
      -- called when mpv wants to set the system-wide volume
      if mpv_vol == nil then
        return
      end
      local volstr = tostring(mpv_vol) .. "%"

      local old_mpv_vol = nil
      if self.sysvol ~= nil then
        old_mpv_vol = 100 * self.sysvol^(1/3)
      end
      if old_mpv_vol ~= nil and math.abs(mpv_vol - old_mpv_vol) < 1.0 then
        -- avoid near-infinite loop where we react to our own volume change.
        -- consider that we might be a couple messages behind in parsing pipewire when we issue this command,
        -- hence a check on only the pipewire -> mpv side wouldn't prevent oscillation
        msg.debug("NOT setting system-wide volume:", old_mpv_vol, volstr)
        return
      end

      msg.debug("setting system-wide volume:", old_mpv_vol, volstr)
      self.sysvol = (0.01*mpv_vol)^3
      subprocess({
        "wpctl",
        "set-volume",
        "@DEFAULT_AUDIO_SINK@",
        volstr
      })
    end,
    on_sysvol_change = function(self, sysvol)
      -- called when the pipewire system volume is changed (either by us, or an external application)
      if sysvol == nil then
        return
      end

      local new_mpv_vol = 100 * sysvol^(1/3)
      local old_mpv_vol = nil
      if self.sysvol ~= nil then
        old_mpv_vol = 100 * self.sysvol^(1/3)
      end

      if old_mpv_vol ~= nil and math.abs(new_mpv_vol - old_mpv_vol) < 1.0 then
        -- avoid an infinite loop where we react to our own volume change
        msg.debug("NOT announcing volume change to mpv (because it was what triggered the change):", old_mpv_vol, new_mpv_vol)
        return
      end

      msg.debug("announcing volume change to mpv:", old_mpv_vol, new_mpv_vol)
      self.sysvol = sysvol
      mp.set_property_number("user-data/sane_sysvol/volume", new_mpv_vol)
    end,
    change_sysmute = function(self, mute)
      if mute == nil then
        return
      end
      if mute == self.sysmute then
        msg.debug("NOT setting system-wide mute (because it didn't change)", mute)
        return
      end

      local mutestr
      if mute then
        mutestr = "1"
      else
        mutestr = "0"
      end
      msg.debug("setting system-wide mute:", mutestr)
      self.sysmute = mute
      subprocess({
        "wpctl",
        "set-mute",
        "@DEFAULT_AUDIO_SINK@",
        mutestr
      })
    end,
    on_sysmute_change = function(self, mute)
      if mute == nil then
        return
      end

      msg.debug("announcing mute to mpv:", mute)
      self.sysmute = mute
      mp.set_property_bool("user-data/sane_sysvol/mute", mute)
    end
  }
end

function pwmon_parser_new()
  return {
    -- volume: pipewire-native volume. usually 0.0 - 1.0, but can go higher (e.g. 3.25)
    -- `wpctl get-volume` and this volume are related, in that the volume reported by
    -- wpctl is the cube-root of this one.
    volume = nil, -- number
    mute = nil, -- bool

    -- parser state:
    in_device = false,
    in_direction = false,
    in_output = false,
    in_vol = false,
    in_mute = false,

    feed_line = function(self, line)
      msg.trace("pw-mon:", line)
      line = ltrim(line)
      if startswith(line, "changed:") or startswith(line, "added:") or startswith(line, "removed:") then
        self.in_device = false
        self.in_direction = false
        self.in_output = false
        self.in_vol = false
        self.in_mute = false
        self.in_properties = false
      elseif startswith(line, "type: ") then
        self.in_device = startswith(line, "type: PipeWire:Interface:Device")
        msg.trace("parsed type:", line, self.in_device)
      elseif startswith(line, "Prop: ") and self.in_device then
        self.in_direction = startswith(line, "Prop: key Spa:Pod:Object:Param:Route:direction")
        if self.in_direction then
          self.in_output = false
        end
        -- which of the *Volumes params we read is unclear.
        -- alternative to this is to just detect the change, and then cal wpctl get-volume @DEFAULT_AUDIO_SINK@
        self.in_vol = startswith(line, "Prop: key Spa:Pod:Object:Param:Props:channelVolumes")
        self.in_mute = startswith(line, "Prop: key Spa:Pod:Object:Param:Props:mute")
        msg.trace("parsed `Prop:`", line, self.in_vol)
      elseif line:find("Spa:Enum:Direction:Output", 1, true) and self.in_direction then
        self.in_output = true
      elseif startswith(line, "Float ") and self.in_device and self.in_output and self.in_vol then
        value = tonumber(strip_prefix(line, "Float "))
        self:feed_volume(value)
      elseif startswith(line, "Bool ") and self.in_device and self.in_output and self.in_mute then
        value = strip_prefix(line, "Bool ") == "true"
        self:feed_mute(value)
      elseif startswith(line, "properties:") and self.in_device then
        self.in_properties = true
      end
    end,

    feed_volume = function(self, vol)
      msg.debug("volume:", vol)
      self.volume = vol
    end,
    feed_mute = function(self, mute)
      msg.debug("mute:", mute)
      self.mute = mute
    end,
    -- get_effective_volume = function(self)
    --   if self.mute then
    --     return 0
    --   else
    --     return self.volume
    --   end
    -- end
  }
end

function pwmon_new()
  return {
    -- non_blocking_popen handle for the pw-mon process
    -- which can be periodically read and parsed to detect volume changes.
    -- we have to use `sane-die-with-parent` otherwise `pw-mon` will still be active even after mpv exits.
    handle = non_blocking_popen.non_blocking_popen("sane-die-with-parent --descendants pw-mon", RD_SIZE),
    stdout_unparsed = "",
    pwmon_parser = pwmon_parser_new(),
    service = function(self)
      -- do a single non-blocking read, and parse the result
      -- in the *rare* case in which more than RD_SIZE data is ready, we service that remaining data on the next call
      local buf, res = self.handle:read(RD_SIZE)
      if res == "closed" then
        msg.debug("pw-mon unexpectedly closed!")
      end
      if buf ~= nil then
        local old_vol = self.pwmon_parser.volume
        local old_mute = self.pwmon_parser.mute
        self.stdout_unparsed = self.stdout_unparsed .. buf
        self:consume_stdout()
        local new_vol = self.pwmon_parser.volume
        local new_mute = self.pwmon_parser.mute

        if new_vol ~= old_vol then
          msg.debug("pipewire volume change:", old_vol, new_vol)
          mp.set_property_number("user-data/sane_sysvol/pw-mon-volume", new_vol)
        end
        if new_mute ~= old_mute then
          msg.debug("pipewire mute change:", old_mute, new_mute)
          mp.set_property_bool("user-data/sane_sysvol/pw-mon-mute", new_mute)
        end
      end
    end,
    consume_stdout = function(self)
      local idx_newline, next_newline = 0, 0
      while next_newline ~= nil do
        next_newline = self.stdout_unparsed:find("\n", idx_newline + 1, true)
        if next_newline ~= nil then
          self.pwmon_parser:feed_line(self.stdout_unparsed:sub(idx_newline + 1, next_newline - 1))
          idx_newline = next_newline
        end
      end
      self.stdout_unparsed = self.stdout_unparsed:sub(idx_newline + 1)
    end,
  }
end

mp.set_property_number("user-data/sane_sysvol/volume", 0)
mp.set_property_bool("user-data/sane_sysvol/mute", true)

local sysvol = sysvol_new()
local first_sysvol_announcement = true
mp.observe_property("user-data/sane_sysvol/volume", "native", function(_, val)
  -- we must set the volume property early -- before we actually know the volume
  -- else other modules will think it's `nil` and error.
  -- but we DON'T want the value we set to actually impact the system volume
  if not first_sysvol_announcement then
    sysvol:change_sysvol(val)
  end
  first_sysvol_announcement = false
end)
mp.observe_property("user-data/sane_sysvol/pw-mon-volume", "native", function(_, val)
  sysvol:on_sysvol_change(val)
end)

local first_sysmute_announcement = true
mp.observe_property("user-data/sane_sysvol/mute", "native", function(_, val)
  -- we must set the mute property early -- before we actually know the mute
  -- else other modules will think it's `nil` and error.
  -- but we DON'T want the value we set to actually impact the system mute
  if not first_sysmute_announcement then
    sysvol:change_sysmute(val)
  end
  first_sysmute_announcement = false
end)
mp.observe_property("user-data/sane_sysvol/pw-mon-mute", "native", function(_, val)
  sysvol:on_sysmute_change(val)
end)

local pwmon = pwmon_new()
mp.register_event("tick", function() pwmon:service() end)

msg.trace("load: complete")
