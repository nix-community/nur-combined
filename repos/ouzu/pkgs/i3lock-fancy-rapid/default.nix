{ stdenv, fetchFromGitHub, xorg }:

stdenv.mkDerivation rec {
  pname = "i3lock-fancy-rapid";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "ouzu";
    repo = "i3lock-fancy-rapid";
    rev = "b88627a399f04b68795a88f748fb6e1f01c65416";
    sha256 = "18qxa9h9n706y7l2dy7921wjpd17jsyvzira0jw6cx4chq2w7wki";
  };

  buildInputs = [ xorg.libX11 ];

  installPhase = ''
    mkdir -p $out/bin
    cp $pname $out/bin
  '';

  meta = with stdenv.lib; {
    description = "A faster implementation of i3lock-fancy. It is blazing fast and provides a fully configurable box blur. It uses linear-time box blur and accelerates using OpenMP.";
    longDescription = "This is my fork of i3lock-fancy-rapid which includes a brightness and pixelation option.";
    homepage = "https://github.com/ouzu/i3lock-fancy-rapid";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}