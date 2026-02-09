{
  fetchFromGitHub,
  fetchPnpmDeps,
  equicord,
  pnpm_10,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
  src = fetchFromGitHub (lib.helper.getSingle ver);
in
  equicord.overrideAttrs (old: {
    inherit (ver) version;
    inherit src;

    pnpmDeps = fetchPnpmDeps {
      inherit (old) pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 1;
      hash = "sha256-iBCA4G1E1Yw/d94pQzcbBGJYeIIgZI+Gw87/x4ogoyg=";
    };

    env =
      old.env
      // {
        EQUICORD_HASH = src.tag;
      };
  })
