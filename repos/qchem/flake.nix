{
  description = "NixOS-QChem flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";

  outputs = { self, nixpkgs } : {

    overlay = import ./.;

    packages."x86_64-linux" = let
      pkgs = (import nixpkgs) {
        system = "x86_64-linux";
        overlays = [ (import ./default.nix) ];
        config.allowUnfree = true;
        config.qchem-config = (import ./cfg.nix) {
          allowEnv = false;
          optAVX = true;
        };
      };
    in pkgs.qchem;

    inherit nixpkgs;
  };
}
