{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "chlink";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "BernardoGiordano";
    repo = "Checkpoint";
    tag = "v${version}";
    hash = "sha256-iSbMmYob00wVpkHAcNNACxeV3NAbwciVfQ1D82eUUGU=";
  };
  
  sourceRoot = "source/tools/chlink";

  vendorHash = null;

  meta = with lib; {
    description = "Companion PC CLI for Checkpoint's wireless save transfer";
    homepage = "https://github.com/BernardoGiordano/Checkpoint";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    mainProgram = "chlink";
  };
}
