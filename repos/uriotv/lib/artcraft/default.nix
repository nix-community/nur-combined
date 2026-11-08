# Binary releases from the official upstream repositories, not Flatpaks/AppImages.
{ lib, stdenvNoCC, fetchurl, autoPatchelfHook, makeWrapper, alsa-lib, alsa-plugins, dbus,
  libGL, libdrm, libva, libx11, libxcb, libxcursor, libxext, libxfixes, libxi,
  libxinerama, libxkbcommon, libxrandr, libxrender, libpulseaudio, wayland,
  vulkan-loader, zlib, fontconfig, freetype, stdenv, pname, source, description }:
let
  inherit (source) version hash;
  runtimeLibraries = [
    alsa-lib alsa-plugins dbus libGL libdrm libva libx11 libxcb libxcursor libxext libxfixes
    libxi libxinerama libxkbcommon libxrandr libxrender libpulseaudio wayland
    vulkan-loader zlib fontconfig freetype stdenv.cc.cc.lib
  ];
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  src = fetchurl {
    url = "https://github.com/storytold/${pname}/releases/download/v${version}/${pname}-${version}-linux-x86_64.tar.gz";
    inherit hash;
  };
  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = runtimeLibraries;
  dontBuild = true;
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -a ./. "$out/"
    test -x "$out/bin/${pname}"
    test -f "$out/share/applications/ai.storyteller.${pname}.desktop"
    runHook postInstall
  '';
  # Winit/wgpu, audio backends, VA-API and GPU drivers are loaded via dlopen.
  # Preserve access to the host driver; this is a normal native process, not FHS.
  postFixup = ''
    for binary in "$out/bin/"*; do
      if [ -f "$binary" ] && [ -x "$binary" ]; then
        wrapProgram "$binary" \
          --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}:/run/opengl-driver/lib" \
          --set-default ALSA_PLUGIN_DIR "${alsa-plugins}/lib/alsa-lib"
      fi
    done
  '';
  meta = {
    inherit description;
    homepage = "https://github.com/storytold/${pname}";
    # These official binary releases bundle additional assets with distinct terms.
    # Do not redistribute to our public Cachix until those terms are audited.
    license = (lib.licenses.OR [ lib.licenses.mit lib.licenses.asl20 ]) // { redistributable = false; };
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
