{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-05-22";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "79bbaba90c92b65abb186880b6d5642227d57a71";
      hash = "sha256-Qa6T4cVZiKkVOl6nKJVKgZ9KeihWX0xVhRuDdF7Hyzw=";
    };

    vendorHash = "sha256-WzSUUgfWGz5XXq3iQrtpF91yOEr0QypTWq1rOJMntGQ=";

    passthru = (prev.passthru or { }) // {
      updateScript = nix-update-script {
        extraArgs = [
          "--commit"
          "--version=branch=main"
          "${final.pname}-unstable"
        ];
      };
    };

    meta = (prev.meta or { }) // {
      description = "${prev.meta.description} - main branch";
      changelog = "https://github.com/stephenafamo/bob/commits/${final.src.rev}/";
    };
  }
)
