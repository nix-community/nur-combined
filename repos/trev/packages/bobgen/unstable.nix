{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.45.0-unstable-2026-06-02";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "c18ba1cb05012ac359b6ccbad74b8a138019c577";
      hash = "sha256-HkvYfijC242OQZvsPhVrCZzCWMN0afasGXwtBuUl+L4=";
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
