{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "artwiz-lemon";

  src = fetchFromGitHub (lib.importJSON ./source.json);

  installPhase = ''
    mkdir -p "$out/share/fonts"
    find . -type f \( -name "*.bdf" -o -name "*.otb" \) -exec cp {} "$out/share/fonts" \;
  '';

  meta = {
    description = "Improved version of artwiz-lime with better kerning, distinct characters, extended unicode support, and in-built icons.";
    homepage = "https://github.com/cmvnd/fonts";
    license = lib.licenses.gpl3Only;
  };

}
