{ stdenv, fetchzip, lib, alsa-lib, gtk3, libunwind, x264, vulkan-loader, xorg, libva, libdrm, libvdpau, libbsd, libmd, xz }:
stdenv.mkDerivation rec {
  pname = "alvr";
  version = "v20.4.3";

  src = fetchzip {
      url = "https://github.com/alvr-org/ALVR/releases/download/${version}/alvr_streamer_linux.tar.gz";
      name = "${pname}-${version}";
      sha256 ="sha256-2gCy25FaEPe/eDddhUI8xKM1xrlthIk/yaCfbSLhlek=";
    };

  sourceRoot = ".";
  outputs = [ "out" "driver" ];
  rpath = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    alsa-lib
    gtk3
    x264.lib
    vulkan-loader
    xorg.libX11
    xorg.libXau
    xorg.libXdmcp
    xorg.libXext
    xorg.libXfixes
    libva
    libdrm
    libunwind
    libbsd
    libmd
    xz
  ];
  preferLocalBuild = true;
  installPhase = ''
    mkdir -p $out/bin $out/share/alvr
    mkdir -p $driver/share/vulkan/explicit_layer.d
    mv ${src.name}/* $out/share/alvr

    ln -s $out/share/alvr/bin/alvr_dashboard $out/bin 
   
    # Driver
    ln -s $out/share/alvr/share/vulkan/explicit_layer.d/alvr_x86_64.json $driver/share/vulkan/explicit_layer.d/alvr_x86_64.json
    ln -s $out/share/alvr/lib64 $driver/lib

    
    ls -la $out/share/alvr

  '';
  fixupPhase = ''
    patchelf --set-rpath "${rpath}" --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/share/alvr/bin/alvr_dashboard
    patchelf --set-rpath "${rpath}" --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/share/alvr/libexec/alvr/vrcompositor-wrapper
    patchelf --set-rpath "${rpath}" $out/share/alvr/libexec/alvr/alvr_drm_lease_shim.so
    patchelf --set-rpath "${rpath}" $out/share/alvr/lib64/libalvr_vulkan_layer.so
    patchelf --set-rpath "${rpath}" $out/share/alvr/lib64/alvr/bin/linux64/driver_alvr_server.so

    
    sed -i "s#../../../lib64/libalvr_vulkan_layer.so#$out/share/alvr/lib64/libalvr_vulkan_layer.so#" $out/share/alvr/share/vulkan/explicit_layer.d/alvr_x86_64.json

  '';

  meta = with lib; {
    description = "ALVR - Stream VR games from your PC to your headset via Wi-Fi.";
    homepage = "https://github.com/alvr-org/ALVR";
    maintainers = with maintainers; [];
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}