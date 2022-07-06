{pkgs, lib, ...}:
{
  imports = [
    ../bootstrap/default.nix
    ../../modules/cachix/system.nix
    ../../modules/hold-gc/system.nix
    ./tuning.nix
    ./tmux.nix
    ./bash.nix
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
}
