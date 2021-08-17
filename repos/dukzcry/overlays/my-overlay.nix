{ unstable, config }:

self: super:
rec {
  dtrx = super.dtrx.overrideAttrs (oldAttrs: {
    postFixup = ''
      ${oldAttrs.postFixup}
      wrapProgram $out/bin/dtrx \
        --prefix PATH : "${super.lib.makeBinPath [ super.unrar ]}"
    '';
  });
  wifi-killer = with super; writeShellScriptBin "wifi-killer" ''
    pciid=02:00.0
    echo 1 > /sys/bus/pci/devices/0000:$pciid/remove
    sleep 5
    rmmod iwlmvm iwlwifi
    sleep 5
    echo 1 > /sys/bus/pci/rescan
    sleep 5
    modprobe iwlwifi iwlmvm
  '';
  # JUST UPDATE RELEASE
  inherit (unstable) steam goldendict ddccontrol;
  #lmms = super.lmms.overrideAttrs (oldAttrs: rec {
  #  cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWANT_WEAKJACK=OFF" ];
  #});
}
