{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPypi,
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
  rizin,
  sigrok-cli,
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
in
buildNpmPackage rec {
  pname = "rea-agents";
  version = "6.5.0";

  # Build the pinned upstream source tag; leave its package manifest and lockfile pristine.
  src = fetchFromGitHub {
    owner = "morluto";
    repo = "rea";
    rev = "refs/tags/rea-agents-${version}";
    hash = "sha256-fPe+tqkSRR5K+zSVWb6kjI6/HbQSJ8DHjLJwSWu8NzI=";
  };

  # Skip dependency lifecycle scripts: frida's installer attempts a toolchain
  # network download, and no locked Linux x86_64 dependency needs these scripts.
  npmFlags = [ "--ignore-scripts" ];
  npmDepsHash = "sha256-EQKhS1S7Hsfjbo5GikMeAFc2HFtALsDcw6XnJATUryw=";

  env = {
    HUSKY = "0";
    TURBO_TELEMETRY_DISABLED = "1";
  };

  nodejs = nodejs_24;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
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
  '';

  # npmInstallHook's $out/bin entries exec `node scripts/rea.mjs` directly,
  # so the env defaults must wrap the bin files, not the .mjs entrypoint.
  postFixup = ''
    for bin in $out/bin/rea $out/bin/rea-agents; do
      wrapProgram "$bin" \
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
        --set-default REA_PWNTOOLS_PYTHON ${reaPythonEnv}/bin/python \
        --set-default REA_RIZIN_COMMAND ${lib.getExe rizin} \
        --set-default REA_SIGROK_COMMAND ${lib.getExe' sigrok-cli "sigrok-cli"} \
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
