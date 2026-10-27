{
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  equicord,
  pnpm_12,
  ...
}: let
  version = "1.15.13.0";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = "v${version}";
    hash = "sha256-tNDfbq1jWW9mpHY2psUkomTApp7A1sBKvZHx7YWWKd4=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (equicord) pname;
    inherit version src;
    pnpm = pnpm_12;
    fetcherVersion = 5;
    hash = "sha256-X4muYcEHXLquPb+ORoU1DdMCiJRLlU5Oywn1VCx0R7s=";
  };
in
  equicord.overrideAttrs (old: {
    inherit version src pnpmDeps;

    nativeBuildInputs = map (input:
      if builtins.isAttrs input && builtins.match "pnpm(_[0-9]+)?" (input.pname or "") != null
      then pnpm_12
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
        updateScript = nix-update-script {
          extraArgs = [
            "--version-regex"
            "^v(\\d+\\.\\d+\\.\\d+\\.\\d+)$"
          ];
        };
      };
  })
