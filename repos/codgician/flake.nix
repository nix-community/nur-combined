{
  description = "📦 NUR packages from codgician.";

  nixConfig = {
    allow-import-from-derivation = "true";
    sandbox = "relaxed";  # For certain packages on aarch64-darwin
    extra-substituters = [ "https://cache.garnix.io" ];
    extra-trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      inherit (nixpkgs) lib;
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      mypkgs = (system: import ./default.nix {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      });
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      devShell = forAllSystems (system: with nixpkgs.legacyPackages.${system}; mkShell {
        buildInputs = [ ];
      });

      legacyPackages = forAllSystems mypkgs;

      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
    };
}
