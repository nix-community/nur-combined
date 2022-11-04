{
  description = "Experimental flake for CI testing";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }: 
  let system = "x86_64-linux"; in recurseIntoAttrs ({
    packages.${system} = import ./default.nix {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };
  });
}