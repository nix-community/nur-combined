# Revue's release binary for Nix, without building it. Made from
# packaging/nix in Revue's repository by `task release:publish:managers` at
# each release; Revue's own flake.nix builds from source instead.
{
  description = "Revue, a fast native code review app (the release binary)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        revue = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/revue-bin.nix { };
      in {
        default = revue;
        revue-bin = revue;
      });
  };
}
