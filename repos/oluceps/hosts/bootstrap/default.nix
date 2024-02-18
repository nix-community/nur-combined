{ self, inputs, ... }: {
  flake =
    let lib = inputs.nixpkgs.lib.extend self.overlays.lib; in
    {
      nixosConfigurations = {
        bootstrap = lib.nixosSystem
          {
            pkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
              config = { };
              overlays = (import ../../overlays.nix inputs);
            };
            specialArgs = lib.base // { user = "elen"; };
            modules = [
              ./configuration.nix
              ./disk-config.nix
              inputs.disko.nixosModules.disko
            ];
          };
      };
    };
}
