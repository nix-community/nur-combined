{ lib, stdenv, fetchFromSourcehut, bearssl, pkg-config, scdoc }:

stdenv.mkDerivation rec {
  pname = "gmni";
  version = "2021-04-02";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "e0993d4886e7e0b8970f7c83b6d0003e75f33348";
    hash = "sha256-mmyV+AkPAsQwpndt+JuiVMhgdjDahQTvASfaIL5/7SU=";
  };

  nativeBuildInputs = [ pkg-config scdoc ];

  buildInputs = [ bearssl ];

  meta = with lib; {
    description = "Gemini client";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
