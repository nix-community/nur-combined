{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

let
  # The installer is a self-extracting shell script with an embedded tar.
  # URL is versionless (always serves latest); version is from embedded base.conf.
  archSuffix = {
    x86_64-linux = "64";
    aarch64-linux = "arm64";
  };
in
stdenv.mkDerivation {
  pname = "cvm-agent";
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

      runHook postInstall
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
