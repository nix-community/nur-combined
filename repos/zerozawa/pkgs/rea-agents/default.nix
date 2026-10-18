{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPypi,
  fetchurl,
  buildNpmPackage,
  makeWrapper,
  autoPatchelfHook,
  nodejs_24,
  python313,
  android-tools,
  apktool,
  binutils,
  binwalk,
  chromium,
  gdb,
  ghidra,
  ilspycmd,
  jdk21_headless,
  mitmproxy,
  procps,
  rizin,
  unblob,
  util-linux,
  wabt,
  wireshark-cli,
  wakaru,
  jadx-headless-mcp,
}:
let
  # REA's pwntools bridge (bridge/pwntools/layout_impl.py) rejects any Python
  # whose installed distributions are not exactly pwntools 4.15.0,
  # pyelftools 0.33 and unicorn 2.1.2; nixpkgs ships pyelftools 0.32 and
  # unicorn 2.1.4, so pin the two mismatches in a dedicated package set.
  reaPython = python313.override {
    packageOverrides = final: prev: {
      pyelftools = prev.pyelftools.overridePythonAttrs (old: rec {
        version = "0.33";
        src = fetchPypi {
          pname = "pyelftools";
          inherit version;
          hash = "sha256-Zg2C3L646D0XAr2X8iP3YWJdoGERwMyYjqxrirDBth8=";
        };
      });
      # The PyPI manylinux wheel ships a self-contained libunicorn loaded via
      # ctypes, so no native build or RPATH fixup is needed.
      unicorn = final.buildPythonPackage rec {
        pname = "unicorn";
        version = "2.1.2";
        format = "wheel";
        src = fetchPypi {
          inherit pname version;
          format = "wheel";
          dist = "cp313";
          python = "cp313";
          abi = "cp313";
          platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
          hash = "sha256-nGoL38OCZmAOrO4vJkIC+tG/+FkK020Ye0cDOngvEtw=";
        };
        pythonImportsCheck = [ "unicorn" ];
      };
    };
  };
  reaPythonEnv = reaPython.withPackages (ps: [
    ps.pwntools
    ps.pyelftools
    ps.unicorn
  ]);

  # src/signals/SigrokRecordingProvider.ts admits exactly `sigrok-cli 0.7.2`
  # whose `--version` also reports libsigrokdecode; nixpkgs ships 0.8.0, which
  # the provider rejects outright. Take the package from the last nixpkgs
  # revision that carried 0.7.2 (with libsigrokdecode 0.5.3, also gone):
  # substituting the pinned tarball keeps this to one FOD fetch at evaluation
  # and a cached download at build time, and the older glibc/glib ride along
  # inside an independent executable with no ABI contact with the rest.
  sigrokCli =
    (import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/160b762eda6d139ac10ae081f8f78d640dd523eb.tar.gz";
      sha256 = "sha256-AqgkGHRrI6h/8FWuVbnkfFmXr4Bqsr4fV23aISqj/xg=";
    }) { system = stdenv.hostPlatform.system; }).sigrok-cli;

  # node_modules/frida is a source package: its install script runs
  # prebuild-install (or make) to place the N-API binding, which npmFlags
  # "--ignore-scripts" skips. Ship the upstream release artifact for the
  # frida version the lockfile pins instead; a lockfile bump must bump this.
  fridaVersion = "17.23.2";
  fridaBinding = fetchurl {
    url = "https://github.com/frida/frida/releases/download/${fridaVersion}/frida-v${fridaVersion}-napi-v8-linux-x64.tar.gz";
    hash = "sha256-n6j2aM6R6wNxPoVk3k+PveIyIz7pHXKcFnc/3hHbrpU=";
  };
