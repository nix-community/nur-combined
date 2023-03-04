{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "morewaita";
  version = "43.3";

  src = fetchFromGitHub {
    owner = "somepaulo";
    repo = "MoreWaita";
    rev = "v${version}";
    hash = "sha256-yLIEG019iczCpReQI3C2+dhdo9qyqVAMXpIfVrVnzhI=";
  };

  installPhase = ''
    mkdir -p $out/share/icons/MoreWaita
    cp -r $src $out/share/icons/MoreWaita
  '';

  meta = with lib; {
    description = "An Adwaita style extra icons theme for Gnome Shell";
    homepage = "https://github.com/somepaulo/MoreWaita";
    license = licenses.gpl3Only;
  };
}
