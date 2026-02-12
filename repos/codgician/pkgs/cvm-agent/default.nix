{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  bzip2,
  libxcrypt-legacy,
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
    zlib # libz.so.1 (needed by sgagentarm64 and python26 zlib/binascii modules)
    bzip2 # libbz2.so.1 (python26 bz2 module)
    libxcrypt-legacy # libcrypt.so.1 (python26 crypt module)
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

      # Install config
      install -Dm644 stargate/etc/base.conf "$out/etc/base.conf"

      # Install admin scripts
      mkdir -p "$out/admin"
      for f in stargate/admin/*; do
        install -Dm755 "$f" "$out/admin/$(basename "$f")"
      done

      # Install python26 runtime (used by barad_agent monitoring component)
      mkdir -p "$out/python26"
      cp -r "python26-${arch}/." "$out/python26/"
      chmod +x "$out/python26/bin/python"

      # Install systemd service file
      install -Dm644 systemd/stargate.service "$out/lib/systemd/system/stargate.service"

      runHook postInstall
    '';

  # Patch admin scripts: replace hardcoded FHS paths with store paths
  postFixup = ''
    for f in "$out"/admin/*.sh; do
      substituteInPlace "$f" \
        --replace-quiet '/usr/local/qcloud/stargate' "$out" \
        --replace-quiet '/var/lib/qcloud/stargate' "$out"
    done

    # Patch systemd service to use store paths
    substituteInPlace "$out/lib/systemd/system/stargate.service" \
      --replace-quiet '/var/lib/qcloud/stargate' "$out" \
      --replace-quiet '/usr/bin/sh' '/bin/sh'
  '';

  # Python 2.6's gdbm/dbm modules need libgdbm.so.3 which is ancient;
  # these modules are non-essential. libutil.so.1 was merged into glibc.
  autoPatchelfIgnoreMissingDeps = [
    "libgdbm.so.3"
    "libgdbm_compat.so.3"
    "libutil.so.1"
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Tencent Cloud CVM guest agent (Stargate)";
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
