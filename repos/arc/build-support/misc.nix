{ self, super, lib, ... }: let
  attrs = {
    purple-plugins-arc = { pidgin, pidgin-skypeweb, pidgin-otr, purple-discord, purple-hangouts, purple-facebook, telegram-purple, purple-matrix, purple-plugin-pack, purple-lurch }:
      [
        pidgin-skypeweb pidgin-otr purple-discord purple-hangouts purple-facebook telegram-purple purple-matrix purple-plugin-pack purple-lurch
      ];
    gst_all_1-noqt = { pkgs }: (pkgs.extend (_: _: {
      enableZbar = false;
    })).gst_all_1;
  };
in (builtins.mapAttrs (_: p: self.callPackage p { }) attrs)
