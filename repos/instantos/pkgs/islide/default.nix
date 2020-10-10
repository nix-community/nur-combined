{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, instantAssist
}:
stdenv.mkDerivation {

  pname = "islide";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "islide";
    rev = "ce0ae756a60045b2215386fce9e8c87c0fc72c12";
    sha256 = "1dbkb6b1a87nbrlc487pr811wk1k2n39a1avx07j1kbdn8ic9ih6";
    name = "instantOS_islide";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr/" "PREFIX = $out"
    substituteInPlace islide.c \
      --replace /usr/share/instantassist/assists "${instantAssist}/share/instantassist/assists" \
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];

  propagatedBuildInputs = [ instantAssist ];

  meta = with lib; {
    description = "instantOS Slide";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/islide";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
