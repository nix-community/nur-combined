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
      rev = "97b413598b59266aa3596e9967e5df6ad819865f";
      hash = "sha256-otbWzGn1ZKOVIyLVIAL4yOJv0+tRQl2Q30O5q4b00aA=";
    };

    cargoHash = "sha256-qNhhH6W2AlcIxM3ruyVqzubWhkS2vPJE7S86wYWvo44=";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src;
      hash = finalAttrs.cargoHash;
    };
  }
)
