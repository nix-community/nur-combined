{ nixpkgsPath ? <nixpkgs> }:
import ./. { inherit nixpkgsPath; pkgs = import nixpkgsPath { config = { permittedInsecurePackages = [ "thrift-0.10.0" ]; }; }; }
