{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-02-06";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "054d6b9081cdf049aac6c651937eff9f47879582";
      hash = "sha256-SZX+Lqq7gDjeALptGgprP1bLuzJ70ZtJYZb4NHFeyV0=";
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
