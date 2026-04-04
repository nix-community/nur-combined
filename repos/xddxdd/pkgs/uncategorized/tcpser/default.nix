{
  stdenv,
  lib,
  sources,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.tcpser) pname version src;

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 tcpser $out/bin/tcpser

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-V";
  doInstallCheck = true;

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Hayes-compatible modem emulator that bridges serial ports to TCP/IP";
    homepage = "https://github.com/go4retro/tcpser";
    license = lib.licenses.gpl2Plus;
    mainProgram = "tcpser";
    platforms = lib.platforms.unix;
  };
})
