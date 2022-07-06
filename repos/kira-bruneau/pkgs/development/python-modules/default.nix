pkgs: final: prev:

with final;

let
  callPackage = pkgs.newScope final;
in
{
  inherit callPackage;

  aamp = callPackage ./aamp { };

  botw-havok = callPackage ./botw-havok { };

  botw-utils = callPackage ./botw-utils { };

  byml = callPackage ./byml { };

  debugpy = callPackage ./debugpy { };

  oead = callPackage ./oead {
    inherit (pkgs) cmake;
  };

  pygls = callPackage ./pygls { };

  pytest-datadir = callPackage ./pytest-datadir { };

  rstb = callPackage ./rstb { };

  vdf = callPackage ./vdf { };
}
