{
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  equicord,
  pnpm_10,
  ...
}: let
  version = "2026-04-23";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = version;
    hash = "sha256-jeeND89z3qt11N9nn+vS8CsalY4oGsSHcGtY0FM0OmQ=";
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
