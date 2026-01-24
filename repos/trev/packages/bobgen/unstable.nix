{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-01-23";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "8437224ce2d99b549bf5f9031e324972bc993dfc";
      hash = "sha256-sh4sIwOYPilAR/qU7MLFvQLItfLs1dFgWnY0Uaf25gw=";
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
