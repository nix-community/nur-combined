# NOTE: Applied a dirty patch while either nixpkgs or equicord fixes the pnpm lock issue
# Hopefully we can remove this patch once the issue is resolved
{
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  equicord,
  pnpm_10,
  ...
}: let
  version = "2026-07-20";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = version;
    hash = "sha256-dHm/Gp/Gd1Bwnu2jGoCmtOpeZ5fJyHLlj5/YIi3zZ3g=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (equicord) pname;
    inherit version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-WdSowp/yuPokdU7Sv/XBQOo/0JPs9AA5LRq6dx57Uyk=";
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
