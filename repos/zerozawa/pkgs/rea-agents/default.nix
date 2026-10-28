{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPypi,
  fetchurl,
  buildNpmPackage,
  makeWrapper,
  autoPatchelfHook,
  nodejs_26,
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
  # REA's pwntools bridges (bridge/pwntools/layout_impl.py,
  # recorded_crash_impl.py) reject any Python whose installed distributions are
  # not exactly pwntools 4.15.0, pyelftools 0.33 and unicorn 2.1.2. nixpkgs
  # already ships pwntools 4.15.0; pyelftools 0.33 is genuinely required (the
  # adapter subclasses its iterators with 0.33's filter arguments), so only that
  # one is overridden here. The unicorn pin is a pwntools lockstep check rather
  # than a behaviour the bridges use — neither bridge imports unicorn, and a
  # layout run over a dynamic ELF projects byte-identical records under 2.1.2
  # and nixpkgs' 2.1.4 — so postPatch follows the packaged version instead.
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

  # Commit behind jadx-headless-mcp's v<version> tag. REA records it as the
  # jadx source revision in Evidence once the audited constants are re-pinned to
  # the packaged JAR; bump it together with pkgs/jadx-headless-mcp.
  jadxRevision = "2b2a560e8035169f75e3c4f1695e773f9c0eebd0";
in
buildNpmPackage rec {
  pname = "rea-agents";
  version = "6.8.0";

  # Build the pinned upstream source tag; leave its package manifest and lockfile pristine.
  src = fetchFromGitHub {
    owner = "morluto";
    repo = "rea";
    rev = "refs/tags/rea-agents-${version}";
    hash = "sha256-2ADn3U3lvUoB4tCEpzO0rMfYE4sis+5uBiEazcp0gpI=";
  };

  # REPO PATCH: re-pin REA's audited jadx-headless-mcp release to the version
  # this repository packages (see jadxRevision).
  postPatch = ''
    jadxJar=$(echo ${jadx-headless-mcp}/share/java/*-all.jar)
    jadxSha=$(sha256sum "$jadxJar" | cut -d' ' -f1)

    # REA pins the audited jadx-headless-mcp release and refuses any engine that
    # reports a different version (src/android/JadxSession.ts). This repository
    # builds that JAR from source, so its digest can never equal upstream's
    # release artifact; point the audited constants at the packaged version and
    # at the digest of the JAR that REA_JADX_MCP_JAR actually launches. REA then
    # keeps its strict check and records the real source revision in Evidence.
    substituteInPlace src/android/JadxRelease.ts \
      --replace-fail 'version: "0.7.1"' 'version: "${jadx-headless-mcp.version}"' \
      --replace-fail 'revision: "5844800a486d2248fa949b74c9896285f5b54de2"' 'revision: "${jadxRevision}"' \
      --replace-fail 'sha256: "6e5eacf500b64292bfb73c49797c1958f6ee44646e43e868039ae7feb573ff75"' "sha256: \"$jadxSha\"" \
      --replace-fail 'releases/download/v0.7.1/jadx-headless-mcp-0.7.1-all.jar' 'releases/download/v${jadx-headless-mcp.version}/jadx-headless-mcp-${jadx-headless-mcp.version}-all.jar'

    # bridge/mitmproxy/capture.py rejects any mitmproxy whose version differs
    # from PROFILE = "12.2.3". The gate guards the native tnetstring record
    # schema; a capture written by 12.2.3 and one written by 12.3.0 project to
    # byte-identical records under either version's mitmdump (headers, cookies,
    # redactions included), so follow the packaged mitmproxy instead of pinning
    # an older nixpkgs for the whole package. The installCheck decodes a fixture
    # through the packaged binary, which is what turns a schema break red.
    substituteInPlace bridge/mitmproxy/capture.py \
      --replace-fail 'PROFILE = "12.2.3"' 'PROFILE = "${mitmproxy.version}"'

    # Same treatment for the pwntools bridges' unicorn sibling pin: neither
    # bridge imports unicorn, so follow the packaged distribution.
    substituteInPlace bridge/pwntools/layout_impl.py bridge/pwntools/recorded_crash_impl.py \
      --replace-fail 'unicorn@2.1.2' 'unicorn@${python313.pkgs.unicorn.version}' \
      --replace-fail '"unicorn": "2.1.2"' '"unicorn": "${python313.pkgs.unicorn.version}"'
  '';

  # Skip dependency lifecycle scripts: frida's installer attempts a toolchain
  # network download, and no locked Linux x86_64 dependency needs these scripts.
  npmFlags = [ "--ignore-scripts" ];
  npmDepsHash = "sha256-3WPXD+qm5WVfrTEvepKwX5RZBfbLBcPB0uDmKIx4MR8=";

  env = {
    HUSKY = "0";
    TURBO_TELEMETRY_DISABLED = "1";
  };

  # 6.8.0's `npm run compile` drives the Rust TypeScript compiler through
  # @tsrs/linux-x64-gnu, a prebuilt glibc executable whose interpreter is
  # /lib64/ld-linux-x86-64.so.2; exec fails with ENOENT inside the sandbox.
  # fixupPhase's autoPatchelfHook only runs after the build script, so patch
  # the binary first.
  preBuild = ''
    tsrsDir=node_modules/@tsrs/linux-x64-gnu
    if [ ! -x "$tsrsDir/tsrs" ]; then
      echo "the locked dependency tree no longer installs $tsrsDir/tsrs; check scripts/run-typescript.mjs and update pkgs/rea-agents" >&2
      exit 1
    fi
    autoPatchelf "$tsrsDir"
  '';

  nodejs = nodejs_26;

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
    lockedFridaVersion=$(${nodejs_26}/bin/node -p "require('$fridaDir/package.json').version")
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

    # bridge/pwntools/layout_impl.py PACKAGES: exact distribution versions, with
    # unicorn following the packaged one (patched, see postPatch).
    ${reaPythonEnv}/bin/python -c '
    import importlib.metadata
    expected = {"pwntools": "4.15.0", "pyelftools": "0.33", "unicorn": "${python313.pkgs.unicorn.version}"}
    for name, want in expected.items():
        got = importlib.metadata.version(name)
        assert got == want, f"{name}: the bridge requires exactly {want}, pinned env has {got} — update pkgs/rea-agents"
    '
    echo "pwntools trio: ok"

    # mitmproxy: PROFILE is patched to the packaged version in postPatch, so the
    # drift alarm is a decode rather than a version string. Encode one flow
    # record, run the installed adapter through the packaged mitmdump, and
    # require the projected request back with its sensitive header redacted.
    mkdir -p mitmproxy-check/conf
    ${reaPythonEnv}/bin/python - > mitmproxy-check/capture.mitm <<'PY'
    import sys

    def encode(value):
        if value is None:
            return b"0:~"
        if isinstance(value, str):
            payload = value.encode()
            return str(len(payload)).encode() + b":" + payload + b";"
        if isinstance(value, bytes):
            return str(len(value)).encode() + b":" + value + b","
        if isinstance(value, list):
            payload = b"".join(encode(item) for item in value)
            return str(len(payload)).encode() + b":" + payload + b"]"
        if isinstance(value, dict):
            payload = b"".join(encode(key) + encode(item) for key, item in value.items())
            return str(len(payload)).encode() + b":" + payload + b"}"
        raise TypeError(type(value))

    record = {
        "request": {
            "scheme": "https",
            "authority": "example.test",
            "path": "/check?q=1",
            "method": "GET",
            "headers": [[b"Host", b"example.test"], [b"Cookie", b"a=b"]],
        },
        "response": None,
        "websocket": None,
    }
    sys.stdout.buffer.write(encode(record))
    PY
    printf '{"snapshot_path":"%s","reply_path":"%s","sensitive_values":["cookie"]}' \
      "$PWD/mitmproxy-check/capture.mitm" "$PWD/mitmproxy-check/reply.json" \
      > mitmproxy-check/request.json
    timeout 120 ${lib.getExe' mitmproxy "mitmdump"} --no-server -q \
      --set confdir="$PWD/mitmproxy-check/conf" \
      --set rea_request_path="$PWD/mitmproxy-check/request.json" \
      -s "$out/lib/node_modules/rea-agents/bridge/mitmproxy/capture.py" \
      || { echo "the packaged mitmdump did not complete the capture adapter run — update pkgs/rea-agents" >&2; exit 1; }
    ${reaPythonEnv}/bin/python -c '
    import json
    reply = json.load(open("mitmproxy-check/reply.json"))
    assert reply["ok"], reply
    request = reply["value"]["records"][0]["reported"]["request"]
    assert request["path"] == "/check?q=1", request
    assert request["headers"][1][1] is None, "the sensitive header was not redacted"
    ' || { echo "mitmproxy ${mitmproxy.version} no longer projects REA's record schema — update pkgs/rea-agents" >&2; exit 1; }
    echo "mitmproxy: ok (${mitmproxy.version} profile)"

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
    ${nodejs_26}/bin/node --input-type=module -e "
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
