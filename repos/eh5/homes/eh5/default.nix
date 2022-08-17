{ self
, nixpkgs
, home-manager
, inputs
, system
, username
, homeDirectory ? "/home/${username}"
}:
home-manager.lib.homeManagerConfiguration {
  modules = [
    ./home.nix
    ./dotfiles.nix
    {
      home = {
        inherit username homeDirectory;
        stateVersion = "22.05";
      };
    }
  ];
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      self.overlays.default
    ];
  };
}
