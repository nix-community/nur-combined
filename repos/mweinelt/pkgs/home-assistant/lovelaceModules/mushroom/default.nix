{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "mushroom";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "piitaya";
    repo = "lovelace-mushroom";
    rev = "refs/tags/v${version}";
    hash = "sha256-zAaYKDB0Z3Zqujf8AAPdsdx5WfBwHoIksQDKMynkjMQ=";
  };

  npmDepsHash = "sha256-kezPZnMmIJ8iPlajM03FPT/N4aUNTaKfOjR+7Dsxb18=";

  installPhase = ''
    mkdir $out
    install -m0644 dist/mushroom.js $out
  '';

  meta = with lib; {
    changelog = "https://github.com/piitaya/lovelace-mushroom/releases/tag/v${version}";
    description = "Mushroom Cards - Build a beautiful dashboard easily";
    homepage = "https://github.com/piitaya/lovelace-mushroom";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
