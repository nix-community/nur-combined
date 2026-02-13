{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  bzip2,
  zlib,
  # Runtime dependencies for admin scripts
  coreutils,
  gnugrep,
  gawk,
  procps,
  psmisc,
  util-linux,
}:

let
  # The installer is a self-extracting shell script with an embedded tar.
  # URL is versionless (always serves latest); version is from embedded base.conf.
  # To update: download the installer, extract base.conf, and check `version = ...`.
  archSuffix = {
    x86_64-linux = "64";
    aarch64-linux = "arm64";
  };
in
stdenv.mkDerivation {
  pname = "cvm-agent";
  # Version extracted from embedded base.conf. URL is versionless; hash pins content.
  version = "1.5.0";

  src = fetchurl {
    url = "https://cloud-monitor-1258344699.cos.ap-guangzhou.myqcloud.com/sgagent/linux_stargate_installer";
    hash = "sha256-O+eitG/SFIzunmVGDspx1djPx57urItNOkpnzIproaU=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib # libstdc++.so.6, libgcc_s.so.1
    bzip2 # libbz2.so.1 (for bundled python2.6)
    zlib # libz.so.1
  ];

  # autoPatchelf: ignore optional Python modules' deps that aren't needed by barad_agent.
  # The aarch64 bundle has many more deps than x86_64 (ncurses, ssl, ffi, etc.)
  autoPatchelfIgnoreMissingDeps = [
    # x86_64 + aarch64: gdbm/crypt modules
    "libcrypt.so.1"
    "libgdbm.so.3"
    "libgdbm_compat.so.3"
    # aarch64-only: _ctypes module (weirdly linked against python2.7)
    "ld-linux-aarch64.so.1"
    "libffi.so.6"
    "libpython2.7.so.1.0"
    # aarch64-only: _curses/_curses_panel modules
    "libncursesw.so.5"
    "libpanelw.so.5"
    "libtinfo.so.5"
    # aarch64-only: _ssl/_hashlib modules (old OpenSSL)
    "libcrypto.so.10"
    "libssl.so.10"
    # aarch64-only: nis module
    "libnsl.so.1"
  ];

  dontUnpack = true;

  installPhase =
    let
      arch = archSuffix.${stdenv.hostPlatform.system};
    in
    ''
      runHook preInstall

      # Extract the embedded tar from the self-extracting installer
      tailNum=$(sed -n '/^#real installing packages append below/{=;q;}' "$src")
      tailNum=$((tailNum + 1))
      tail -n +"$tailNum" "$src" > package.tgz
      tar -xzf package.tgz

      # Extract the inner stargate archive
      tar -xzf stargate.tgz

      # Install sgagent binary
      install -Dm755 "stargate/bin/sgagent${arch}" "$out/bin/sgagent"

      # Install stargate libs (bundled libstdc++ fallbacks)
      mkdir -p "$out/lib"
      for f in stargate/lib/libstdcxx-*/*; do
        install -Dm644 "$f" "$out/lib/$(basename "$f")"
      done

      # Install config
      install -Dm644 stargate/etc/base.conf "$out/etc/base.conf"

      # Install admin scripts
      mkdir -p "$out/admin"
      for f in stargate/admin/*; do
        install -Dm755 "$f" "$out/admin/$(basename "$f")"
      done

      # Install systemd service file
      install -Dm644 systemd/stargate.service "$out/lib/systemd/system/stargate.service"

      # Install bundled Python 2.6 (required by barad_agent for metric collection).
      # This is a pre-built binary shipped inside the installer — not built from source.
      mkdir -p "$out/python26"
      cp -r "python26-${arch}/." "$out/python26/"
      chmod +x "$out/python26/bin/python"

      runHook postInstall
    '';

  # Patch scripts: replace hardcoded FHS paths with Nix store paths
  postFixup =
    let
      # PATH for admin scripts: coreutils (whoami, wc, rm, kill), gnugrep, gawk, procps (ps), psmisc (killall), util-linux (flock)
      runtimePath = lib.makeBinPath [
        coreutils
        gnugrep
        gawk
        procps
        psmisc
        util-linux
      ];
    in
    ''
      # Patch FHS install paths (only scripts that reference them)
      for f in "$out"/admin/{start,stop,uninstall}.sh; do
        substituteInPlace "$f" \
          --replace-fail '/usr/local/qcloud/stargate' "$out" \
          --replace-fail '/var/lib/qcloud/stargate' "$out"
      done

      # Patch FHS PATH -> Nix store PATH (two variants exist)
      for f in "$out"/admin/{start,restart,addcrontab,delcrontab,stop}.sh; do
        substituteInPlace "$f" \
          --replace-fail "export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'" \
                         "export PATH='${runtimePath}'"
      done
      substituteInPlace "$out/admin/uninstall.sh" \
        --replace-fail "export PATH='/usr/sbin:/sbin:/usr/bin:/bin'" \
                       "export PATH='${runtimePath}'"

      # Patch systemd service
      substituteInPlace "$out/lib/systemd/system/stargate.service" \
        --replace-fail '/var/lib/qcloud/stargate' "$out" \
        --replace-fail '/usr/bin/sh' '/bin/sh'
    '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Tencent Cloud CVM guest agent (Stargate + BaradAgent monitor)";
    homepage = "https://cloud.tencent.com/document/product/248/6211";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "sgagent";
  };
}
