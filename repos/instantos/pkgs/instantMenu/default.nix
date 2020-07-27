{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, instantUtils
}:
stdenv.mkDerivation {

  pname = "instantMenu";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantMENU";
    rev = "07e58a3485533174df9d806a39d29894d6a58ae4";
    sha256 = "0fp99nchp6kb0302w14niiw8rljhdi67q59fdzjjlciw9r8mafx3";
    name = "instantOS_instantMenu";
  };

  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];
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
