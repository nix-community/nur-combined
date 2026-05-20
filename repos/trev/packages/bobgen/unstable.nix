{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-05-19";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "676e5f1fa88c2fca0ebe0a4f16de94196aa5b96b";
      hash = "sha256-7tqbgTaxcsIAk11tJ+sOVY1NOFEvxiO9wZtwsMj7boM=";
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
