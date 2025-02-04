{
  lib,
  stdenv,
  fetchFromGitLab,
}:

stdenv.mkDerivation rec {
  pname = "rstmcpp";
  version = "unstable-2023-04-02";

  src = fetchFromGitLab {
    owner = "beelzy";
    repo = pname;
    rev = "fe8bee01a5009997ec23e7599cafc1b2bdfad364";
    hash = "sha256-T9mxTBj/eykvbBkbmEKTUFldtBp3cJgWAbeu44SwxiM=";
    fetchSubmodules = true;
  };

  # fixes clang
  patches = [ ./include-stdio.patch ];

  makeFlags = [
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp rstmcpp${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  meta = with lib; {
    description = "An experimental port of BrawlLib's RSTM encoder, and the WAV file handling from LoopingAudioConverter, to C++.";
    homepage = "https://gitlab.com/beelzy/rstmcpp";
    license = licenses.bsd0;
    platforms = platforms.all;
    mainProgram = "rstmcpp";
  };
}
