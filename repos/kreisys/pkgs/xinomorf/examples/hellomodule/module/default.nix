{ stubs
, pkgs ? import <nixpkgs> {} }:

{
  mkHelloWorld = import ./hello.nix { inherit pkgs; } stubs;
}
