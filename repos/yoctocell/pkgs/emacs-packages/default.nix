{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:

{
  eshell-syntax-highlighting = pkgs.callPackage ./eshell-syntax-highlighting { inherit sources pkgs; };
  matrix-client = pkgs.callPackage ./matrix-client { inherit sources pkgs; };
  org-pretty-table = pkgs.callPackage ./org-pretty-table { inherit sources pkgs; };
}
