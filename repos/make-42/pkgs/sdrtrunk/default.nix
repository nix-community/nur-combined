{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "sdrtrunk";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "DSheirer";
    repo = "sdrtrunk";
    rev = "v${version}";
    hash = "sha256-5cklAqO7KyDdkQM0fCZTT8DHsZx/Tf0c8B9TiLMLrkA=";
  };

  meta = {
    description = "A cross-platform java application for decoding, monitoring, recording and streaming trunked mobile and related radio protocols using Software Defined Radios (SDR).  Website";
    homepage = "https://github.com/DSheirer/sdrtrunk";
    changelog = "https://github.com/DSheirer/sdrtrunk/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [];
    mainProgram = "sdrtrunk";
    platforms = lib.platforms.all;
  };
}
