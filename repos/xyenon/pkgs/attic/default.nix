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
      rev = "eadcab9f8f318df14034d7c986e66cd8214131c4";
      hash = "sha256-k4Lipy8plmFeMMPYqg9IH3vPuZXJ6jr/kuyDKvjvLBc=";
    };

    cargoHash = "sha256-hoI/TszgyLQttthVHRZkLmAPQVgLKFMDg3oKk5rEsSU=";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src;
      hash = finalAttrs.cargoHash;
    };
  }
)
