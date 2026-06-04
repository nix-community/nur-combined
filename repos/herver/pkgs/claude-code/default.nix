{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  pkgs,
}:

let
  version = "2.1.162";
  pname = "claude-code";

  # GCS bucket backing the official installer (claude.ai/install.sh).
  # Tracks the "latest" channel; see update.sh.
  src = fetchurl {
    url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-x64/claude";
    hash = "sha256-lHpJsN6GiPanSm51PCR3H/Pd0Xsqba6F82ME7FFOYdE=";
    name = "${pname}-${version}";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  # The binary is a glibc-linked Node SEA; its interpreter
  # (/lib64/ld-linux-x86-64.so.2) must be patched for NixOS.
  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/libexec/claude

    makeWrapper $out/libexec/claude $out/bin/claude \
      --set-default DISABLE_AUTOUPDATER 1 \
      --set-default DISABLE_INSTALLATION_CHECKS 1

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Agentic coding tool that lives in your terminal";
    homepage = "https://code.claude.com/docs/en/overview";
    downloadPage = "https://claude.ai/install.sh";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude";
  };
}
