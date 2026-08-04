{
  stdenv,
  lib,
  fetchFromGitHub,
  libX11,
  libXi,
  libXtst,
}:

stdenv.mkDerivation {
  pname = "xmouseless";
  version = "unstable-2023-06-24";

  src = fetchFromGitHub {
    owner = "jbensmann";
    repo = "xmouseless";
    rev = "ef4987e6358bcf956e0add652032e4e430d363a1";
    hash = "sha256-NMKMBDIdorcOM5pYE3XBw9XxxZ3tPWbdQeFc6PbYgE0=";
  };

  buildInputs = [
    libX11
    libXi
    libXtst
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "Replacement for the physical mouse in Linux";
    homepage = "https://github.com/jbensmann/xmouseless";
    licenses = licenses.gpl3Only;
    mainProgram = "xmouseless";
  };
}
