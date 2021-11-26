{ lib, stdenv, fetchFromSourcehut, pkg-config, zig
, curl, SDL2, SDL2_image, SDL2_ttf
}:

stdenv.mkDerivation rec {
  pname = "mepo";
  version = "2021-11-22";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = pname;
    rev = "c188f27c67c17514656389986defdbce9705ed14";
    hash = "sha256-oshI/Oo6KgOymT/njVc/NgeyB27iox9R2DBwWZdt/0A=";
  };

  nativeBuildInputs = [ pkg-config zig ];

  buildInputs = [ curl SDL2 SDL2_image SDL2_ttf ];

  buildPhase = ''
    export HOME=$TMPDIR
    zig build -Drelease-safe=true
  '';

  doCheck = true;
  checkPhase = ''
    zig build test
  '';

  installPhase = ''
    install -Dm755 zig-out/bin/mepo -t $out/bin
    install -Dm755 scripts/mepo_* $out/bin
  '';

  meta = with lib; {
    description = "Fast, simple, and hackable OSM map viewer";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # https://github.com/NixOS/nixpkgs/issues/86299
  };
}
