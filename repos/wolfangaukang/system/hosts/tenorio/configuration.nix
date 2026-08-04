{
  lib,
  hostname,
  overlays,
  ...
}:

{
  nix.enable = false; # Setting this as Lix was installed through https://git.lix.systems/lix-project/lix-installer
  nixpkgs = {
    inherit overlays;
  };
  system.defaults.dock = {
    autohide = true;
    orientation = "bottom";
    showhidden = true;
  };
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = false;
      cleanup = "zap";
    };
    casks = [
      "karabiner-elements"
      "scroll-reverser"
    ];
  };
  networking.localHostName = hostname;
  programs = {
    fish.enable = lib.mkForce false;
    zsh.enable = true;
  };
  system = {
    primaryUser = "bjorn";
    stateVersion = 6;
  };
}
