{ pkgs, ... }:

{
  annotatego = pkgs.callPackage ./annotatego { };
  go-hello-world = pkgs.callPackage ./go-hello-world { };
  nanoc = pkgs.callPackage ./nanoc { };
  rust-hello-world = pkgs.callPackage ./rust-hello-world { };
}
