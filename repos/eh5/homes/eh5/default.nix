{ self
, nixpkgs
, home-manager
, inputs
, system
, username
, homeDirectory ? "/home/${username}"
}:
home-manager.lib.homeManagerConfiguration {
  inherit system username homeDirectory;
  configuration = ./home.nix;
  extraModules = [
    ./dotfiles.nix
  ];
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      self.overlays.default
      inputs.nixgl.overlay
    ];
  };
}
