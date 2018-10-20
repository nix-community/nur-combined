{ stdenv, fetchFromGitHub, imagemagick }:
stdenv.mkDerivation rec {
  name = "tiv-${version}";
  version = "03-08-2018";

  src = fetchFromGitHub {
    owner = "stefanhaustein";
    repo = "TerminalImageViewer";

    rev = "643b56aee1c3836715f6ab2931fa10972d41bfcc";
    sha256 = "13phcsc8kajpgrh6ibrhwh8w9m69l9cz5yzsbakgkp5vn7w2j4f2";
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
