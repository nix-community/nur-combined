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
  equicord.overrideAttrs (old: rec {
    inherit (ver) version;
    inherit src;

    pnpmDeps = fetchPnpmDeps {
      inherit (old) pname;
      inherit version src;
      pnpm = pnpm_10;
      fetcherVersion = 1;
      hash = ver.pnpmHash or "";
    };

    env =
      old.env
      // {
        EQUICORD_HASH = src.tag;
      };
  })
