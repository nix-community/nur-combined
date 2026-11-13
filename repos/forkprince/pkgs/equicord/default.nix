{
  fetchFromGitHub,
  fetchPnpmDeps,
  equicord,
  pnpm_11,
  lib,
  ...
}: let
  version = "2026-11-13";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = version;
    hash = "sha256-KKkjr8jFvUZc1HhK+0DH24OV4odEAC82/57oAOinQ1A=";
  };

  # TODO: Once 26.11 drops remove the fixup.
  pnpmDeps =
    (fetchPnpmDeps {
      inherit (equicord) pname;
      inherit version src;
      pnpm = pnpm_11;
      fetcherVersion = 4;
      hash = "sha256-rFxPEG/BvWUnI+nu1IAZAJxye6MRkoOGS9Afj2ksRK0=";
    }).overrideAttrs (old: {
      fixupPhase =
        lib.replaceStrings [
          ''rm "$storePath/v11/index.db"''
        ] [
          ''
            rm "$storePath/v11/index.db"
            sed -i "s/,x'/,X'/g" "$storePath/v11/index.db.sql"
          ''
        ] (old.fixupPhase or "");
    });
in
  equicord.overrideAttrs (old: {
    inherit version src pnpmDeps;

    nativeBuildInputs = map (input:
      if builtins.isAttrs input && builtins.match "pnpm(_[0-9]+)?" (input.pname or "") != null
      then pnpm_11
      else input)
    (old.nativeBuildInputs or []);

    env =
      old.env
      // {
        EQUICORD_HASH = src.tag;
      };

    passthru =
      (old.passthru or {})
      // {
        inherit pnpmDeps;
      };
  })
