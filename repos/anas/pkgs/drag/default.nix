{ lib
, fetchFromCodeberg
, stdenv
, libX11
}:

let
  pname = "drag";
  version = "1.1";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromCodeberg {
    owner = "ayari";
    repo = pname;
    rev = version;
    hash = "sha256-WsL5Qjts2I9x6n+9K+3OIuruyzI34HtDyEQlx2FM2Yc=";
  };

  buildInputs = [
    libX11
  ];

  installPhase = ''
    install -Dm755 drag $out/bin/drag
    install -Dm644 drag.1 $out/share/man/man1/drag.1
    install -Dm644 LICENSE $out/share/licenses/${pname}/LICENSE
    install -Dm644 README.md $out/share/doc/${pname}/README.md
  '';

  meta = {
    description = "A minimal X11 drag-and-drop utility.";
    homepage = "https://codeberg.org/ayari/drag";
    license = lib.licenses.cc0;
    mainProgram = "drag";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.unix;
  };
}
