{
  attic-client,
  fetchFromGitHub,
  rustPlatform,
  ...
}@args:

let
  overrideArgs = builtins.removeAttrs args [
    "attic-client"
    "fetchFromGitHub"
    "rustPlatform"
  ];
in
(attic-client.override overrideArgs).overrideAttrs (
  finalAttrs: _prevAttrs: {
    src = fetchFromGitHub {
      owner = "XYenon";
      repo = "attic";
      rev = "2cf5a731d22643c68a8e5ca083fc8d171830a99f";
      hash = "sha256-KCMM3iWikLAkN1cHv/W5lgZlZTwAypN/qAvCRa0G+Uw=";
    };

    cargoHash = "sha256-wDHi/CtPgTYNF/qdWgDe20tB57w+o9GPWSug+dY1MuE=";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src;
      hash = finalAttrs.cargoHash;
    };
  }
)
