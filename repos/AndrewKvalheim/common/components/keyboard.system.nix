{ config, ... }:

let
  inherit (builtins) readFile;

  identity = import ../resources/identity.nix;
in
{
  imports = [
    ../../packages/kmonad.nix
    ../../packages/ydotoold.nix
  ];

  console.useXkbConfig = true;
  services.xserver.layout = "halmakish";
  services.xserver.extraLayouts.halmakish = {
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

  services.ydotoold.enable = true;

  # Permissions
  users.users.${identity.username}.extraGroups = [ "ydotool" ];
}
