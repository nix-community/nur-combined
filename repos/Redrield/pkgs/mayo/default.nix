{ stdenv, fetchFromGitHub, wrapQtAppsHook, cmake, qtbase, qtsvg, xorg, opencascade-occt }:
stdenv.mkDerivation {
  pname = "mayo";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "fougue";
    repo = "mayo";

    rev = "97627a0f5c06ad0afc77f5843914046eb6123dda";
    hash = "sha256-rK8aHpO6tn2yh8ZcdsWnMjlDryPgcO4ibYcPgm9Zs1U=";
  };

  nativeBuildInputs = [ cmake wrapQtAppsHook ];
  buildInputs = [ xorg.xcbutilcursor xorg.libXi opencascade-occt qtbase qtsvg ];

  installPhase = ''
    install -Dm755 mayo $out/bin/mayo
  '';
}
