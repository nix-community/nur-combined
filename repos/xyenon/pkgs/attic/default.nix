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
      rev = "47bdd7bc914fb505de71302aab2408d519479e66";
      hash = "sha256-Y2c65ylVTitJ0N2u13n9QXcOv0BIGRsMkb+RByqa83Y=";
    };

    cargoHash = "sha256-rq07TK8ilDq3/YdC22uSerxcRUgEJi/0jgamKfGJW7w=";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src;
      hash = finalAttrs.cargoHash;
    };
  }
)
