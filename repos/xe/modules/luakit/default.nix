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
      ".config/luakit/userconf.lua".text = ''
        local settings = require "settings"
        require_web_module "referer_control_wm"
        require_web_module "tab_favicons"
        settings.window.home_page = "luakit://newtab/"
      '';
    };
  };
}
