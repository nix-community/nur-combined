{
  lib,
  stdenv,
  callPackage,
  autoPatchelfHook,
  makeWrapper,
  jdk25,
  source ? callPackage ./source.nix { },
  unzip,
}:

stdenv.mkDerivation {
  pname = "kotlin-lsp";
  inherit (source) version src;
  sourceRoot = "extension/server";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    rm -rf jbr
    mkdir -p "$out/share/kotlin-lsp" "$out/bin"
    cp -a . "$out/share/kotlin-lsp/"

    # The upstream launcher's empty envVarBaseName makes _JDK its runtime
    # override. Keep JAVA_HOME available to the project's Gradle toolchain.
    makeWrapper "$out/share/kotlin-lsp/bin/intellij-server" "$out/bin/intellij-server" \
      --set _JDK "${jdk25.home}"

    runHook postInstall
  '';

  meta = {
    description = "Official Kotlin language server from JetBrains";
    homepage = "https://github.com/Kotlin/kotlin-lsp";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      binaryBytecode
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "intellij-server";
  };
}
