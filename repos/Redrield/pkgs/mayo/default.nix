{ stdenv, fetchFromGitHub, wrapQtAppsHook, cmake, qtbase, qtsvg, xorg, opencascade-occt }:
stdenv.mkDerivation {
  pname = "mayo";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "fougue";
    repo = "mayo";

    rev = "develop";
    sha256 = "1p8j9m40b82wkmnpnfcdd61mha1v374vg7jbyfvkads5phrlgb3v";
  };

  nativeBuildInputs = [ cmake wrapQtAppsHook ];
  buildInputs = [ xorg.xcbutilcursor xorg.libXi opencascade-occt qtbase qtsvg ];

  installPhase = ''
    install -Dm755 mayo $out/bin/mayo
  '';
}
