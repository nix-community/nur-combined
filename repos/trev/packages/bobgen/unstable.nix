{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.43.0-unstable-2026-04-29";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "bd793b041e164727e1d657e4eab9deceb43ab914";
      hash = "sha256-QB4HOh8Xq5s1FwGlqtOffiw9UlOYe9CI85+rv/jWtlU=";
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
