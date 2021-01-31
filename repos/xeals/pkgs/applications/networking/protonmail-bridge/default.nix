{ stdenv
, lib
, fetchFromGitHub
, buildGoModule

, go
, goModules
, libsecret
, pkg-config
, qtbase
, qtdoc
}:
let
  builder = import ./common.nix {
    inherit lib fetchFromGitHub buildGoModule libsecret pkg-config;
  };
in
{
  protonmail-bridge = builder (import ./app.nix { inherit qtbase go goModules; });
  protonmail-bridge-headless = builder (import ./headless.nix { });
}
