{ ... }:

{
  imports = [
    ./wayland.nix
  ];

  programs.sway = {
    enable = true;
    xwayland.enable = true;
  };
}
