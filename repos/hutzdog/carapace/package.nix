{ lib, buildGo118Module, fetchFromGitHub }:


buildGo118Module rec {
  pname = "carapace-bin";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "rsteube";
    repo = "carapace-bin";
    rev = "v${version}";
    sha256 = "0cyoo2X2QvZfpjLFtNV2JicdbiiIiNFHysQaMGa34k4=";
  };

  preBuild = ''
    go generate ./cmd/...
  '';
  subPackages = ["cmd/..."];
  vendorSha256 = "+SFnR+vESUwlwFfEnQtw1luiC0aqYIsWpb2QDWXl5bM=";

  meta = with lib; {
    description = "Multi-shell multi-command argument completer";
    homepage = "https://github.com/rsteube/carapace-bin";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
