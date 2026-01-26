{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-01-24";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "e9f809880659f77dce5ffe48442183a4679c9784";
      hash = "sha256-1xABLfOQAs9jv4S2G1w0UTJ5wjfc2mi3uYuR3ycxHsA=";
    };

    vendorHash = "sha256-WzSUUgfWGz5XXq3iQrtpF91yOEr0QypTWq1rOJMntGQ=";

    passthru = {
      updateScript = lib.concatStringsSep " " (nix-update-script {
        extraArgs = [
          "--commit"
          "--version=branch=main"
          "${final.pname}.unstable"
        ];
      });
    };

    meta = prev.meta // {
      description = "${prev.meta.description} - main branch";
      changelog = "https://github.com/stephenafamo/bob/commits/${final.src.rev}/";
    };
  }
)
