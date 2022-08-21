{ lib
, buildGoPackage
, fetchFromGitHub
}:

buildGoPackage rec {
  pname = "signal-back";
  version = "0.1.6";

  goPackagePath = "github.com/xeals/signal-back";

  src = fetchFromGitHub {
    owner = "xeals";
    repo = "signal-back";
    rev = "v${version}";
    hash = "sha256-hcHP9C8iniPoS6wcmxl1kTjMnFvqGpFkXQX4Yw91+Kc=";
  };

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "Decrypt Signal instant messenger backups";
    homepage = "https://github.com/xeals/signal-back";
    license = licenses.asl20;
    maintainers = with maintainers; [ dschrempf ];
    platforms = platforms.all;
  };
}
