{
  golink,
  fetchFromGitHub,
  nix-update-script,
}:
golink.overrideAttrs (
  _finalAttrs: previousAttrs: {
    version = "1.0.0-unstable-2026-09-23";

    src = fetchFromGitHub {
      owner = "tailscale";
      repo = "golink";
      rev = "e034189e44e1d01c0672c401b038b8959d58aea6";
      hash = "sha256-lIt63F0a5AQNANln/ZtlpbMPNvqdEcutu2ybOT5vE6I=";
    };

    vendorHash = "sha256-Hyb4HtnkYCRzVQGzEDCylv9fQwtEuWG8bbxnIjnYIps=";

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
