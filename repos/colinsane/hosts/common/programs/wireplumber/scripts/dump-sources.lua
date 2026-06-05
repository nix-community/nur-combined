#!/usr/bin/env -S NIX_BUILD_SHELL=/bin/sh nix-shell
--[[
#!nix-shell -i wpexec ../../../../../integrations/nix-shell --arg f 'ps: [ ps.wireplumber ]'
--]]
-- Dump all Wireplumber sources (i.e. Microphones)
-- use like `wpexec ./dump-sources.lua`

dumputils = require("./dump-common")

dumputils:dump_om(ObjectManager {
  Interest {
    type = "node",
    Constraint { "media.class", "matches", "Audio/Source", type = "pw-global" },
    -- do not consider virtual items created by WirePlumber
    Constraint { "wireplumber.is-virtual", "!", true, type = "pw" },
  }
})
