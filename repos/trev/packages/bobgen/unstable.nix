{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-05-25";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "24e585f7dd2ac28597ce92da72c93b123df6de6a";
      hash = "sha256-YsnfJflR6Wk6tu8mZvBbpWcaZHy+GyItNYLtXPmKrr8=";
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
