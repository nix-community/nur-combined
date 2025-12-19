{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "plank-themes";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "dancooper71";
    repo = "Plank-Themes";
    rev = "738b825bfce4a3e1672c47ba70bad80bde60c623";
    sha256 = "sha256-+DFLswm527MRI4WH0tgd4eB9fNdTMAYOLhvtplffVSw=";
  };

  nativeBuildInputs = [ ];

  doCheck = false;

  installPhase = ''
    mkdir -p $out/share/plank/themes
    cp -rf Plank\ Themes/* $out/share/plank/themes/

    rm -rf $out/share/plank/themes/Transparent
  '';

  meta = with lib; {
    description = "A collection of over 100 plank themes";
    homepage = "https://github.com/dancooper71/Plank-Themes";
    license = licenses.gpl3Only;
  };
}
