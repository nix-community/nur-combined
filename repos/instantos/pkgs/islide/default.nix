{ lib
, stdenv
, fetchFromGitHub
, gnumake
, instantAssist
, libX11
, libXft
, libXinerama
}:
stdenv.mkDerivation {

  pname = "islide";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "islide";
    rev = "77d976ba9b9a71601aa34248a06e8c983b13fb5f";
    sha256 = "sha256-BxD/GQMu2XgeeZotrdAf0hp+iXPS4KotvNixeXWg0FE=";
    name = "instantOS_islide";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr/" "PREFIX = $out"
    substituteInPlace islide.c \
      --replace /usr/share/instantassist/assists "${instantAssist}/share/instantassist/assists" \
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = [ libX11 libXft libXinerama ];

  propagatedBuildInputs = [ instantAssist ];

  meta = with lib; {
    description = "instantOS Slide";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/islide";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
