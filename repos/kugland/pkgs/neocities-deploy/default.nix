{ lib
, fetchFromGitHub
, rustPlatform
, buildRustPackage ? rustPlatform.buildRustPackage
,
}:
buildRustPackage rec {
  pname = "neocities-deploy";
  version = "0.1.24";
  src = fetchFromGitHub {
    owner = "kugland";
    repo = "neocities-deploy";
    rev = "v${version}";
    hash = "sha256-53kfPjZR1xDfg6izJURwg2M9ITqavidaIVgcqpvoQv0=";
  };
  cargoHash = "sha256-4wBKq4GK5Yz+nUsRokNy5ysPhHN05GFgReBPhjo7mWA=";
  doCheck = false;
  meta = with lib; {
    description = "A command-line tool for deploying your Neocities site";
    homepage = "https://github.com/kugland/neocities-deploy";
    license = licenses.gpl3;
    maintainers = with maintainers; [ kugland ];
    mainProgram = "neocities-deploy";
    platforms = platforms.all;
  };
}
