#!/usr/bin/env -S NIX_BUILD_SHELL=/bin/sh nix-shell
--[[
#!nix-shell -i wpexec ../../../../../integrations/nix-shell --arg f 'ps: [ ps.wireplumber ]'
--]]
-- Dump all Wireplumber events as they occur
-- use like `wpexec ./monitor-events.lua`

dumputils = require("./dump-common")

SimpleEventHook {
  name = "monitor-events",
  -- after = ...
  -- before = ...
  interests = {
    EventInterest {
      -- Constraint { "event.type", "=", "select-target" },
    },
  },
  execute = function (event)
    print(dumputils:dump_event(event))
  end
}:register()
print("monitoring... do something like play/pause media, change volume, etc")
