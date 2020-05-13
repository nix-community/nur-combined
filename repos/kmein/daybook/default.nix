{ stdenv, makeWrapper, pandoc, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "daybook";
  src = fetchFromGitHub {
    owner = "kmein";
    repo = "daybook";
    rev = "cad1aef158b0df36861434eb04c953d99a122e80";
    sha256 = "07qippyry0yjf971pnqxm9i0xpvih8mvbhxwfwpwq980jik1hbl1";
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
