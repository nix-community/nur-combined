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
    rev = "a75fa3e9d4b0a81cba699fb1fdf02dfbefb7be72";
    sha256 = "13aqxsiqh25bfrmq2cw42hgrghnxpii8zllxhhqf7r46s93ss5q0";
    name = "instantOS_instantMenu";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr" "PREFIX = $out"
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];
  propagatedBuildInputs = [ instantUtils ];

  meta = with lib; {
    description = "basic menu for instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
