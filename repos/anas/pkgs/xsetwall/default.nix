{ lib
, fetchFromCodeberg
, stdenv
, libX11
, bash
}:

let
  pname = "xsetwall";
  version = "1.0.3";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromCodeberg {
    owner = "0x61nas";
    repo = "xsetwall";
    rev = "v${version}";
    hash = "sha256-EufKPjHwGE/EvrT1fPN9RwgbUsy4ab38gDn9oRBo0nI=";
  };

  buildInputs = [
    libX11
    bash
  ];

  buildPhase = ''
    bash ./x build
  '';

  installPhase = ''
    install -Dm755 xsetwall $out/bin/xsetwall
    install -Dm644 xsetwall.1 $out/share/man/man1/xsetwall.1
    install -Dm644 LICENSE $out/share/licenses/${pname}/LICENSE
    install -Dm644 readme $out/share/doc/${pname}/readme
  '';

  meta = {
    description = "A minimal utility for setting wallpapers in X11 environment.";
    homepage = "https://github.com/0x61nas/xsetwall";
    license = lib.licenses.mit;
    mainProgram = "xsetwall";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.unix;
  };
}
