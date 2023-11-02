{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "mushroom";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "piitaya";
    repo = "lovelace-mushroom";
    rev = "refs/tags/v${version}";
    hash = "sha256-dVwQZ7T2Hq7pXfvE1uvnmaRh9w2ZMeJ01sf/YvGMQUM=";
  };

  npmDepsHash = "sha256-dXVePzHRmdgh6vW2azC12W1Z/vY0wMod3tjTpvFLY8M=";

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
