{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
}:
stdenv.mkDerivation rec {

  pname = "InstantMENU";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantMENU";
    rev = "master";
    sha256 = "1w1phfddyaxd1p1siihfm0l47kcra2ib43wwyla6svdyg844z9b5";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr" "PREFIX = $out"
    patchShebangs theme.sh
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];

  configurePhase = ''
    ./theme.sh    
  '';

  meta = with lib; {
    description = "Window manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
