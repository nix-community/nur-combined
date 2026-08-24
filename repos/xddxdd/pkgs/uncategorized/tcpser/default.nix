{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tcpser";
  version = "1.1.4";
  src = fetchFromGitHub {
    owner = "go4retro";
    repo = "tcpser";
    tag = "v1.1.4";
    hash = "sha256-Ir/tQde7hfqlgOVXE2HqJSzEXdceCTywptN8PRqylMI=";
  };
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

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/go4retro/tcpser/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Hayes-compatible modem emulator that bridges serial ports to TCP/IP";
    homepage = "https://github.com/go4retro/tcpser";
    license = lib.licenses.gpl2Plus;
    mainProgram = "tcpser";
    platforms = lib.platforms.unix;
  };
})
