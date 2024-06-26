{ ... }:

{
  imports = [
    ./common/wayland.nix
  ];

  programs.sway = {
    enable = true;
    xwayland.enable = true;
  };
}
