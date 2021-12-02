{ lib, stdenv, fetchFromSourcehut, pkg-config, zig
, curl, SDL2, SDL2_image, SDL2_ttf
}:

stdenv.mkDerivation rec {
  pname = "mepo";
  version = "2021-12-02";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = pname;
    rev = "e17efef7646868ec70d181f4e3a20c1a9ea2e54c";
    hash = "sha256-+nwVUgtw9AaATEspG84YJiD8Ec8VSec+Q+qShdMJcM0=";
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
