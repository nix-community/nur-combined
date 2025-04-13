{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation {
  pname = "w2c2";
  version = "0-unstable-2025-04-02";

  src = fetchFromGitHub {
    owner = "turbolent";
    repo = "w2c2";
    rev = "06022f2ff69bdc7d0514a49a18004440a03c3a61";
    hash = "sha256-YXIoyJEu+BMSwOU9Iit9WKobvVI45/3a8rpM7lBpBwI=";
  };

  nativeBuildInputs = [ cmake ];

  # TODO pr these upstream
  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin/ w2c2/w2c2
    install -Dm644 -t $out/lib wasi/libw2c2wasi.a
    install -Dm644 -t $out/include/wasi/ $src/wasi/*.h
    install -Dm644 -t $out/include/ $src/w2c2/*.h
    install -Dm644 -t $out/include/w2c2 $src/w2c2/*.h

    runHook postInstall
  '';

  meta = {
    description = "Translates WebAssembly modules to portable C";
    homepage = "https://github.com/turbolent/w2c2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "w2c2";
    platforms = lib.platforms.all;
  };
}
