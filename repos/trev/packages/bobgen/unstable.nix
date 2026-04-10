{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-04-05";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "50353154d23970235c43264d6c704f56b246b254";
      hash = "sha256-IGZWtnkGVEkjC/N9GtTykBcsJsnvwZYAvxmA30UYSq0=";
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
