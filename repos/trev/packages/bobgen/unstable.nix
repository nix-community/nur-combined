{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-05-17";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "079618b95342a9ea7b987315434c27eb9ae69d99";
      hash = "sha256-f/Uaad7//6+GhJu8iIE3THwftR+s0hULYvGSQNb6OlU=";
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
