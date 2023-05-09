{ lib, inputs, self, super, ... }:
with lib;
{
  eachDefaultSystems = f: genAttrs
    [
      "aarch64-linux"
      "x86_64-linux"
    ]
    (system: f (import inputs.nixpkgs { inherit system; overlays = [ super.overlay ]; }));
} // (import ../lib { inherit lib; })
