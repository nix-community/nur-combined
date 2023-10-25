{ lib, stdenv, fetchFromGitea, cmake, pkg-config, makeWrapper, SDL2, the-foundation, AppKit }:

stdenv.mkDerivation rec {
  pname = "bwh";
  version = "1.0.3";

  src = fetchFromGitea {
    domain = "git.skyjake.fi";
    owner = "skyjake";
    repo = "bwh";
    rev = "v${version}";
    hash = "sha256-POKjvUGFS3urc1aqOvfCAApUnRxoZhU725eYRAS4Z2w=";
  };

  nativeBuildInputs = [ cmake pkg-config makeWrapper ];

  buildInputs = [ SDL2 the-foundation ] ++ lib.optional stdenv.isDarwin AppKit;

  installPhase = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/{Applications,bin}
    mv *.app $out/Applications
    makeWrapper $out/{Applications/Bitwise\ Harmony.app/Contents/MacOS/Bitwise\ Harmony,bin/bitwise-harmony}
  '';

  meta = with lib; {
    description = "Bitwise Harmony - simple synth tracker";
    homepage = "https://git.skyjake.fi/skyjake/bwh";
    license = licenses.bsd2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
    mainProgram = "bitwise-harmony";
  };
}
