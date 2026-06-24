{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}:
stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
  pname = "vmware-fusion";
  version = "13.6.3";

  # NOTE: This is my bypass for them locking downloads behind an account, so expect to never see updates.
  src = fetchurl {
    url = "https://api.serversmp.xyz/upload/6869eb38cd2a3ec4e9b32fc8.tar";
    hash = "sha256-BBX8nJle+VnzkFu9l9RWDmcBhW0ik7RK7R2aojo7fEE=";
  };

  meta = {
    description = "Create, manage, and run virtual machines";
    homepage = "https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [Prinky];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = lib.platforms.darwin;
  };

  nativeBuildInputs = [unzip];

  unpackPhase = ''
    runHook preUnpack
    tar xf $src
    unzip -q "com.vmware.fusion.zip"
    runHook postUnpack
  '';

  extraInstall = ''
    mkdir -p $out/bin
    libDir="$out/Applications/VMware Fusion.app/Contents/Library"

    ln -s "$libDir/vkd/bin/vctl" $out/bin/vctl
    ln -s "$libDir/vmnet-bridge" $out/bin/vmnet-bridge
    ln -s "$libDir/vmnet-cfgcli" $out/bin/vmnet-cfgcli
    ln -s "$libDir/vmnet-cli" $out/bin/vmnet-cli
    ln -s "$libDir/vmnet-dhcpd" $out/bin/vmnet-dhcpd
    ln -s "$libDir/vmnet-natd" $out/bin/vmnet-natd
    ln -s "$libDir/vmnet-netifup" $out/bin/vmnet-netifup
    ln -s "$libDir/vmnet-sniffer" $out/bin/vmnet-sniffer
    ln -s "$libDir/vmcli" $out/bin/vmcli
    ln -s "$libDir/vmrest" $out/bin/vmrest
    ln -s "$libDir/vmrun" $out/bin/vmrun
    ln -s "$libDir/vmss2core" $out/bin/vmss2core
    ln -s "$libDir/VMware OVF Tool/ovftool" $out/bin/ovftool
    ln -s "$libDir/vmware-aewp" $out/bin/vmware-aewp
    ln -s "$libDir/vmware-authd" $out/bin/vmware-authd
    ln -s "$libDir/vmware-cloneBootCamp" $out/bin/vmware-cloneBootCamp
    ln -s "$libDir/vmware-id" $out/bin/vmware-id
    ln -s "$libDir/vmware-ntfs" $out/bin/vmware-ntfs
    ln -s "$libDir/vmware-rawdiskAuthTool" $out/bin/vmware-rawdiskAuthTool
    ln -s "$libDir/vmware-rawdiskCreator" $out/bin/vmware-rawdiskCreator
    ln -s "$libDir/vmware-remotemks" $out/bin/vmware-remotemks
    ln -s "$libDir/vmware-usbarbitrator" $out/bin/vmware-usbarbitrator
    ln -s "$libDir/vmware-vdiskmanager" $out/bin/vmware-vdiskmanager
    ln -s "$libDir/vmware-vmdkserver" $out/bin/vmware-vmdkserver
    ln -s "$libDir/vmware-vmx" $out/bin/vmware-vmx
    ln -s "$libDir/vmware-vmx-debug" $out/bin/vmware-vmx-debug
    ln -s "$libDir/vmware-vmx-stats" $out/bin/vmware-vmx-stats
  '';
})
