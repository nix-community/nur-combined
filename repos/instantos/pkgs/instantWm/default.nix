{ lib
, stdenv
, fetchFromGitHub
, gnumake
, pavucontrol
, rofi
, rxvt-unicode-unwrapped
, st
, cantarell-fonts
#, joypixels
, instantAssist
, instantUtils
, instantDotfiles
, libX11
, libXft
, libXinerama
, wmconfig ? null
, extraPatches ? []
, defaultTerminal ? st
}:

let
  gitrev = {
    owner = "instantOS";
    repo = "instantWM";
    rev = "416edc3f1b34179770aa136f371f5969b1c22cc9";
    sha256 = "69WFzbLXZjoYFoPrN2hSfTd9Kqs+HvkQf8qcuHxDIqg=";
    name = "instantOS_instantWm";
  };
in

stdenv.mkDerivation {

  pname = "instantWm";
  version = "unstable";

  src = fetchFromGitHub gitrev;

  patches = [ ] ++ extraPatches;

  postPatch =
  ( if builtins.isPath wmconfig then "cp ${wmconfig} config.def.h\n" else "" ) + 
  ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr/local" "PREFIX = $out"
    substituteInPlace config.def.h \
      --replace "\"pavucontrol\"" "\"${pavucontrol}/bin/pavucontrol\"" \
      --replace "\"rofi\"" "\"${rofi}/bin/rofi\"" \
      --replace "\"urxvt\"" "\"${rxvt-unicode-unwrapped}/bin/urxvt\"" \
      --replace "\"st\"" "\"${defaultTerminal}/bin/${builtins.head (builtins.match "(.*)-.*" defaultTerminal.name)}\"" \
      --replace /usr/share/instantassist/ "${instantAssist}/share/instantassist/" \
      --replace /usr/share/instantdotfiles/ "${instantDotfiles}/share/instantdotfiles/"
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = [ libX11 libXft libXinerama ];
  propagatedBuildInputs = [
    cantarell-fonts
    #joypixels
    pavucontrol
    rofi
    rxvt-unicode-unwrapped
    defaultTerminal
  ] ++
  [
    instantAssist
    instantUtils
  ];

  preBuild = ''
    makeFlagsArray+=(VERSION='"instantOS beta6-g${gitrev.rev} instantNIX"' CMS_VERSION="${gitrev.rev}")
  '';

  installPhase = ''
    install -Dm 555 instantwm $out/bin/instantwm
    install -Dm 555 startinstantos $out/bin/startinstantos
    install -Dm 555 instantwmctrl.sh $out/bin/instantwmctrl
  '';

  checkPhase = ''
    $out/bin/instantwm -V > /dev/null
  '';

  meta = with lib; {
    description = "Window manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ 
        maintainers.shamilton
        "con-f-use <con-f-use@gmx.net>"
        "paperbenni <instantos@paperbenni.xyz>"
    ];
    platforms = platforms.linux;
  };
}
