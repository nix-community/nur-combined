{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-02-18";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "4d7ab7ca166350fd228041bf0079c8339841e413";
      hash = "sha256-Yz14aMtdM0cVAocI65bTqZlCiLKHtj99noKi7wJq3WY=";
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
