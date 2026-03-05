{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-03-05";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "d9c40b0abeddf4b5a70473baa509e9119a63ba3c";
      hash = "sha256-N7wgNu5BJg2oT3I4XXFtgkMiZmoaiVqsaXgejw/hNY0=";
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
