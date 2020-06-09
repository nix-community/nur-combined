{ lib
, mkDerivation
, fetchFromGitHub
, fetchpatch
, cmake
, pkg-config
, extra-cmake-modules
, qtbase
, kactivities
, hunspell
, qtscript
, kross
, breakpointHook
}:
mkDerivation rec {

  pname = "Lokalize";
  version = "20.04.1";

  src = fetchFromGitHub {
    owner = "KDE";
    repo = "lokalize";
    rev = "v${version}";
    sha256 = "0qm9qgrgffacpd303slf8plq9qqx6sf8m1gih3cg2gbwpv5k9y9x";
  };

  nativeBuildInputs = [ breakpointHook pkg-config extra-cmake-modules cmake  ];

  buildInputs = [ kross qtscript hunspell kactivities qtbase ];

  meta = with lib; {
    description = "Computer-aided translation system that focuses on productivity and quality assurance";
    license = licenses.mit;
    homepage = "https://dangvd.github.io/ksmoothdock/";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
