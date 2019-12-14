{ buildGoPackage, arduino-cli }:
buildGoPackage rec {
  name = "vgo2nix-${version}";
  version = arduino-cli.branch;
  src = arduino-cli;
  goDeps = ./deps.nix;
  goPackagePath = "github.com/arduino/arduino-cli";
}
