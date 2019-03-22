{ stdenv, lib, buildGoPackage, fetchFromGitHub  }:

buildGoPackage rec {
  pname = "ko";
  name = "${pname}-${version}";
  version = "0.1";

  goPackagePath = "github.com/google/ko";

  src = fetchFromGitHub {
    owner = "google";
    repo = "ko";
    rev = "v${version}";
    sha256 = "1sn1s6784jb5p6q43nb87qs19hx3s4gnin59ava9mzw3n6p0bihc";
  };

  meta = with stdenv.lib; {
    homepage    = https://github.com/google/ko;
    description = "Build and deploy Go applications on Kubernetes";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
