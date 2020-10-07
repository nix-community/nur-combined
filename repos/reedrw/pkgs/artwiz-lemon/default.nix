{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "artwiz-lemon";

  src = fetchFromGitHub (lib.importJSON ./source.json);

  installPhase = ''
    install -D -m644 lemon.bdf "$out/share/fonts/lemon.bdf"
  '';

  meta = {
    description = "Improved version of artwiz-lime with better kerning, distinct characters, extended unicode support, and in-built icons.";
    homepage = "https://github.com/cmvnd/fonts";
    license = stdenv.lib.licenses.wtfpl;
  };

}

