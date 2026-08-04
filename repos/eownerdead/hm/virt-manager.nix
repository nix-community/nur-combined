{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.eownerdead.virt-manager.enable = lib.mkEnableOption "Enable virt-manager";

  config = lib.mkIf config.eownerdead.virt-manager.enable {
    home.packages = with pkgs; [ virt-manager ];

    dconf.settings = {
      "org/virt-manager/virt-manager" = {
        xmleditor-enabled = true;
      };
      "org/virt-manager/virt-manager/connections" = {
        uris = [
          "qemu:///session"
          "qemu:///system"
        ];
        autoconnect = [
          "qemu:///session"
          "qemu:///system"
        ];
      };
    };
  };
}
