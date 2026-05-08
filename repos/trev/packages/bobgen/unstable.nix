{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.43.0-unstable-2026-05-08";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "d700087f2fdc7e1ed4c99ae1874ce9eb72c55cb0";
      hash = "sha256-igfewPE4/JHPIIlm/SBMEX+cXQlMBXuka1YOBXwEbWc=";
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
