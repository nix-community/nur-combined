{ stdenv, makeWrapper, pandoc, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "daybook";
  src = fetchFromGitHub {
    owner = "kmein";
    repo = "daybook";
    rev = "db2c34830e09183c80f3381bf5e4c44d52f05d53";
    sha256 = "0nbsv8f12qh5spq7zhimhdf3p7msk33xrb0ilqvlc6jmlkpislmv";
  };
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ pandoc ];
  buildPhase = ''
    mkdir -p $out/man/man1
    pandoc --standalone --to man daybook.1.md -o $out/man/man1/daybook.1
  '';
  installPhase = ''
    mkdir -p $out/bin
    install daybook $out/bin
    wrapProgram $out/bin/daybook --prefix PATH ":" ${pandoc}/bin ;
  '';
  meta = with stdenv.lib; {
    homepage = https://github.com/kmein/daybook;
    description = "A diary writing utility in sh";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
