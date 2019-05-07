{ callPackage, lib, fetchFromGitHub
, coreutils, direnv, which
, ... } @ args:

let
  generic = import ./generic.nix;
  genericArgs = lib.attrNames (lib.functionArgs generic);
  oArgs = lib.filterAttrs (a: _: lib.elem a genericArgs) args;
in (callPackage ./generic.nix ({
  pname = "lorri-unstable";
  version = "2019-04-29";

  # master branch
  src = fetchFromGitHub {
    owner = "target";
    repo = "lorri";
    rev = "d4af845fa4ba4243d57ea8d9a3600ec3c82b5476";
    sha256 = "0bdysnvl4i4g3hfp333i5q82sc7vdh23rzh8nfnr3mysw853v7rq";
  };

  cargoSha256 = "0lx4r05hf3snby5mky7drbnp006dzsg9ypsi4ni5wfl0hffx3a8g";
} // oArgs)).overrideAttrs (o: {
  buildInputs = o.buildInputs ++ [ direnv which ];

  COREUTILS = coreutils;
  USER = "bogus";

  preConfigure = ''
    source ${o.src + "/nix/pre-check.sh"}

    # Do an immediate, light-weight test to ensure logged-evaluation
    # is valid, prior to doing expensive compilations.
    nix-build --show-trace ./src/logged-evaluation.nix \
      --arg src ./tests/direnv/basic/shell.nix \
      --arg coreutils "$COREUTILS" --no-out-link
  '';
})
