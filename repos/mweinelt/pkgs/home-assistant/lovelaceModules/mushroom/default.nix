{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "mushroom";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "piitaya";
    repo = "lovelace-mushroom";
    rev = "refs/tags/v${version}";
    hash = "sha256-cOXpmS2c3s+2T9POniPIJ5R6NVAxiyTNf/oKNUp8IbY=";
  };

  npmDepsHash = "sha256-U27D6yE4ygCdG9g2j5NLj6a02tiUXJ7ncx+20LdBs3A=";

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
