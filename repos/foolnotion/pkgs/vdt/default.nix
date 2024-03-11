{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "vdt";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "foolnotion";
    repo = "vdt";
    rev = "f23b87bbebdbac0a3e53d5e560c3d5f68790ea83";
    hash = "sha256-DElmGB4TzmrOm3ZoV/8hE8Ap53hd6frXYMQMKmlGanc=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A collection of fast and inline implementations of mathematical functions";
    homepage = "https://github.com/dpiparo/vdt";
    license = licenses.gpl3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
