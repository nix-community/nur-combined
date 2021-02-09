{ lib, stdenv, fetchFromGitHub, scdoc, zig }:

stdenv.mkDerivation rec {
  pname = "gmi2html";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "shtanton";
    repo = "gmi2html";
    rev = "v${version}";
    sha256 = "1nfl0cy99mm2rk9v0g43370i4rnz26hg9ryl0gkm5d1v2sg2i4al";
  };

  nativeBuildInputs = [ scdoc zig ];

  preConfigure = "HOME=$TMP";

  buildPhase = ''
    zig build -Drelease-safe
    scdoc < doc/gmi2html.scdoc > doc/gmi2html.1
  '';

  installPhase = ''
    zig build --prefix $out install
    install -Dm644 doc/gmi2html.1 -t $out/share/man/man1
  '';

  meta = with lib; {
    description = "Translate text/gemini into HTML";
    homepage = "https://github.com/shtanton/gmi2html";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
