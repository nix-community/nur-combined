{ lib
, fetchFromGitHub
, rustPlatform
, buildRustPackage ? rustPlatform.buildRustPackage
,
}:
buildRustPackage rec {
  pname = "neocities-deploy";
  version = "0.1.23";
  src = fetchFromGitHub {
    owner = "kugland";
    repo = "neocities-deploy";
    rev = "v${version}";
    hash = "sha256-3MxtsImRIErWhNBVBtXew4l6kcfqQ9xl0BGTSoIzncA=";
  };
  cargoHash = "sha256-hSUDxYkHFVbl2SJUBR7cqPgcDxEDQNq+Yhbqn2wDrhw=";
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
