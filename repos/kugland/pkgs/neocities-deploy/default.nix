{ pkgs
, lib
, fetchFromGitHub
, rustPlatform
, buildRustPackage ? rustPlatform.buildRustPackage
,
}:
buildRustPackage rec {
  pname = "neocities-deploy";
  version = "0.1.13";
  src = fetchFromGitHub {
    owner = "kugland";
    repo = "neocities-deploy";
    rev = "v${version}";
    hash = "sha256-Ax1xmNyt+Gymk28p9lXh+CV17rWjMBKIZtc+nthic+8=";
  };
  cargoHash = "sha256-R6TTB+TXA44vp+7454fu9/5bscgNao0wuskdgpA2BwY=";
  meta = with lib; {
    description = "A command-line tool for deploying your Neocities site";
    homepage = "https://github.com/kugland/neocities-deploy";
    license = licenses.gpl3;
    maintainers = [ ];
  };
}
