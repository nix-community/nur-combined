{ pkgs
, stdenv
, src
, version
}:

let
  nodeComposition = import ./composition.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
  };
in
nodeComposition.package.override {
  pname = "betanin";
  inherit version;
  src = "${src}/betanin_client";

  postInstall = ''
    PRODUCTION=true npm run-script build
  '';
}
