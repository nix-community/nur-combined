{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-05-21";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "3a2d784792208c5a0fe8963efb4a1ebb25e528a6";
      hash = "sha256-dr+yrmKp5yZD9TZl2/6lgkTOz0KjQXnahgeay2gSSx0=";
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
