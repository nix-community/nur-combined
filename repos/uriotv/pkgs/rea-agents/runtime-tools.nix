{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  python313,
  autoPatchelfHook,
  makeWrapper,
  callPackage,
  ghidra,
  jdk21,
  chromium,
  android-tools,
  apktool,
  ilspycmd,
  binwalk,
  unblob,
  mitmproxy,
  util-linux,
  coreutils,
}:

let
  # REA checks these versions exactly; a newer system Python environment is
  # not interchangeable with the audited offline ELF decoder.
  decoderPython = python313.override {
    packageOverrides = final: prev: {
      pyelftools = prev.pyelftools.overrideAttrs {
        version = "0.33";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/a3/11/767522582afab1b884d277de0e6e011640cb9d7292a38694b4b1a1df1ae8/pyelftools-0.33.tar.gz";
          sha256 = "660d82dcbeb8e83d1702bd97f223f761625da06111c0cc988eac6b8ab0c1b61f";
        };
        # The sdist omits the upstream external readelf test fixture.
        doCheck = false;
      };
      unicorn = prev.buildPythonPackage {
        pname = "unicorn";
        version = "2.1.2";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/57/88/bc15c97ce48e83b330c457d71d467d7b0e59c9e4debcdca9f0caefc676e1/unicorn-2.1.2-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
          sha256 = "9c6a0bdfc38266600eacee2f264202fad1bff8590ad36d187b47033a782f12dc";
        };
        nativeBuildInputs = [ autoPatchelfHook ];
        buildInputs = [ stdenv.cc.cc.lib ];
        pythonImportsCheck = [ "unicorn" ];
        meta = {
          license = lib.licenses.gpl2Plus;
          sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
          platforms = [ "x86_64-linux" ];
        };
      };
      pwntools = prev.pwntools.override {
        inherit (final) pyelftools unicorn;
      };
    };
  };
  pwntoolsPython = decoderPython.withPackages (p: [
    p.pwntools
    p.pyelftools
    p.unicorn
  ]);

  # Unblob's pyfatfs depends on fs, which still imports pkg_resources. Use
  # Python 3.13 and keep a scoped, compatible setuptools for that dependency.
  fsSetuptools = python313.pkgs.buildPythonPackage {
    pname = "setuptools";
    version = "80.9.0";
    format = "wheel";
    src = python313.pkgs.fetchPypi {
      pname = "setuptools";
      version = "80.9.0";
      format = "wheel";
      dist = "py3";
      python = "py3";
      sha256 = "062d34222ad13e0cc312a4c02d73f059e86a4acbfbdea8f8f76b28c99f306922";
    };
    meta.license = lib.licenses.mit;
  };
  extractionPython = python313.override {
    packageOverrides = final: prev: {
      fs = prev.fs.override { setuptools = fsSetuptools; };
    };
  };
  unblobRuntime = unblob.override { python3 = extractionPython; };

  jadxMcpJar = fetchurl {
    url = "https://github.com/1013503897/jadx-headless-mcp/releases/download/v0.7.1/jadx-headless-mcp-0.7.1-all.jar";
    sha256 = "sha256-bl6s9QC2QpK/tzxJeXwZWPbuRGRuQ+hoA5rn/rVz/3U=";
  };

  wakaru = stdenv.mkDerivation {
    pname = "rea-wakaru";
    version = "1.14.0";
    src = fetchurl {
      url = "https://github.com/pionxzh/wakaru/releases/download/v1.14.0/wakaru-linux-x64.tar.gz";
      sha256 = "sha256-2w5iADRyMZWrQm6U0A1V29j9AQapKK2iVj8RAxltCfo=";
    };
    sourceRoot = ".";
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ stdenv.cc.cc.lib ];
    installPhase = ''
      runHook preInstall
      install -Dm755 wakaru "$out/bin/wakaru"
      runHook postInstall
    '';
    meta = {
      license = lib.licenses.asl20;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };

  # The official portable distribution includes its own GDB, Python and all
  # plugin dependencies. Its launchers explicitly use the bundled ELF loader.
  pwndbg = stdenvNoCC.mkDerivation {
    pname = "rea-pwndbg";
    version = "2026.09.15";
    src = fetchurl {
      url = "https://github.com/pwndbg/pwndbg/releases/download/2026.09.15/pwndbg_2026.09.15_x86_64-portable.tar.xz";
      sha256 = "sha256-e6ZGZu5ZWIW6Sw4HP4XkI4KRA+n9vpIbpO7xrNkVCAM=";
    };
    sourceRoot = "pwndbg";
    nativeBuildInputs = [ makeWrapper ];
    dontStrip = true;
    dontPatchELF = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/lib/pwndbg" "$out/bin"
      cp -a . "$out/lib/pwndbg/"
      ln -s "$out/lib/pwndbg/bin/pwndbg" "$out/bin/pwndbg"
      cat > "$out/lib/pwndbg/rea-gdbinit.py" <<'PY'
      from pwndbginit.gdbinit import main_try
      main_try()
      PY
      # Set PATH before the launcher's initial dirname/realpath/uname calls.
      makeWrapper "$out/lib/pwndbg/bin/gdb" "$out/bin/rea-pwndbg-gdb" \
        --prefix PATH : ${lib.makeBinPath [ coreutils ]}
      runHook postInstall
    '';
    meta = {
      license = lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };
  nativeAot = callPackage ./nativeaot.nix { inherit ghidra jdk21; };
in
{
  inherit
    pwntoolsPython
    jadxMcpJar
    wakaru
    pwndbg
    nativeAot
    ;
  packages = [
    chromium
    android-tools
    apktool
    ilspycmd
    binwalk
    unblobRuntime
    mitmproxy
    util-linux
  ];
  environment = {
    REA_BROWSER_EXECUTABLE = lib.getExe chromium;
    REA_ADB_PATH = "${android-tools}/bin/adb";
    REA_APKTOOL_COMMAND = lib.getExe apktool;
    REA_ILSPY_CMD_PATH = lib.getExe ilspycmd;
    REA_JADX_MCP_JAR = jadxMcpJar;
    REA_BINWALK_COMMAND = lib.getExe binwalk;
    REA_UNBLOB_COMMAND = lib.getExe unblobRuntime;
    REA_MITMDUMP_COMMAND = "${mitmproxy}/bin/mitmdump";
    REA_PWNTOOLS_PYTHON = "${pwntoolsPython}/bin/python3";
    REA_PWNDBG_GDB = "${pwndbg}/bin/rea-pwndbg-gdb";
    REA_PWNDBG_GDBINIT = "${pwndbg}/lib/pwndbg/rea-gdbinit.py";
    REA_PWNDBG_VENV_PATH = "${pwndbg}/lib/pwndbg";
    PWNDBG_NO_AUTOUPDATE = "1";
    REA_WAKARU_COMMAND = "${wakaru}/bin/wakaru";
    REA_FIRMWARE_PRLIMIT_COMMAND = "${util-linux}/bin/prlimit";
    REA_JAVASCRIPT_PRLIMIT_COMMAND = "${util-linux}/bin/prlimit";
    REA_EVM_PRLIMIT_COMMAND = "${util-linux}/bin/prlimit";
  };
}
