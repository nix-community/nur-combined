{self, pkgs, lib, ...}:
let
  inherit (self) inputs;
in
{
  imports = [
    ../bootstrap/default.nix
    ../../modules/cachix/system.nix
    ../../modules/hold-gc/system.nix
    ./tuning.nix
    ./tmux
    ./bash
    "${inputs.simple-dashboard}/nixos-module.nix"
  ];

  boot.loader.grub.memtest86.enable = true;
  
  environment = {
    systemPackages = with pkgs; [
      rlwrap
      wget
      curl
      unrar
      direnv
      pciutils
    ];
  };
  cachix.enable = true;

  services.smartd = {
    enable = true;
    autodetect = true;
    notifications.test = true;
  };
}
