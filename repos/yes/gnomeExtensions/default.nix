{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

{
  onedrive = callPackage ./onedrive { inherit rp; };
}