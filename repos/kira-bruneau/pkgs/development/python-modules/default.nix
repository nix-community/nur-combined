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

  lunr = callPackage ./lunr { };

  mkdocs = callPackage ./mkdocs { };

  mkdocs-material = callPackage ./mkdocs-material { };

  mkdocs-material-extensions = callPackage ./mkdocs-material-extensions {
    # Pass a build of mkdocs-material without
    # mkdocs-material-extensions for tests
    mkdocs-material = mkdocs-material.override {
      mkdocs-material-extensions = null;
    };
  };

  oead = callPackage ./oead {
    inherit (pkgs) cmake;
  };

  pygls = callPackage ./pygls { };

  pymdown-extensions = callPackage ./pymdown-extensions { };

  pytest-datadir = callPackage ./pytest-datadir { };

  rstb = callPackage ./rstb { };

  vdf = callPackage ./vdf { };
}
