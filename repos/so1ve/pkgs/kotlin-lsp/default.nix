{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  jdk25,
}:

let
  # Pinned manually: GitHub's latest release still points at an expired EAP.
  # https://github.com/Kotlin/kotlin-lsp/issues/270#issuecomment-5551783635
  version = "263.4421.0";
  sources = {
    x86_64-linux = {
      suffix = "";
      hash = "sha256-0dq073s5qI93zPaNXloWXJ88Xg+bG7mSPmJaVL08Zz8=";
    };
    aarch64-linux = {
      suffix = "-aarch64";
      hash = "sha256-hScJin/mYUkzwGqJuPG/ANAP4e5ghe62fMCXgmAiwr0=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "kotlin-lsp";
  inherit version;

  src = fetchurl {
    url = "https://download.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}${source.suffix}.tar.gz";
    inherit (source) hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
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
    platforms = builtins.attrNames sources;
    mainProgram = "intellij-server";
  };
}
