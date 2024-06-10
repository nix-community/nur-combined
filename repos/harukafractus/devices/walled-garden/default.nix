{ pkgs, ... }: {

  imports = [ ../_options ];

  networking.hostName = "walled-garden";
  nixpkgs.hostPlatform = "aarch64-darwin";
  services.nix-daemon.enable = true;

  system.defaults = {
    trackpad.Clicking = true;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    trackpad.Dragging = true;
  };

  nixpkgs.overlays = [
    (import ../../nur-everything/overlays/darwin)
  ];
}
