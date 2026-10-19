{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Pick the right upstream package per platform.
  syncthingPackage =
    if pkgs.stdenv.hostPlatform.isDarwin then pkgs.syncthing-macos else pkgs.syncthing;
  musicPath =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Music/Library"
    else
      "${config.home.homeDirectory}/Music";
in
{
  options.dots.syncthing.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the syncthing dotfiles module.";
  };

  config = lib.mkIf config.dots.syncthing.enable {
    services.syncthing = {
      enable = true;
      package = syncthingPackage;
      overrideDevices = true;
      overrideFolders = true;
      guiAddress = "0.0.0.0:8384";
      guiCredentials = {
        username = "avy";
        passwordFile = config.sops.secrets.syncthing-guipass.path;
      };
      settings = {
        options.relaysEnabled = true;
        urAccepted = -1;
        devices = {
          "Avys-Mac".id = "ZU2VV6Q-KU2QH2C-Z6PELOK-7YXOH7B-D6PAZNY-WROV7VD-4CNJNBG-CSZ4EQP";
          "Pixel-3".id = "XRQ5W4J-V3BJKXH-2NIAP4E-JRPWVGQ-GQ5EFKG-IRFYUGD-55F62F3-GETMOAI";
          "Avys-Iphone".id = "ZFO4ZOC-NXLX55J-CUI2ADD-GTHUHAA-4M2HBXI-632UESR-6SQEUDV-QWLD6AJ";
        };

        folders = {
          "music" = {
            path = musicPath;
            devices = [
              "Avys-Mac"
              "Pixel-3"
              "Avys-Iphone"
            ];
          };
        };
      };
    };
  };

}
