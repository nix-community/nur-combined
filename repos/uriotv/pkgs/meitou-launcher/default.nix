{ lib, fetchurl, appimageTools, buildFHSEnv }:
let
  pname = "meitou-launcher";
  version = "1.13.0";
  # Upstream's prebuilt launcher: a NativeAOT executable, so no .NET SDK, NuGet
  # lock or source build is involved. The AppImage is only unpacked; it is never
  # run as a mounted AppImage, so the bundled Velopack updater does not consider
  # the launcher installed and leaves updates to Nix.
  src = fetchurl {
    url = "https://github.com/VlcekM/MeitouClient/releases/download/launcher-v${version}/MeitouLauncher-linux-x64.AppImage";
    hash = "sha256-1d183AHuct8y6JXZ313MuBSZMKzbXNVt12iKidHmC0U=";
  };
  contents = appimageTools.extractType2 { inherit pname version src; };
in
buildFHSEnv {
  inherit pname version;
  # The launcher and the game releases it downloads are upstream's Linux
  # binaries; they need an FHS loader and libraries on NixOS.
  targetPkgs = pkgs: with pkgs; [
    alsa-lib dbus fontconfig freetype glib gtk3 icu libGL libice libsm libx11
    libxcursor libxext libxfixes libxi libxkbcommon libxrandr libxrender libvpx
    openal openssl stdenv.cc.cc.lib vulkan-loader wayland zlib
  ];
  # Meitou can score llvmpipe above an integrated GPU because it counts the
  # software driver's large RAM heap as VRAM. Exclude Mesa's CPU ICD by default,
  # but preserve explicit Vulkan/Mesa driver selections and allow software-only
  # use via VK_LOADER_DRIVERS_DISABLE="".
  profile = ''
    if [[ ! ''${VK_LOADER_DRIVERS_DISABLE+x} && ! ''${VK_LOADER_DRIVERS_SELECT+x} && \
          ! ''${VK_DRIVER_FILES+x} && ! ''${VK_ICD_FILENAMES+x} && ! ''${MESA_VK_DEVICE_SELECT+x} ]]; then
      export VK_LOADER_DRIVERS_DISABLE='*lvp*'
    fi
    # Velopack treats the launcher as an installed AppImage only through $APPIMAGE.
    unset APPIMAGE APPDIR
  '';
  runScript = "${contents}/usr/bin/meitou-launcher";
  extraInstallCommands = ''
    install -Dm644 ${contents}/MeitouLauncher.desktop $out/share/applications/meitou-launcher.desktop
    substituteInPlace $out/share/applications/meitou-launcher.desktop \
      --replace-fail 'Icon=MeitouLauncher' 'Icon=meitou-launcher' \
      --replace-fail 'Categories=Utility;' 'Categories=Game;'
    install -Dm644 ${contents}/MeitouLauncher.png $out/share/icons/hicolor/64x64/apps/meitou-launcher.png
  '';
  passthru = { inherit src contents; };
  meta = {
    description = "Meitou game launcher (upstream binary); downloads game versions and requires Kenshi";
    homepage = "https://github.com/VlcekM/MeitouClient";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "meitou-launcher";
  };
}
