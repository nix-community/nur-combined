{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
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
    zlib # libz.so.1
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

      # Install systemd service file
      install -Dm644 systemd/stargate.service "$out/lib/systemd/system/stargate.service"

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
