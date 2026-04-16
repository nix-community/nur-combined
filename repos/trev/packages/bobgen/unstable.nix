{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-04-14";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "e84c7f4903c1f5b7a78f0f2b2050f9a4fbfbb468";
      hash = "sha256-3KY2t4CsfC9w7zAb/FEleMX9p3nUDKNNAp5BnaEk9o8=";
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
