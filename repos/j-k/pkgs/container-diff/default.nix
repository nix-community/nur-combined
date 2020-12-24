{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "container-diff";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "GoogleContainerTools";
    repo = pname;
    rev = "v${version}";
    sha256 = "09kxqzhg8s40gzlq3mmf5gypilgpsydmfpzhsm1vfxxldbn7cxlg";
  };

  vendorSha256 = null;

  subPackages = [ "." ];

  buildFlagsArray = [
    "-ldflags="
    "-s"
    "-w"
    "-X github.com/GoogleContainerTools/${pname}/version.version=v${version}"
    "-X github.com/GoogleContainerTools/${pname}/version.gitVersion="
  ];

  doCheck = false;

  meta = with lib; {
    description = "container-diff: Diff your Docker containers";
    homepage = src.meta.homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
