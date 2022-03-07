{ stdenv, lib, fetchFromGitHub, xorg, inkscape }:

stdenv.mkDerivation rec {
  pname = "catppuccin-cursors";
  version = "ea242e87413fefc44369bfaa168e04610c92b195";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "cursors";
    rev = version;
    sha256 = "sha256-FHF8bgO/UQjCOswkpzjAsjZ6RNHi8FWn1kfZPpGPaG0=";
  };

  nativeBuildInputs = [
    xorg.xcursorgen
    inkscape
  ];

  installPhase = ''
    PREFIX="/" DESTDIR=$out make install
  '';

  meta = with lib; {
    description = "Soothing pastel mouse cursors";
    homepage = "https://github.com/catppuccin/cursors";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
