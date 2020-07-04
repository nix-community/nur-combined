{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, rofi
}:
stdenv.mkDerivation rec {

  pname = "InstantWM";
  version = "";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantWM";
    rev = "beta2";
    sha256 = "098s2gg526zzv9rpsc6d2ski8nscbrn3ngvlhkq6kmzs66d6pvb0";
  };

  patches = [
    ./shebang-script.patch
    ./config_def_h.patch
  ];

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr/local" "PREFIX = $out"
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];
  propagatedBuildInputs = [ rofi ];

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