in
buildNpmPackage rec {
  pname = "rea-agents";
  version = "6.7.0";

  # Build the pinned upstream source tag; leave its package manifest and lockfile pristine.
  src = fetchFromGitHub {
    owner = "morluto";
    repo = "rea";
    rev = "refs/tags/rea-agents-${version}";
    hash = "sha256-GKgXQZdzsmr2bEffi+UaffY5TseJ7dSQvWwF1kuz2og=";
  };

  # Skip dependency lifecycle scripts: frida's installer attempts a toolchain
  # network download, and no locked Linux x86_64 dependency needs these scripts.
  npmFlags = [ "--ignore-scripts" ];
  npmDepsHash = "sha256-BWMsF0ja+AyQg3w7BKVjzbI372HOKd2bFpFwbCAB5cA=";

  env = {
    HUSKY = "0";
    TURBO_TELEMETRY_DISABLED = "1";
  };

  nodejs = nodejs_24;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    procps
  ];

  # libstdc++/libgcc_s for the prebuilt @lydell/node-pty-linux-x64 pty.node.
  buildInputs = [ stdenv.cc.cc.lib ];
  # Retain the published runtime tree, not source, tests, docs, or build config.
  postInstall = ''
    packageDir="$out/lib/node_modules/rea-agents"
    find "$packageDir" -mindepth 1 -maxdepth 1 -print0 |
      while IFS= read -r -d $'\0' path; do
        case "''${path##*/}" in
          dist|skills|bridge|scripts|native|third_party|licenses|node_modules|package.json|README.md|LICENSE|DISCLAIMER.md|THIRD_PARTY_NOTICES.md|install.sh)
            ;;
          *)
            rm -rf "$path"
            ;;
        esac
      done

    # frida resolves its binding as module_root/build/frida_binding.node
    # (node_modules/frida/build/src/frida.js via `bindings`), so the artifact
    # dropped here is exactly what the runtime looks for. Installing it before
    # fixupPhase lets autoPatchelfHook give it a glibc RUNPATH like the
    # prebuilt @lydell/node-pty binding.
    fridaDir="$packageDir/node_modules/frida"
    if [ ! -f "$fridaDir/package.json" ]; then
      echo "the locked dependency tree no longer contains frida; drop fridaBinding and the frida installCheck" >&2
      exit 1
    fi
    lockedFridaVersion=$(${nodejs_24}/bin/node -p "require('$fridaDir/package.json').version")
    if [ "$lockedFridaVersion" != "${fridaVersion}" ]; then
      echo "locked frida is $lockedFridaVersion but fridaBinding pins ${fridaVersion}; update pkgs/rea-agents" >&2
      exit 1
    fi
    chmod -R u+w "$fridaDir"
    mkdir -p "$TMPDIR/frida-binding"
    tar xf ${fridaBinding} -C "$TMPDIR/frida-binding"
    install -m755 "$TMPDIR/frida-binding/build/frida_binding.node" \
      "$fridaDir/build/frida_binding.node"
  '';

  # npmInstallHook's $out/bin entries exec `node scripts/rea.mjs` directly,
  # so the env defaults must wrap the bin files, not the .mjs entrypoint.
  # Everything REA reads for itself is REA_-prefixed. The last two are the
  # ambient names the Ghidra provider and the jadx Java probe read verbatim
  # (src/ghidra/GhidraJavaLaunch.ts, src/android/JadxConfiguration.ts); REA
  # ships no REA_-prefixed alias for either, so renaming them would disable the
  # Ghidra and jadx providers rather than tidy the environment. `--set-default`
  # keeps them overridable for callers with their own Ghidra/JDK.
  postFixup = ''
    for bin in $out/bin/rea $out/bin/rea-agents; do
      wrapProgram "$bin" \
        --prefix PATH : ${lib.makeBinPath [ procps ]} \
        --set-default REA_ADB_PATH ${lib.getExe' android-tools "adb"} \
        --set-default REA_APKTOOL_COMMAND ${lib.getExe apktool} \
        --set-default REA_BINWALK_COMMAND ${lib.getExe binwalk} \
        --set-default REA_BROWSER_EXECUTABLE ${lib.getExe chromium} \
        --set-default REA_CAPINFOS_COMMAND ${lib.getExe' wireshark-cli "capinfos"} \
        --set-default REA_EVM_PRLIMIT_COMMAND ${lib.getExe' util-linux "prlimit"} \
        --set-default REA_FIRMWARE_PRLIMIT_COMMAND ${lib.getExe' util-linux "prlimit"} \
        --set-default REA_GDB_COMMAND ${lib.getExe gdb} \
        --set-default REA_ILSPY_CMD_PATH ${lib.getExe' ilspycmd "ilspycmd"} \
        --set-default REA_JADX_MCP_JAR ${jadx-headless-mcp.jar} \
        --set-default REA_JAVASCRIPT_PRLIMIT_COMMAND ${lib.getExe' util-linux "prlimit"} \
        --set-default REA_MITMDUMP_COMMAND ${lib.getExe' mitmproxy "mitmdump"} \
        --set-default REA_OBJDUMP_COMMAND ${lib.getExe' binutils "objdump"} \
        --set-default REA_PWNDBG_GDB ${lib.getExe gdb} \
        --set-default REA_PWNTOOLS_PYTHON ${reaPythonEnv}/bin/python \
        --set-default REA_RIZIN_COMMAND ${lib.getExe rizin} \
        --set-default REA_SIGROK_COMMAND ${lib.getExe' sigrokCli "sigrok-cli"} \
        --set-default REA_SIGROK_PRLIMIT_COMMAND ${lib.getExe' util-linux "prlimit"} \
        --set-default REA_TSHARK_COMMAND ${lib.getExe' wireshark-cli "tshark"} \
        --set-default REA_TSHARK_PRLIMIT_COMMAND ${lib.getExe' util-linux "prlimit"} \
        --set-default REA_UNBLOB_COMMAND ${lib.getExe unblob} \
        --set-default REA_WABT_BIN_DIRECTORY ${wabt}/bin \
        --set-default REA_WAKARU_COMMAND ${lib.getExe wakaru} \
        --set-default GHIDRA_INSTALL_DIR ${ghidra}/lib/ghidra \
        --set-default JAVA_HOME ${jdk21_headless}
    done
  '';

  # Version-gate checks: REA pins exact or release-line versions for several
  # providers (asserted in its own bridge code), so fail the build when a
  # pinned nixpkgs input drifts out of REA's accepted range. This runs in the
  # normal build, which makes drifting daily CI red without any CI changes.
  # `rea doctor` is reused for everything it covers (ghidra release line and
  # JDK bounds, jadx bridge jar, node runtime) so the accepted ranges always
  # come from the packaged REA itself; the remaining gates (exact Python
  # distributions, mitmproxy profile, firmware release lines, apktool
  # minimum) are asserted by hand against the constants in REA's bridge code.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME=$TMPDIR

    echo "rea --version: $($out/bin/rea --version)"

    # Doctor scopes ghidra+jadx as required providers; host/hopper/IDA/JEB/
    # skill checks stay informational (user-machine state, not package state).
    # A drifted provider makes the doctor exit nonzero and healthy=false.
    set +e
    $out/bin/rea doctor --provider ghidra --provider jadx --format json > doctor.json
    doctorStatus=$?
    set -e
    if [ $doctorStatus -ne 0 ]; then
      echo "rea doctor reported unhealthy pinned providers:" >&2
      cat doctor.json >&2
      exit 1
    fi
    ${reaPythonEnv}/bin/python -c '
    import json
    report = json.load(open("doctor.json"))
    failed = [c["name"] for c in report["scope_checks"] if not c["ok"]]
    assert not failed, f"rea doctor provider checks failed: {failed} — update pkgs/rea-agents pins"
    ilspy = [c for c in report["checks"] if c["name"] == "ilspycmd"]
    assert ilspy and ilspy[0]["ok"], "ilspycmd probe failed — update pkgs/rea-agents pins"
    '
    echo "doctor (node/ghidra/jadx/ilspycmd): ok"

    # bridge/pwntools/layout_impl.py PACKAGES: exact distribution versions.
    ${reaPythonEnv}/bin/python -c '
    import importlib.metadata
    expected = {"pwntools": "4.15.0", "pyelftools": "0.33", "unicorn": "2.1.2"}
    for name, want in expected.items():
        got = importlib.metadata.version(name)
        assert got == want, f"{name}: REA requires exactly {want}, pinned env has {got} — update pkgs/rea-agents"
    '
    echo "pwntools trio: ok"

    # bridge/mitmproxy/capture.py PROFILE = "12.2.3".
    ${mitmproxy}/bin/mitmdump --version 2>/dev/null | grep -q '^Mitmproxy: 12\.2\.3\b' \
      || { echo "mitmproxy drifted from REA's exact 12.2.3 profile — update pkgs/rea-agents" >&2; exit 1; }
    echo "mitmproxy: ok"

    # ApktoolConfiguration: minimum supported version 2.7.0.
    apktoolVersion=$(${apktool}/bin/apktool --version)
    [ "$(printf '%s\n2.7.0\n' "$apktoolVersion" | sort -V | head -1)" = "2.7.0" ] \
      || { echo "apktool $apktoolVersion is below REA's minimum 2.7.0" >&2; exit 1; }
    echo "apktool: ok ($apktoolVersion)"

    # FirmwareRelease: binwalk accepted line 3.1.x, unblob 26.6.x.
    ${binwalk}/bin/binwalk --version | grep -q '^binwalk 3\.1\.' \
      || { echo "binwalk drifted from REA's accepted 3.1.x line" >&2; exit 1; }
    [ "$(${unblob}/bin/unblob --version | cut -d. -f1-2)" = "26.6" ] \
      || { echo "unblob drifted from REA's accepted 26.6.x line" >&2; exit 1; }
    echo "binwalk/unblob: ok"

    # The pinned sibling tool must run (no REA-side version gate).
    ${wakaru}/bin/wakaru --version >/dev/null
    echo "wakaru: ok"

    # src/signals/SigrokRecordingProvider.ts admits exactly this banner plus
    # libsigrokdecode; both conditions are what the wrapper's REA_SIGROK_COMMAND
    # must satisfy, and nixpkgs' own sigrok-cli fails them.
    sigrokVersion=$(${sigrokCli}/bin/sigrok-cli --version)
    printf '%s\n' "$sigrokVersion" | grep -qx 'sigrok-cli 0\.7\.2' \
      || { echo "sigrok-cli is not the exact 0.7.2 REA requires — update pkgs/rea-agents" >&2; exit 1; }
    printf '%s\n' "$sigrokVersion" | grep -q 'libsigrokdecode' \
      || { echo "sigrok-cli 0.7.2 was built without libsigrokdecode — update pkgs/rea-agents" >&2; exit 1; }
    echo "sigrok-cli: ok"

    # Loading frida's binding is what every REA frida tool does first
    # (node_modules/frida/build/src/frida.js resolves build/frida_binding.node);
    # it catches a missing artifact and an unpatched loader path alike.
    ${nodejs_24}/bin/node --input-type=module -e "
    await import('file://$out/lib/node_modules/rea-agents/node_modules/frida/build/src/frida.js');
    " || { echo "frida failed to load its N-API binding — update pkgs/rea-agents" >&2; exit 1; }
    echo "frida binding: ok"

    runHook postInstallCheck
  '';

  passthru = {
    pythonEnv = reaPythonEnv;
  };

  meta = {
    description = "One MCP for reverse engineering across binaries, applications, and runtime behavior";
    homepage = "https://github.com/morluto/rea";
    license = lib.licenses.mit;
    # Bundled JavaScript is compiled from source; upstream native modules remain.
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    mainProgram = "rea";
    # The pwntools provider profile is Linux x64 only, and the pinned unicorn
    # wheel targets manylinux x86_64.
    platforms = [ "x86_64-linux" ];
  };
}
