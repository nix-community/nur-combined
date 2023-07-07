{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "mushroom";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "piitaya";
    repo = "lovelace-mushroom";
    rev = "refs/tags/v${version}";
    hash = "sha256-2qYWwF2Et+8/xmqwyRr6JgrzK/BQua/KduXzlD89GCY=";
  };

  npmDepsHash = "sha256-6n1zk4PtfX4Ju+U2qMmGDstuwpRQOkH8IG15j7QhyQw=";

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
