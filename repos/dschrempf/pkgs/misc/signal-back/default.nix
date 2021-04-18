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
    sha256 = "19zqfl7n7y05bmj926pabffcqf4iflcrn75c9gl277i25zsczhc5";
  };

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "Decrypt Signal instant messenger backups";
    homepage = "https://github.com/xeals/signal-back";
    # TODO: Change to dschrempf from Nixpkgs.
    license = licenses.asl20;
    maintainers = with maintainers; [ dschrempf ];
    platforms = platforms.all;
  };
}
