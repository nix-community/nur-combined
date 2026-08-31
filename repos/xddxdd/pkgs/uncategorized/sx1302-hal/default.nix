{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sx1302-hal";
  version = "0-unstable-2023-02-06";
  src = fetchFromGitHub {
    owner = "NebraLtd";
    repo = "sx1302_hal";
    rev = "3760434a18e6ba47b695c22786195e57cc6b4c1c";
    hash = "sha256-8u4gQ1ifNrXzoOiXAZ535ZMZi8w6VRCljOC0u9xbJOg=";
  };
  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 packet_forwarder/lora_pkt_fwd $out/bin/lora_pkt_fwd
    install -Dm755 tools/reset_lgw.sh $out/bin/reset_lgw.sh
    install -Dm755 util_boot/boot $out/bin/boot
    install -Dm755 util_chip_id/chip_id $out/bin/chip_id
    install -Dm755 util_net_downlink/net_downlink $out/bin/net_downlink
    install -Dm755 util_spectral_scan/spectral_scan $out/bin/spectral_scan

    mkdir -p $out/conf/
    cp packet_forwarder/global_conf.* $out/conf/

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/NebraLtd/sx1302_hal";
    hardcodeZeroVersion = true;
  };
  meta = {
    mainProgram = "lora_pkt_fwd";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "SX1302/SX1303 Hardware Abstraction Layer and tools";
    homepage = "https://github.com/NebraLtd/sx1302_hal";
    license = lib.licenses.unfreeRedistributable;
  };
})
