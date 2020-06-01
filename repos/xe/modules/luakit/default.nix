{ config, pkgs, lib, ... }:

let
  nur = import (builtins.fetchTarball
    "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
in {
  home = {
    packages = [ nur.repos.xe.luakit ];
    file = {
      ".local/share/luakit/newtab.html".source = ./start.html;
      ".config/luakit/theme-dark.lua".source = ./theme-dark.lua;
      ".config/luakit/userconf.lua".text = ''
        local settings = require "settings"
        settings.window.home_page = "luakit://newtab/"

        -- Load library of useful functions for luakit
        local lousy = require "lousy"

        lousy.theme.init(lousy.util.find_config("theme-dark.lua"))
        assert(lousy.theme.get(), "failed to load theme")
      '';
    };
  };
}
