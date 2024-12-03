{ config, ... }:

let
  inherit (builtins) readFile;

  identity = import ../resources/identity.nix;
in
{
  console.useXkbConfig = true;
  services.xserver.xkb.layout = "halmakish";
  services.xserver.xkb.extraLayouts.halmakish = {
    description = "Halmakish";
    languages = [ "eng" ];
    symbolsFile = ../resources/halmakish.xkb;
  };

  services.kmonad = {
    enable = true;
    keyboards.default = {
      config = readFile (config.host.resources + "/halmakish.kbd");
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
