{ pkgs ? import <nixpkgs> {} }:

let
  nur = pkgs.callPackage ./../.. {};
  inherit (nur) minecraft;
in

with minecraft;

mkDatapack {
  meta = {
    name = "my-dimensions";
    description = "Adds two new dimensions";
  };
  additions = {
    dimension_type = {
      type = dimensionSettings.overworld // {
        has_skylight = false;
      };
    };
    dimension = {
      superflat = {
        type = "my-dimensions:type";
        generator = genSuperflat {};
      };
      normal = {
        type = "my-dimensions:type";
        generator = genNormal {
          seed = 0;
        };
      };
    };
  };
}
