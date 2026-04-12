{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-04-11";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "c4319ea563dd19d5886496e7bd993750d45e6d4a";
      hash = "sha256-qUjVP9qVTxVCdZv4rJ7H4kC+JfI5pBCtmGLzWTXHixA=";
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
