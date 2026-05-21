{
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  equicord,
  pnpm_10,
  ...
}: let
  version = "2026-05-21";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = version;
    hash = "sha256-x5h9KuAGfgJhmMbISgDTnN/J0hQ9l4T05e8mm/gvUm4=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (equicord) pname;
    inherit version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-RwppRWrEzIKZDb3QLVAMd1bHXyFwiatYNiNccVgrcWA=";
  };
in
  equicord.overrideAttrs (old: {
    inherit version src pnpmDeps;

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
