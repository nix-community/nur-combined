{ stdenv, lib, buildGoPackage, fetchFromGitHub  }:

buildGoPackage rec {
  pname = "ko";
  name = "${pname}-${version}";
  version = "0.4.0";

  goPackagePath = "github.com/google/ko";

  src = fetchFromGitHub {
    owner = "google";
    repo = "ko";
    rev = "v0.4.0";
    sha256 = "0d9z83hi6xr00iskzd3vnb94sr1xn7639bxlj1mfmxcy8ch7aa4f";
  };

  meta = with stdenv.lib; {
    homepage    = https://github.com/google/ko;
    description = "Build and deploy Go applications on Kubernetes";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
