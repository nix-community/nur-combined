{
  buildGoModule,
  fetchFromGitHub,
  lib,
  stdenv,
}:
buildGoModule rec {
  pname = "get-authkey";
  # latest version that builds on last stable
  version = "1.78.1";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${version}";
    sha256 = "sha256-HHLGvxB3MMmmOUNLr2ivouLDO/Lo2FJYRYzoCE2fUDk=";
  };

  vendorHash = "sha256-0VB7q9HKd5/QKaWBMpCYycRRiNTWCEjUMc3g3z6agc8=";

  subPackages = ["cmd/get-authkey"];

  meta = with lib; {
    description = "Allocates an authkey using an OAuth API client and prints it to stdout for scripts to capture and use.";
    homepage = "https://pkg.go.dev/tailscale.com/cmd/get-authkey";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}
