{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, rofi
, InstantUtils
}:
stdenv.mkDerivation rec {

  pname = "InstantWM";
  version = "beta2";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantWM";
    rev = "${version}";
    sha256 = "098s2gg526zzv9rpsc6d2ski8nscbrn3ngvlhkq6kmzs66d6pvb0";
  };

  patches = [
    ./shebang-script.patch
    ./config_def_h.patch
  ];

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr/local" "PREFIX = $out"
    substituteInPlace instantwm.c \
      --replace "cd /usr/bin; ./instantautostart &" "${InstantUtils}/bin/instantautostart &"
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];
  propagatedBuildInputs = [ rofi InstantUtils ];

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
