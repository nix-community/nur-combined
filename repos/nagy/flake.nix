{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    {
      inherit ((import self { pkgs = nixpkgs.legacyPackages."x86_64-linux"; }))
        lib;
      overlays.default =
        (import self { pkgs = nixpkgs.legacyPackages."x86_64-linux"; }).overlay;
      nixosModules.ssh-known-keys = { pkgs }: {
        services.openssh.knownHosts =
          self.lib.mapAttrs (name: value: { publicKey = value; })
          self.lib.sshKnownPublicKeys;
      };
    } // (flake-utils.lib.eachDefaultSystem (system: {
      packages = flake-utils.lib.flattenTree
        (import self { pkgs = nixpkgs.legacyPackages.${system}; });
    }));
}
