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
        modes.add_binds("normal", {{
            "<Control-c>",
            "Copy selected text.",
            function ()
              luakit.selection.clipboard = luakit.selection.primary
            end
        }})

        local editor = require "editor"
        editor.editor_cmd = "e {file} +{line}"

        require_web_module("referer_control_wm")
        require_web_module("tab_favicons")
      '';
    };
  };
}
