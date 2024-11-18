{ config, ... }:

let
  inherit (builtins) readFile;

  identity = import ../resources/identity.nix;
in
{
  imports = [
    ../../packages/kmonad.nix
  ];

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
      fallthrough = true;
      allowCommands = false;
    };
  };
  systemd.services.kmonad-default.restartIfChanged = false;

  programs.ydotool.enable = true;

  # Permissions
  users.users.${identity.username}.extraGroups = [ "ydotool" ];
}
