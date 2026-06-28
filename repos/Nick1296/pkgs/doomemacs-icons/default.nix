{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  variant ? "emacs",
  imagemagick,
}:
let
  folder-name = if variant == "emacs-brown" then "emacs-doom" else "${variant}-doom";
  icon-name = if variant == "emacs" then "doom-purple.png" else "doom.png";
in
stdenvNoCC.mkDerivation {
  pname = "doomemacs-icons";
  version = "2023-03-10";
  src =
    if
      (lib.asserts.assertOneOf "variant" variant [
        "emacs"
        "emacs-brown"
        "abject"
        "cute"
      ])
    then
      fetchFromGitHub {
        owner = "jaidetree";
        repo = "doom-icon";
        rev = "e90e93ff6c05615137a0a3694f4674ba83ff00ae";
        hash = "sha256-TLUzL37X41PBRK9oVtKjZDQ2Laf82OMA9KWzTjGKmyY=";
      }
    else
      null;
  dontUnpack = true;
  nativeBuildInputs = [
    imagemagick
  ];
  installPhase = ''
    mkdir -p $out/share/icons/hicolor/
    for size in 16 24 36 48 72; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
      magick $src/${folder-name}/${icon-name} -resize ''${size}x''${size} \
        $out/share/icons/hicolor/''${size}x''${size}/apps/doomemacs.png
    done
  '';
  meta = with lib; {
    description = "A proposed doom Emacs icon";
    homepage = "https://github.com/jaidetree/doom-icon";
    license = licenses.cc0;
    platforms = platforms.all;
  };
}
