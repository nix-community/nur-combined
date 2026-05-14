{ config, lib, ... }:

let
  inherit (builtins) readFile replaceStrings;

  identity = import ../library/identity.lib.nix { inherit lib; };
in
{
  console.useXkbConfig = true;
  services.xserver.xkb.layout = "engramish";
  services.xserver.xkb.extraLayouts.engramish = {
    description = "Engramish";
    languages = [ "eng" ];
    symbolsFile = ./assets/engramish.xkb;
  };

  services.kmonad = {
    enable = true;
    keyboards.default = {
      config = replaceStrings [ "░" ] [ "_" ] (readFile (config.host.dir + "/assets/engramish.kbd"));
      defcfg = {
        enable = true;
        allowCommands = false;
        fallthrough = true;
      };
    };
  };
  systemd.services.kmonad-default.restartIfChanged = false;

  programs.ydotool.enable = true;

  # Permissions
  users.users.${identity.username}.extraGroups = [ "ydotool" ];
}
