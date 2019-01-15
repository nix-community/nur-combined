{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  name = "source-code-pro-nerdfonts-${version}";
  version = "2.0.0";

  src = fetchzip {
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/SourceCodePro.zip";
    sha256 = "1rf8ar4jnx6by4br46rcybzvh7mxp3vy6y9jn0y93j53p8j4cyv2";
    stripRoot = false;
  };
  buildCommand = ''
    install --target $out/share/fonts/opentype -D $src/*Mono.ttf
  '';

  meta = with stdenv.lib; {
    description = "Nerdfont version of Fira Code";
    homepage = https://github.com/ryanoasis/nerd-fonts;
    license = licenses.mit;
  };
}
