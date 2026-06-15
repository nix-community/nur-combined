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
      rev = "74a031aaad1934e1b699ff6323a99a444ad7df0f";
      hash = "sha256-OUg9IulCDk02L6ZRFFAE3uAJnJvwVtKWH/+MZrs3A6Q=";
    };

    cargoHash = "sha256-HJy7aqMzy7+uJTtRbjhp3cXMHaxIwSQoiUoqx5fNaZc=";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src;
      hash = finalAttrs.cargoHash;
    };
  }
)
