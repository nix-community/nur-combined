{
  stdenv,
  sources,
  lib,
}:
stdenv.mkDerivation rec {
  inherit (sources.sx1302-hal) pname version src;
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

  meta = {
    mainProgram = "lora_pkt_fwd";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "SX1302/SX1303 Hardware Abstraction Layer and Tools (packet forwarder...)";
    homepage = "https://github.com/NebraLtd/sx1302_hal";
    license = lib.licenses.unfreeRedistributable;
  };
}
