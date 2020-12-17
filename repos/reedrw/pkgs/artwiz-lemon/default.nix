{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "artwiz-lemon";

  src = fetchFromGitHub (lib.importJSON ./source.json);

  installPhase = ''
    install -D -m644 lemon.bdf "$out/share/fonts/lemon.bdf"
    install -D -m644 spectrum-fonts/berry.bdf "$out/share/fonts/berry.bdf"
  '';

  meta = {
    description = "Improved version of artwiz-lime with better kerning, distinct characters, extended unicode support, and in-built icons.";
    homepage = "https://github.com/cmvnd/fonts";
    license = stdenv.lib.licenses.wtfpl;
  };

}
