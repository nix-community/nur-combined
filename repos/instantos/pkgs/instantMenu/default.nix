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
    rev = "95b69afe3bd90dbf4e41a0e15a29c708bf0d2e01";
    sha256 = "05ai4yf5w8cjxqr5scva0fbkcrfyc7jvpxlyzlhyxzvp47a1jy2m";
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
