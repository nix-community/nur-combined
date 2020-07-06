{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "ko";
  name = "${pname}-${version}";
  version = "0.5.1";

  goPackagePath = "github.com/google/ko";

  src = fetchFromGitHub {
    owner = "google";
    repo = "ko";
    rev = "v${version}";
    sha256 = "0vn1znn7490sxfk51z24r8hv09sn40xvvp98v5wr5s7xj7glyrsl";
  };

  meta = with stdenv.lib; {
    homepage = https://github.com/google/ko;
    description = "Build and deploy Go applications on Kubernetes";
    license = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
