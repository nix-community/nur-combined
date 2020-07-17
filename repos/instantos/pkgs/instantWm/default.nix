{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, pavucontrol
, rofi
, rxvt_unicode
, st
, instantAssist
, instantUtils
, instantDotfiles
, extraPatches ? []
, defaultTerminal ? st
}:
stdenv.mkDerivation {

  pname = "instantWm";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantWM";
    rev = "ef3327f995ed44975806a0eb3f09a531925b2e0e";
    sha256 = "0nsy9vgbbj6q17m1wzpgk2igbhhrgsg3z4wpi23lmkh8rlwwb0qc";
    name = "instantOS_instantWm";
  };

  patches = [
    ./config_def_h.patch
  ] ++ extraPatches;

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr/local" "PREFIX = $out"
    substituteInPlace instantwm.c \
      --replace "cd /usr/bin; ./instantautostart &" "${instantUtils}/bin/instantautostart &"
    substituteInPlace config.def.h \
      --replace "\"pavucontrol\"" "\"${pavucontrol}/bin/pavucontrol\"" \
      --replace "\"rofi\"" "\"${rofi}/bin/rofi\"" \
      --replace "\"urxvt\"" "\"${rxvt_unicode}/bin/urxvt\"" \
      --replace "\"st\"" "\"${defaultTerminal}/bin/${builtins.head (builtins.match "(.*)-.*" defaultTerminal.name)}\"" \
      --replace /opt/instantos/menus "${instantAssist}/opt/instantos/menus" \
      --replace /usr/share/instantdotfiles "${instantDotfiles}/share/instantdotfiles/"
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];
  propagatedBuildInputs = [ 
    pavucontrol
    rofi
    rxvt_unicode
    st
  ] ++
  [
    instantAssist
    instantUtils
  ];

  installPhase = ''
    install -Dm 555 instantwm $out/bin/instantwm
    install -Dm 555 startinstantos $out/bin/startinstantos
  '';

  meta = with lib; {
    description = "Window manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
