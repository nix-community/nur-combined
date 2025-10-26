{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "mushroom";
  version = "5.0.8";

  src = fetchFromGitHub {
    owner = "piitaya";
    repo = "lovelace-mushroom";
    rev = "7f3e7ec840462240ada9e5aa02a2c1151e7a39ba";
    hash = "sha256-EMKGf/oULS1aqaNWvw2aDxiY8jq3WihwLy1uVW4KeBU=";
  };

  npmDepsHash = "sha256-QL0JxHsf6QcP/s+5ZCFei7kv/avhoUWoz/7tqkvW0aQ=";

  installPhase = ''
    mkdir $out
    install -m0644 dist/mushroom.js $out
  '';

  passthru = {
    entrypoint = "mushroom.js";
  };

  meta = with lib; {
    changelog = "https://github.com/piitaya/lovelace-mushroom/releases/tag/v${version}";
    description = "Mushroom Cards - Build a beautiful dashboard easily";
    homepage = "https://github.com/piitaya/lovelace-mushroom";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}