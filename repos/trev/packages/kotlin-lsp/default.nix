{
  autoPatchelfHook,
  fetchzip,
  jdk25,
  lib,
  makeWrapper,
  stdenv,
  stdenvNoCC,
  unzip,
}:

let
  # EAP builds stop working 30 days after this UTC build date,
  # from idea/IntelliJServerApplicationInfo.xml in lib/language-server.main.jar
  buildDate = "202610140421";

  # converts a UTC "YYYYMMDDhhmm" timestamp to seconds since the epoch
  toEpoch =
    timestamp:
    let
      part = start: len: lib.toIntBase10 (builtins.substring start len timestamp);
      month = part 4 2;
      # count years from March so the leap day is the last day of the year
      year = part 0 4 - (if month <= 2 then 1 else 0);
      era = year / 400;
      yearOfEra = year - era * 400;
      dayOfYear = (153 * (month + (if month > 2 then -3 else 9)) + 2) / 5 + part 6 2 - 1;
      dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear;
      days = era * 146097 + dayOfEra - 719468;
    in
    days * 86400 + part 8 2 * 3600 + part 10 2 * 60;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kotlin-lsp";
  version = "263.7084.0";

  src =
    let
      sources = {
        x86_64-linux = fetchzip {
          url = "https://download.jetbrains.com/language-server/kotlin-server/${finalAttrs.version}/kotlin-server-${finalAttrs.version}.tar.gz";
          hash = "sha256-Ld04XYQh62ahCzpAzZzwhFtI0apmhZIhQMVRm6ak+eQ=";
        };
        aarch64-linux = fetchzip {
          url = "https://download.jetbrains.com/language-server/kotlin-server/${finalAttrs.version}/kotlin-server-${finalAttrs.version}-aarch64.tar.gz";
          hash = "sha256-gxv8v1/zSQO9EPD7S1YA/2igI809uq/tah8AVdCKNds=";
        };
        aarch64-darwin = fetchzip {
          url = "https://download.jetbrains.com/language-server/kotlin-server/${finalAttrs.version}/kotlin-server-${finalAttrs.version}-aarch64.sit";
          extension = "zip";
          hash = "sha256-wD4BU8Be6pLOmrnaojm7EHr+lfYAp5NjCoPC+M3deHM=";
        };
      };
    in
    sources.${stdenv.hostPlatform.system}
      or (throw "unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    jdk25
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/kotlin-lsp
    cp -r bin build.txt kotlin-lsp.sh lib license modules plugins product-info.json $out/share/kotlin-lsp
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    ln -s ${jdk25}/lib/openjdk $out/share/kotlin-lsp/jbr
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    cp -r jbr $out/share/kotlin-lsp/
  ''
  + ''
    makeWrapper $out/share/kotlin-lsp/bin/intellij-server $out/bin/kotlin-lsp

    runHook postInstall
  '';

  doInstallCheck =
    stdenv.buildPlatform.canExecute stdenv.hostPlatform && !stdenv.hostPlatform.isDarwin;
  nativeInstallCheckInputs = [ unzip ];
  installCheckPhase = ''
    runHook preInstallCheck

    unzip -p $out/share/kotlin-lsp/lib/language-server.main.jar idea/IntelliJServerApplicationInfo.xml \
      | grep -q 'date="${buildDate}"' || {
      echo "buildDate does not match the build date in IntelliJServerApplicationInfo.xml" >&2
      exit 1
    }

    if (( $(date +%s) >= ${toString finalAttrs.passthru.expiresAt} )); then
      echo "kotlin-lsp ${finalAttrs.version} has expired, update it" >&2
      exit 1
    fi

    req='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":null,"capabilities":{}}}'
    printf 'Content-Length: %d\r\n\r\n%s' "''${#req}" "$req" \
      | timeout 120 $out/bin/kotlin-lsp --stdio > response.txt 2>/dev/null || true

    grep -q '"jsonrpc"' response.txt || {
      echo "kotlin-lsp did not respond to an LSP initialize request" >&2
      exit 1
    }

    runHook postInstallCheck
  '';

  passthru = {
    # seconds since the epoch at which the server refuses to start
    expiresAt = toEpoch buildDate + 30 * 24 * 60 * 60;

    updateScript = [
      "bash"
      "packages/kotlin-lsp/update.sh"
    ];
  };

  meta = {
    description = "Kotlin Language Server and plugin for Visual Studio Code";
    homepage = "https://github.com/Kotlin/kotlin-lsp";
    changelog = "https://github.com/Kotlin/kotlin-lsp/releases/tag/kotlin-lsp/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "kotlin-lsp";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
