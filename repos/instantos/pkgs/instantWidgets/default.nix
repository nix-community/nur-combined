{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation {

  pname = "instantWidgets";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantwidgets";
    rev = "6396d938cb122448e427a5944160308e4ce3bc06";
    sha256 = "1gb30bxwlb1hff7k4xdlawl4p29ql01arahzmlhp6nln28s5l6dn";
    name = "instantOS_instantWidgets";
  };

  postPatch = ''
    substituteInPlace install.conf \
      --replace /usr/share/instantwidgets "$out/share/instantwidgets"
  '';

  installPhase = ''
    mkdir -p "$out/share/instantwidgets"
    mv * "$out/share/instantwidgets"
  '';

  meta = with lib; {
    description = "instantOS widgets";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantwidgets";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
