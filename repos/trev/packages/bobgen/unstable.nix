{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.43.0-unstable-2026-05-05";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "b4f99edf899c59ceb542946dfe5d8f6ebfd25b5d";
      hash = "sha256-t4UIuCnh07LlUxwuMbpFq9GZX5UaPokBgPF4bgjumwo=";
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
