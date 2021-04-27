{ lib, stdenv, fetchFromGitHub, scdoc, zig }:

stdenv.mkDerivation rec {
  pname = "gmi2html";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "shtanton";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VJEonhY7tFLnA9Tn9KAR32YSwRmDPLDTzKLWlDwD1Nk=";
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
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
