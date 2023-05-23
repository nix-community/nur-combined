{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      selfImported = import self { inherit pkgs; };
    in {
      inherit (selfImported) lib;
      overlays.default = selfImported.overlay;
      nixosModules.ssh-known-keys = { ... }: {
        services.openssh.knownHosts =
          self.lib.mapAttrs (_: publicKey: { inherit publicKey; })
          self.lib.sshKnownPublicKeys;
      };
    } // (flake-utils.lib.eachDefaultSystem (system: {
      packages = flake-utils.lib.flattenTree
        (import self { pkgs = nixpkgs.legacyPackages.${system}; });
    }));
}
