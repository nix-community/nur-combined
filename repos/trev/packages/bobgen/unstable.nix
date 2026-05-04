{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.43.0-unstable-2026-05-04";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "dec1f39cd58eb78bfab0b38473ee11ce22f3395f";
      hash = "sha256-kJm8Uh6K17PL5/O03510C8tSvoH+Ku6JwZIAF2ipN+w=";
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
