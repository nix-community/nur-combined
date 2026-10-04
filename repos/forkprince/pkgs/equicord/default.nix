{
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  equicord,
  pnpm_11,
  ...
}: let
  version = "2026-10-04";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = version;
    hash = "sha256-utAAobxSmcmM8ZiM0y6E5OtvEpKDOtq5eP3KSu22saM=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (equicord) pname;
    inherit version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-hBZHHB5kRkNqep5vWMMnwIblNCAOZvLotDjJUJd9iMU=";
  };
in
  equicord.overrideAttrs (old: {
    inherit version src pnpmDeps;

    nativeBuildInputs = map (input:
      if builtins.isAttrs input && (input.pname or "") == "pnpm"
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
        updateScript = nix-update-script {
          extraArgs = [
            "--version-regex"
            "^(\\d{4}-\\d{2}-\\d{2})$"
          ];
        };
      };
  })
