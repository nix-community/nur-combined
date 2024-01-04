{ stdenv, fetchzip, fetchurl, glib, lib, alsa-lib, gtk3, libunwind, x264, vulkan-loader, xorg, libva, libdrm, libvdpau, libbsd, libmd, xz }:
stdenv.mkDerivation rec {
  pname = "alvr";
  version = "v20.5.0";

  src = fetchzip {
      url = "https://github.com/alvr-org/ALVR/releases/download/${version}/alvr_streamer_linux.tar.gz";
      name = "${pname}-${version}";
      sha256 ="sha256-RkUVWk+6V+5MLwsvT7/d8JVps2MLnZfUMcWi8144E0I=";
    };

  sourceRoot = ".";

  rpath = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    alsa-lib
    gtk3
    glib
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
  dontBuild = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/ALVR $out/share/vulkan/explicit_layer.d $out/share/applications/ $out/share/icons/hicolor/256x256/apps/
    mv ${src.name}/* $out/opt/ALVR

    cp ${./alvr.png} $out/share/icons/hicolor/256x256/apps/alvr.png
    cp ${./alvr.desktop} $out/share/applications/alvr.desktop

    ln -s $out/opt/ALVR/bin/alvr_dashboard $out/bin 
    ln -s $out/opt/ALVR/share/vulkan/explicit_layer.d/alvr_x86_64.json $out/share/vulkan/explicit_layer.d

    runHook postInstall
  '';
  fixupPhase = ''
    runHook preFixup

    patchelf --set-rpath "${rpath}" --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/opt/ALVR/bin/alvr_dashboard
    patchelf --set-rpath "${rpath}" --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/opt/ALVR/libexec/alvr/vrcompositor-wrapper
    patchelf --set-rpath "${rpath}" $out/opt/ALVR/libexec/alvr/alvr_drm_lease_shim.so
    patchelf --set-rpath "${rpath}" $out/opt/ALVR/lib64/libalvr_vulkan_layer.so
    patchelf --set-rpath "${rpath}" $out/opt/ALVR/lib64/alvr/bin/linux64/driver_alvr_server.so

    sed -i "s#../../../lib64/libalvr_vulkan_layer.so#$out/opt/ALVR/lib64/libalvr_vulkan_layer.so#" $out/opt/ALVR/share/vulkan/explicit_layer.d/alvr_x86_64.json
    
    runHook postFixup
  '';

  meta = with lib; {
    description = "ALVR - Stream VR games from your PC to your headset via Wi-Fi.";
    homepage = "https://github.com/alvr-org/ALVR";
    maintainers = with maintainers; [];
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}