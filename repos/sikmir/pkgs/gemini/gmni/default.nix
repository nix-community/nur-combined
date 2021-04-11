{ lib, stdenv, fetchFromSourcehut, bearssl, pkg-config, scdoc }:

stdenv.mkDerivation rec {
  pname = "gmni";
  version = "2021-04-02";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "e0993d4886e7e0b8970f7c83b6d0003e75f33348";
    sha256 = "09gdgyz21ni707ph91fs61v61j2lladzhvbplqqc80hg17w9av4s";
  };

  nativeBuildInputs = [ pkg-config scdoc ];

  buildInputs = [ bearssl ];

  meta = with lib; {
    description = "Gemini client";
    homepage = "https://git.sr.ht/~sircmpwn/gmni";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
