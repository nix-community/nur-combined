{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "font-typst-math";
  version = "unstable-2025-06-16";

  src = fetchFromGitHub {
    owner = "chillcicada";
    repo = "fonts";
    rev = "d9da8ae346fb772f485d2da2c8b5d58fda3b783c";
    sha256 = "sha256-Fa4Xe27qZieIoYo829/VPFmarH6kYe0Qt0lQAqOemCE=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/{truetype,opentype}
    install -D *.ttf $out/share/fonts/truetype/
    install -D *.otf $out/share/fonts/opentype/

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/chillcicada/fonts/tree/typst-math";
    description = "Minimal fonts for Typst Math VS Code extension";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.all;
  };
}
