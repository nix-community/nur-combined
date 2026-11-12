{
  autoPatchelfHook,
  coreutils,
  fetchzip,
  jdk25,
  lib,
  libfaketime,
  makeWrapper,
  patchelf,
  stdenv,
  stdenvNoCC,
  unzip,
}:

let
  # EAP builds stop working 30 days after this UTC build date,
  # from idea/IntelliJServerApplicationInfo.xml in lib/language-server.main.jar
  buildDate = "202611031640";

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

  # seconds since the epoch at which the server refuses to start
  expiresAt = toEpoch buildDate + 30 * 24 * 60 * 60;

  # On Linux, libfaketime is a DT_NEEDED dependency of the launcher, so only the
  # server process sees the faked clock; child processes such as the Gradle
  # daemon inherit no LD_PRELOAD and keep the real one. Once the real clock
  # passes fakeStart, the server's clock starts at fakeStart instead and ticks
  # from there, leaving a week of uptime before it would reach expiresAt.
  fakeStart = expiresAt - 7 * 24 * 60 * 60;
  faketimeSetup = ''
    if (( $(${coreutils}/bin/date +%s) >= ${toString fakeStart} )); then
      export FAKETIME="@$(${coreutils}/bin/date -d @${toString fakeStart} '+%Y-%m-%d %H:%M:%S')"
    else
      export FAKETIME=+0
    fi
    export FAKETIME_DONT_FAKE_MONOTONIC=1
    # one process needs no shared state, which would leak in /dev/shm when the server is killed
    export FAKETIME_DISABLE_SHM=1
  '';
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kotlin-lsp";
  version = "271.2085.0";

  src =
    let
      sources = {
        x86_64-linux = fetchzip {
          url = "https://download.jetbrains.com/language-server/kotlin-server/${finalAttrs.version}/kotlin-server-${finalAttrs.version}.tar.gz";
          hash = "sha256-lB+KkyW8h0j4Xpi//+IVxJvdSu2XFRS2QOwGHfrRG58=";
        };
        aarch64-linux = fetchzip {
          url = "https://download.jetbrains.com/language-server/kotlin-server/${finalAttrs.version}/kotlin-server-${finalAttrs.version}-aarch64.tar.gz";
          hash = "sha256-gGQ1WrTurM9uE3RmzabCAHiTLTEgUVO3hgvH5ft9IXM=";
        };
        aarch64-darwin = fetchzip {
          url = "https://download.jetbrains.com/language-server/kotlin-server/${finalAttrs.version}/kotlin-server-${finalAttrs.version}-aarch64.sit";
          extension = "zip";
          hash = "sha256-33Jos2E3fi8rxqEbZuJ6t3LnPZEIEFgNUq4VLHT5yjk=";
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
    patchelf
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

    patchelf --add-needed ${libfaketime}/lib/libfaketime.so.1 $out/share/kotlin-lsp/bin/intellij-server
    makeWrapper $out/share/kotlin-lsp/bin/intellij-server $out/bin/kotlin-lsp \
      --run ${lib.escapeShellArg faketimeSetup}
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    cp -r jbr $out/share/kotlin-lsp/
    makeWrapper $out/share/kotlin-lsp/bin/intellij-server $out/bin/kotlin-lsp
  ''
  + ''
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

    # sends an LSP initialize request to the given command and prints its output
    initialize() {
      local req='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":null,"capabilities":{}}}'
      printf 'Content-Length: %d\r\n\r\n%s' "''${#req}" "$req" | timeout 120 "$@" --stdio 2>&1 || true
    }

    initialize $out/bin/kotlin-lsp | grep -q '"jsonrpc"' || {
      echo "kotlin-lsp did not respond to an LSP initialize request" >&2
      exit 1
    }

    # a year after expiry, by faking the clock for the wrapper's own date calls too
    after=$(( ${toString expiresAt} + 365 * 24 * 60 * 60 - $(date +%s) ))

    FAKETIME="+$after" initialize $out/share/kotlin-lsp/bin/intellij-server | grep -q 'has expired' || {
      echo "the launcher does not follow the libfaketime clock, so the expiry is not faked" >&2
      exit 1
    }

    LD_PRELOAD=${libfaketime}/lib/libfaketime.so.1 FAKETIME="+$after" initialize $out/bin/kotlin-lsp \
      | grep -q '"jsonrpc"' || {
      echo "kotlin-lsp did not respond to an LSP initialize request after it expired" >&2
      exit 1
    }

    runHook postInstallCheck
  '';

  passthru = {
    updateScript = [
      "bash"
      "packages/kotlin-lsp/update.sh"
    ];
  }
  # macOS ignores DYLD_INSERT_LIBRARIES for the hardened darwin launcher, so it still expires there
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    inherit expiresAt;
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
