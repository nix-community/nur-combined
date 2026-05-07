{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
}:

bobgen.overrideAttrs (
  final: prev: {
    version = "0.43.0-unstable-2026-05-06";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "316333a7411ba20f6b4af7da55adf0795d69c66b";
      hash = "sha256-hZ4fq3meGrTwv2d/qkpBR3Rz82sUqyk9yT05l2sFRX4=";
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
