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
  version = "2026-09-01";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = version;
    hash = "sha256-8n9Ld5qBqTs1S6GHGCa13hIzrExvuaky3CmqkxwAh0E=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (equicord) pname;
    inherit version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-rx8z6PAlAPaZbkmg+3Vvq8OXR/yy5ZP0PmAk97ZDOSQ=";
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
