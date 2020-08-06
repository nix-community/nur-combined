{ stdenv, fetchFromGitHub, automake, autoconf, pkgconfig, libxkbcommon, pango
, cairo, git, bison, flex, librsvg, check, libstartup_notification, libxcb
, xcbutil, xcbutilwm, xcbutilxrm, which }:

let
  rofi = fetchFromGitHub {
    owner = "davatorium";
    repo = "rofi";
    rev = "e275ed2283c385a1fc7de4670257809578e13e60";
    sha256 = "0af6q4dvnvcnayg6n1qij3vq5afn08vxqkk8805g42842myfz8fi";
  };
  libgwater = fetchFromGitHub {
    owner = "sardemff7";
    repo = "libgwater";
    rev = "c7bd8c914999d12051466a2d1b94f7ef74fbbffb";
    sha256 = "0g829r2mwqh5ijzl14zw2yl5kzzvgnh6mm4wxzdmf5vgv2z0s830";
  };
  libnkutils = fetchFromGitHub {
    owner = "sardemff7";
    repo = "libnkutils";
    rev = "8adccd3b1b33b2a9a29dd12a7e686907bbafc5d4";
    sha256 = "1q7ahcn7vk3nn8m5jhg0fwg9s8bhjdc0srmfjy2l9p8bzqxnyqzl";
  };
in stdenv.mkDerivation {
  pname = "rofi-unwrapped-git";
  version = "1.6.0";

  srcs = [ rofi libgwater libnkutils ];

  preUnpack = ''
    mkdir rofi
    mkdir rofi/subprojects
    mkdir rofi/subprojects/libgwater
    mkdir rofi/subprojects/libnkutils
  '';
  unpackCmd = ''
    case $curSrc in
    	${rofi})
    		cp -r $curSrc/* rofi
    		;;
    	${libgwater})
    		mkdir libgwater
    		cp -r $curSrc/* rofi/subprojects/libgwater
    		;;
    	${libnkutils})
    		mkdir libnkutils
    		cp -r $curSrc/* rofi/subprojects/libnkutils
    		;;
    esac
  '';
  sourceRoot = "rofi";

  nativeBuildInputs = [ automake autoconf pkgconfig ];

  preConfigure = ''
    patchShebangs script
    autoreconf -i
  '';
  configureScript = "./configure --prefix=$out";

  doCheck = false;

  buildInputs = [
    libxkbcommon
    pango
    cairo
    git
    bison
    flex
    librsvg
    check
    libstartup_notification
    libxcb
    xcbutil
    xcbutilwm
    xcbutilxrm
    which
  ];

  meta = with stdenv.lib; {
    description = "Window switcher, run dialog and dmenu replacement";
    homepage = "https://github.com/davatorium/rofi";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
