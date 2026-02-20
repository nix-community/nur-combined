{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-02-20";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "4d86d6fb6efb444b56ff858382897f5f1a33c85d";
      hash = "sha256-x1o/nZo6QRkFMYrfUxNPt2qXClqjT5rwr07e7e2aohg=";
    };

    vendorHash = "sha256-WzSUUgfWGz5XXq3iQrtpF91yOEr0QypTWq1rOJMntGQ=";

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--commit"
        "--version=branch=main"
        "${final.pname}.unstable"
      ];
    };

    meta = prev.meta // {
      description = "${prev.meta.description} - main branch";
      changelog = "https://github.com/stephenafamo/bob/commits/${final.src.rev}/";
    };
  }
)
