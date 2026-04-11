{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-04-10";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "ce9f085c8e3cb3beb3ec919d9c362bb9c49a4c7b";
      hash = "sha256-CiTepia9RAADSyYrceS3b6MaN6lvwBDU+PxgqlSTGPM=";
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
