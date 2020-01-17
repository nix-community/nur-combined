{ stdenv, lib, buildGoPackage, fetchFromGitHub  }:

buildGoPackage rec {
  pname = "ko";
  name = "${pname}-${version}";
  version = "dev";

  goPackagePath = "github.com/google/ko";

  src = fetchFromGitHub {
    owner = "google";
    repo = "ko";
    rev = "2e28671384daf65cbb9fd7fbf0488ae2900c3ae5";
    sha256 = "00l141sgx64qv7mpy40qm4a29pm9qqxg7k7d1gj3g8qq6j0n7ks1";
  };

  meta = with stdenv.lib; {
    homepage    = https://github.com/google/ko;
    description = "Build and deploy Go applications on Kubernetes";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
