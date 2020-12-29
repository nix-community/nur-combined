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
    rev = "39d214e0ceab393236d8c6e54305d70659054a2a";
    sha256 = "sha256-IbPRnrXOzq7tSiXFgUhPYph3eufeIVxqWl/WG3UkTmg=";
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
