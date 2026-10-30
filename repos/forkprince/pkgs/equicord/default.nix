{
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  equicord,
  pnpm_10,
  pnpm_10_latest ? pnpm_10,
  ...
}: let
  version = "1.15.14.0";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = "v${version}";
    hash = "sha256-ijNxC/uR3Wy4JX/6qNnNGQwS5752+vK2T26N1bsLeG4=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (equicord) pname;
    inherit version src;
    pnpm = pnpm_10_latest;
    fetcherVersion = 3;
    hash = "sha256-vwGHq4chumYcdmiNcAh49bxErVv7GuxCnIyzgXO5pOE=";
  };
in
  equicord.overrideAttrs (old: {
    inherit version src pnpmDeps;

    nativeBuildInputs = map (input:
      if builtins.isAttrs input && builtins.match "pnpm(_[0-9]+)?" (input.pname or "") != null
      then pnpm_10_latest
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
