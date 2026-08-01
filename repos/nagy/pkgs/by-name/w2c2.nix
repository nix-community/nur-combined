{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation {
  pname = "w2c2";
  version = "0-unstable-2026-08-01";

  src = fetchFromGitHub {
    owner = "turbolent";
    repo = "w2c2";
    rev = "5f1ece4e5f23bac078c30c92f6671423157dad7a";
    hash = "sha256-1VNSRYNk8xIEUumIvmuwO6t/3NF+O9Vsv+fyAYhVI5g=";
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
