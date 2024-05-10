{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "w2c2";
  version = "unstable-2024-04-13";

  src = fetchFromGitHub {
    owner = "turbolent";
    repo = "w2c2";
    rev = "13095d82c8331232c8e72de174f548f6551ec668";
    hash = "sha256-dIfYKfu0LeCzEDNvY90IDHw2bIrI3AZU7T7HXewl228=";
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

  meta = with lib; {
    description = "Translates WebAssembly modules to portable C";
    homepage = "https://github.com/turbolent/w2c2";
    license = licenses.mit;
    maintainers = with maintainers; [ nagy ];
    mainProgram = "w2c2";
    platforms = platforms.all;
  };
}
