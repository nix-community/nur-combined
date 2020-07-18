{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, instantUtils
}:
stdenv.mkDerivation {

  pname = "instantMenu";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantMENU";
    rev = "1d88b332fb51e6d55fe10961a1b895613c838201";
    sha256 = "04cv7iwqyy3z5c1c6hkfyq4d2xsh0cphy7lrm2l05c8z8g2wqrq5";
    name = "instantOS_instantMenu";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr" "PREFIX = $out"
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];
  propagatedBuildInputs = [ instantUtils ];

  meta = with lib; {
    description = "basic menu for instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
