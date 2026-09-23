{
  golink,
  fetchFromGitHub,
  nix-update-script,
}:
golink.overrideAttrs (
  _finalAttrs: previousAttrs: {
    version = "1.0.0-unstable-2026-09-22";

    src = fetchFromGitHub {
      owner = "tailscale";
      repo = "golink";
      rev = "6ee915b34f81fed9310c2d63bdcd7c5134abe4ed";
      hash = "sha256-xSKk1WHQdMTxhooovpD4J5sucIhO1BRNStChRSS+aI0=";
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
