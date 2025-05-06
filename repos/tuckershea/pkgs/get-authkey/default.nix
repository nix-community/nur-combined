{
  buildGoModule,
  fetchFromGitHub,
  lib,
  stdenv,
}:
buildGoModule rec {
  pname = "get-authkey";
  version = "1.82.5";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${version}";
    sha256 = "sha256-BFitj8A+TfNKTyXBB1YhsEs5NvLUfgJ2IbjB2ipf4xU=";
  };

  vendorHash = "sha256-SiUkN6BQK1IQmLfkfPetzvYqRu9ENK6+6txtGxegF5Y=";

  subPackages = ["cmd/get-authkey"];

  meta = with lib; {
    description = "Allocates an authkey using an OAuth API client and prints it to stdout for scripts to capture and use.";
    homepage = "https://pkg.go.dev/tailscale.com/cmd/get-authkey";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}
