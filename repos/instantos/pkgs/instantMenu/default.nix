{ lib
, stdenv
, fetchFromGitHub
, gnumake
, instantUtils
, libX11
, libXft
, libXinerama
}:

stdenv.mkDerivation {
  pname = "instantMenu";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantMENU";
    rev = "3f544aec3a4672ecd0b5e4f5fb3f188736d3709a";
    sha256 = "VWMKufNPNreRxGXfM4zHdM82vxeBgFA9mpLVMX9mzcQ=";
    name = "instantOS_instantMenu";
  };

  nativeBuildInputs = [ gnumake ];
  buildInputs = [ libX11 libXft libXinerama ];
  propagatedBuildInputs = [ instantUtils ];

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr" "PREFIX = $out"
    patchShebangs theme.sh
  '';

  meta = with lib; {
    description = "Basic menu for instantOS";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantMENU";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
