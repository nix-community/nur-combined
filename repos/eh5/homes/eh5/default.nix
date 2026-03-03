{
  self,
  nixpkgs,
  home-manager,
  inputs,
  system,
  username,
  homeDirectory ? "/home/${username}",
}:
home-manager.lib.homeManagerConfiguration {
  modules = [
    ./home.nix
    {
      home = {
        inherit username homeDirectory;
        stateVersion = "25.11";
      };
      nix = {
        nixPath = [ "nixpkgs=${nixpkgs}" ];
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
