{
  golink,
  fetchFromGitHub,
  nix-update-script,
}:
golink.overrideAttrs (
  _finalAttrs: previousAttrs: {
    version = "1.0.0-unstable-2026-08-20";

    src = fetchFromGitHub {
      owner = "tailscale";
      repo = "golink";
      rev = "3f9300f2b03f29f1a2eb704ff419d849f47aabf4";
      hash = "sha256-RUS9EtnG0VwRzOV0a0f8vC1nxpjSRONSHdLaQ2Z5aUE=";
    };

    vendorHash = "sha256-V6ko9wBp1pRY00l3EynnAFf5JlM/BQTA6hctXlWMnRI=";

    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script {
        extraArgs = [
          "--version=branch"
          "--override-filename"
          "pkgs/tailscale/golink.nix"
        ];
      };
    };
  }
)
