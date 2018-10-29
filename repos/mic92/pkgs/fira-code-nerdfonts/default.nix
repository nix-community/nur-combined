{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  name = "fira-code-nerdfonts-${version}";
  version = "2.0.0";

  src = fetchzip {
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/FiraCode.zip";
    sha256 = "1bnai3k3hg6sxbb1646ahd82dm2ngraclqhdygxhh7fqqnvc3hdy";
    stripRoot = false;
  };
  buildCommand = ''
    install --target $out/share/fonts/opentype -D $src/*.otf 
    rm $out/share/fonts/opentype/*Windows\ Compatible.otf
  '';

  meta = with stdenv.lib; {
    description = "Nerdfont version of Fira Code";
    homepage = https://github.com/ryanoasis/nerd-fonts;
    license = licenses.mit;
  };
}
