{ stdenv, lib, fetchFromGitHub, libX11, libXi, libXtst }:

stdenv.mkDerivation {
  pname = "xmouseless";
  version = "unstable-22-07-17";

  src = fetchFromGitHub {
    owner = "jbensmann";
    repo = "xmouseless";
    rev = "19537edd0695bb1605efcf532bd239e4a99da972";
    sha256 = "sha256-Y5z+Trzoe6EvG8PmKjD5wDNi7nkP57wlqjjN8q2+gLo=";
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
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
