#!/usr/bin/env -S NIX_BUILD_SHELL=/bin/sh nix-shell
--[[
#!nix-shell -i wpexec ../../../../.. -A static-nix-shell.mkShell --arg packages 'ps: [ ps.wireplumber ]'
--]]
-- Dump all Wireplumber links
-- use like `wpexec ./dump-links.lua`

dumputils = require("./dump-common")

dumputils:dump_om(ObjectManager {
  Interest {
    type = "link",
  },
})
