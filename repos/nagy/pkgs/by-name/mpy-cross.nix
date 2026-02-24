{
  lib,
  stdenv,
  python3,
  micropython,
}:

stdenv.mkDerivation {
  pname = "mpy-cross";
  inherit (micropython) version src;
  sourceRoot = "source/mpy-cross";

  nativeBuildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall

    install -Dm755 build/mpy-cross $out/bin/mpy-cross

    runHook postInstall
  '';

  meta = {
    description = "An integrated set of utilities to remotely interact with and automate a MicroPython device over a serial connection";
    homepage = "https://github.com/micropython/micropython/blob/master/tools/mpremote/README.md";
    platforms = lib.platforms.unix;
    license = micropython.meta.license;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "mpy-cross";
  };
}
