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
      rev = "fe8e54d6b1d12cd0a6fcc96814ed30c1d5dcdcc5";
      hash = "sha256-1QNnCu5fxSk969CHC+uwfbRZjpOhHLV1RIuFtYRioHo=";
    };

    cargoHash = "sha256-hoI/TszgyLQttthVHRZkLmAPQVgLKFMDg3oKk5rEsSU=";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src;
      hash = finalAttrs.cargoHash;
    };
  }
)
