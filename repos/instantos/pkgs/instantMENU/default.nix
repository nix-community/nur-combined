{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, instantUtils
}:
stdenv.mkDerivation rec {

  pname = "instantMENU";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantMENU";
    rev = "964840a2dc45828e3969039b67a41b6485d3bdfd";
    sha256 = "13nin2j5vmmynbicxxwcmjijkdy5bn8c8qrjgimkkakjv4l79cxq";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr" "PREFIX = $out"
    patchShebangs theme.sh
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];
  propagatedBuildInputs = [ instantUtils ];

  configurePhase = ''
    ./theme.sh    
  '';

  meta = with lib; {
    description = "basic menu for instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
