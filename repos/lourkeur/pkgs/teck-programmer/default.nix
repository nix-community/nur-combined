{ libudev, pkgs, system }:

let
  nodePackages = import ./composition.nix {
    inherit pkgs system;
  };
in
nodePackages.teck-programmer.override {
  buildInputs = [ libudev.dev ];
}
