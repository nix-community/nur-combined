{ lib
, stdenv
, fetchurl
, cmake
, glib
, nss
, nspr
, atk
, at-spi2-atk
, libdrm
, expat
, mesa
, gtk3
, pango
, cairo
, alsa-lib
, dbus
, at-spi2-core
, cups
, libcef
, libxkbcommon
, xorg
, zlib
, openssl
, wayland
, systemd
, pkgs
}:

let
  vk_rpath = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    xorg.libX11
  ];
  gl_rpath = lib.makeLibraryPath [
    stdenv.cc.cc.lib
  ];
  rpath = lib.makeLibraryPath [
    glib
    nss
    nspr
    atk
    at-spi2-atk
    libdrm
    expat
    xorg.libxcb
    libxkbcommon
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    mesa
    gtk3
    pango
    cairo
    alsa-lib
    dbus
    at-spi2-core
    cups
    xorg.libxshmfence
  ];
  platforms = {
    "aarch64-linux" = {
      platformStr = "linuxarm64";
      projectArch = "arm64";
    };
    "x86_64-linux" = {
      platformStr = "linux64";
      projectArch = "x86_64";
    };
  };
  platforms."aarch64-linux".sha256 = "0c034h0hcsff4qmibizjn2ik5pq1jb4p6f0a4k6nrkank9m0x7ap";
  platforms."x86_64-linux".sha256 = "02pj4dgfswpaglxkmbd9970znixlv82wna4xxhwjh7i5ps24a0n6";

  platformInfo = builtins.getAttr stdenv.targetPlatform.system platforms;
in
stdenv.mkDerivation rec {
  pname = "cef-binary";
  version = pkgs.libcef.version;
  src = pkgs.libcef.src;

  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ "-DPROJECT_ARCH=${platformInfo.projectArch}" ];
  makeFlags = [ "libcef_dll_wrapper" ];
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out/lib/ $out/share/cef/  $out/bin/
    cp -r ../Release $out/share/cef/
    cp -r ../Resources $out/share/cef/
    cp -r ../include $out/share/cef/

    cp -r libcef_dll_wrapper  $out/share/cef/
    
    patchelf --set-rpath "$out/share/cef/Release/:${rpath}" $out/share/cef/Release/libcef.so
    patchelf --set-rpath "$out/share/cef/Release/:${gl_rpath}" $out/share/cef/Release/libEGL.so
    patchelf --set-rpath "$out/share/cef/Release/:${gl_rpath}" $out/share/cef/Release/libGLESv2.so
    patchelf --set-rpath "$out/share/cef/Release/:${vk_rpath}" $out/share/cef/Release/libvulkan.so.1
    patchelf --set-rpath "$out/share/cef/Release/:${vk_rpath}" $out/share/cef/Release/libvk_swiftshader.so
    
    patchelf --set-rpath "$out/share/cef/Release/:${vk_rpath}" --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/share/cef/Release/chrome-sandbox

    ln -s $out/share/cef/Release/chrome-sandbox $out/bin
    ln -s $out/share/cef/Release/libcef.so $out/lib
    ln -s $out/share/cef/libcef_dll_wrapper/libcef_dll_wrapper.a $out/lib/
    ln -s $out/share/cef/include $out/

    sed -i "s#./libvk_swiftshader.so#$out/share/cef/Release/libvk_swiftshader.so#" $out/share/cef/Release/vk_swiftshader_icd.json



    
  '';
  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Simple framework for embedding Chromium-based browsers in other applications";
    homepage = "https://cef-builds.spotifycdn.com/index.html";
    maintainers = with maintainers; [];
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
