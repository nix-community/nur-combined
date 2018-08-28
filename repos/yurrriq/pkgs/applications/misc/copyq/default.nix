{ stdenv, fetchurl, makeWrapper, undmg }:

stdenv.mkDerivation rec {
  name = "copyq-${version}";
  version = "3.5.0";

  src = fetchurl {
    url = "https://github.com/hluk/CopyQ/releases/download/v${version}/CopyQ.dmg";
    sha256 = "909c059c6717daa1932765b47beedbabe4c34a6799746bcedc014c28632e1c79";
  };

  buildInputs = [ makeWrapper undmg ];

  installPhase = ''
    local app=$out/Applications/CopyQ.app
    mkdir -p $app $out/bin
    cp -R . $app
    chmod a+x $app/Contents/MacOS/copyq
    makeWrapper $_ $out/bin/copyq
  '';

  meta = with stdenv.lib; {
    description = "Clipboard manager with advanced features";
    homepage = https://hluk.github.io/CopyQ/;
    repositories.git = git://git@github.com:hluk/CopyQ.git;
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ yurrriq ];
  };
}
