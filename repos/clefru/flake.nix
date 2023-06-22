{
  description = "clefru overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, ... }: rec {
    # Use makePackages if you want to use this flake with something
    # else than x86_64.
    makePackages = pkgs: pkgs.lib.filterAttrs (n: v:
      n != "lib" && n != "modules" && n != "overlays") (import ./default.nix {
        inherit pkgs;
      });
    packages.x86_64-linux = makePackages (import nixpkgs {
      config = {
        allowUnfree = true;
      };
      system = "x86_64-linux";
    });
  };
}
