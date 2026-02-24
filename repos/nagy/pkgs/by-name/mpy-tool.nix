{
  lib,
  stdenv,
  python3,
  micropython,
}:

stdenv.mkDerivation {
  inherit (micropython) version src;
  pname = "mpy-tool";
  # sourceRoot = "source/tools/mpy-tool";
  doBuild = false;

  nativeBuildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ln -s $src/tools/mpy-tool.py $out/bin/mpy-tool

    runHook postInstall
  '';

  meta = {
    description = "An integrated set of utilities to remotely interact with and automate a MicroPython device over a serial connection";
    homepage = "https://github.com/micropython/micropython/blob/master/tools/mpremote/README.md";
    platforms = lib.platforms.unix;
    license = micropython.meta.license;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "mpy-tool";
  };
}
