{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  openssl,
  stdenv,
}:
let
  pin = import ../../lib/release-pin.nix {
    inherit lib fetchurl;
  } ./pin.json stdenvNoCC.hostPlatform.system;
  inherit (stdenvNoCC.hostPlatform) isDarwin isLinux;
in
stdenvNoCC.mkDerivation {
  pname = "agent-access";
  inherit (pin) version src;

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals isLinux [
    openssl
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontFixup = isDarwin;

  installPhase = ''
    runHook preInstall
    install -Dm755 aac "$out/bin/aac"
    runHook postInstall
  '';

  meta = {
    description = "Open protocol, CLI, and SDK to provide agents with credentials without exposing their entire vault (official prebuilt release)";
    homepage = "https://github.com/bitwarden/agent-access";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
    mainProgram = "aac";
  };
}
