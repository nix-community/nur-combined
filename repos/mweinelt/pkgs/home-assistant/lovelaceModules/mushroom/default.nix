{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "mushroom";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "piitaya";
    repo = "lovelace-mushroom";
    rev = "refs/tags/v${version}";
    hash = "sha256-9zNSs4fL4vbMhr8xQY7hocMlDWOsGJIBqXQ5KaaAG3U=";
  };

  npmDepsHash = "sha256-JKlFGE4WO4rOV0lGvXvxfcubtpAOfGloWJDtzrXpZFE=";

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
