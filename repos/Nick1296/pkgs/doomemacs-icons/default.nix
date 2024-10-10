{ lib,stdenvNoCC, fetchFromGitHub }:
stdenvNoCC.mkDerivation rec {
  name = "doomemacs-icons";
  version = "2023-03-10";
  src = fetchFromGitHub {
    owner = "jaidetree";
    repo = "doom-icon";
    rev = "e90e93ff6c05615137a0a3694f4674ba83ff00ae";
    hash = "sha256-TLUzL37X41PBRK9oVtKjZDQ2Laf82OMA9KWzTjGKmyY=";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/doomemacs-icons/{abject,cute,emacs}-doom
    cp $src/abject-doom/*.* $out/share/doomemacs-icons/abject-doom/
    cp $src/cute-doom/*.* $out/share/doomemacs-icons/cute-doom/
    cp $src/emacs-doom/*.* $out/share/doomemacs-icons/emacs-doom/
    '';
  meta = with lib; {
    description = "A proposed doom Emacs icon";
    homepage = "https://github.com/jaidetree/doom-icon";
    license = licenses.cc0;
    platforms = platforms.all;
  };
}
