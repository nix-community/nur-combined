{ stdenv, fetchFromGitHub, imagemagick }:
stdenv.mkDerivation rec {
  name = "tiv-${version}";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "stefanhaustein";
    repo = "TerminalImageViewer";

    rev = "v${version}";
    sha256 = "18jwx8r2pn4ihfa46llik3ma1482dhr5lpg37j615qmcarxpvq8j";
  };

  sourceRoot = "source/src/main/cpp";

  buildInputs = [ imagemagick ];

  preInstall = ''
    substituteInPlace Makefile --replace '/usr/local/bin' "$out/bin"
    mkdir -p $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Small C++ program to display images in a (modern) terminal using RGB ANSI codes and unicode block graphics characters";
    license = licenses.asl20;
    homepage = https://github.com/stefanhaustein/TerminalImageViewer;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}
