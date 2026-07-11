# NOTE: Applied a dirty patch while either nixpkgs or equicord fixes the pnpm lock issue
# Hopefully we can remove this patch once the issue is resolved (il check everyday)
{
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  equicord,
  pnpm_10,
  ...
}: let
  version = "2026-07-11";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = version;
    hash = "sha256-noA8iw7cixzNH3ZherQiEr2CXMpU+XR3vSxk3gldx1E=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (equicord) pname;
    inherit version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-dcBFN5NxFzZVWW8L3Cnvcp3LFR0WF4Ff5+I1H5XgZ3Q=";
    prePnpmInstall = ''
      yq -yi '.patchedDependencies = {"@types/less@3.0.8": {"hash": "641e6c93bb737bac7fc283416857bd095cd85bcbcba63becb7a8bbcc78f73076", "path": "patches/@types__less@3.0.8.patch"}}' pnpm-lock.yaml
    '';
  };
in
  equicord.overrideAttrs (old: {
    inherit version src pnpmDeps;

    patchPhase = ''
      sed \
        -e "/@types\\/less@3\\.0\\.8[^:]*: [a-f0-9]/s/': .*/':/" \
        -e "/@types\\/less@3\\.0\\.8[^:]*':\$/a\\    hash: 641e6c93bb737bac7fc283416857bd095cd85bcbcba63becb7a8bbcc78f73076" \
        -e "/@types\\/less@3\\.0\\.8[^:]*':\$/a\\    path: patches/@types__less@3.0.8.patch" \
        pnpm-lock.yaml > pnpm-lock.yaml.tmp
      mv pnpm-lock.yaml.tmp pnpm-lock.yaml
    '';

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
