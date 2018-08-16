{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  name = "inconsolata-nerdfont-${version}";
  version = "v2.0.0";

  src = fetchzip {
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/Inconsolata.zip";
    sha256 = "014kxpbz6lwy84hhnmmakw1lwmylks5x1c1ffqn974lvk572zfar";
    stripRoot=false;
  };
  buildCommand = ''
    install --target $out/share/fonts/opentype -D $src/*.otf 
  '';

  meta = with stdenv.lib; {
    description = "Nerdfont version of inconsolata";
    homepage = https://github.com/ryanoasis/nerd-fonts;
    license = licenses.mit;
  };
}
