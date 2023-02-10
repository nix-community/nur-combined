{ lib
, ignoreLayoutSettings ? false
, dotfiles
}:

let
  inherit (lib) mkIf;

in {
  hardware.keyboard.zsa.enable = true;
  services.xserver.extraConfig = mkIf ignoreLayoutSettings ''${builtins.readFile "${dotfiles}/config/xorg/99-moonlander.conf"}'';
}
