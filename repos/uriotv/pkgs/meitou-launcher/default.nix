{ lib, buildDotnetModule, dotnetCorePackages, fetchFromGitHub, buildFHSEnv, makeDesktopItem,
  copyDesktopItems, stdenv, libGL, libx11, libxcursor, libxext, libxi, libxrandr, libice, libsm, fontconfig, freetype, openal, libvpx, zlib }:
let
  version = "1.9.0";
  src = fetchFromGitHub {
    owner = "VlcekM";
    repo = "MeitouClient";
    rev = "launcher-v${version}";
    hash = "sha256-m9ZnkbECw1gB4bvLHP4VbZWgcKMrUOSm3uurcFmvYGw=";
  };
  launcher = buildDotnetModule {
    pname = "meitou-launcher-unwrapped";
    inherit version src;
    projectFile = "launcher/Meitou.Launcher/Meitou.Launcher.csproj";
    nugetDeps = ./deps.json;
    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    dotnet-runtime = dotnetCorePackages.runtime_10_0;
    executables = [ "meitou-launcher" ];
    # Publish as framework-dependent .NET instead of upstream's single-file AOT.
    # Keep Avalonia/Skia native libraries alongside the managed executable.
    postPatch = ''
      substituteInPlace launcher/Meitou.Launcher/Meitou.Launcher.csproj \
        --replace-fail '<PublishAot>true</PublishAot>' '<PublishAot>false</PublishAot>' \
        --replace-fail 'AfterTargets="ResolvePackageAssets" Condition=' 'Condition=' \
        --replace-fail 'AfterTargets="ComputeResolvedFilesToPublishList" Condition=' 'Condition='
    '';
    runtimeDeps = [ libGL libx11 libxcursor libxext libxi libxrandr libice libsm fontconfig freetype openal libvpx zlib stdenv.cc.cc.lib ];
    meta.platforms = [ "x86_64-linux" ];
  };
  desktop = makeDesktopItem {
    name = "meitou-launcher";
    desktopName = "Meitou Launcher";
    comment = "Manage and launch Meitou; requires your own Kenshi installation";
    exec = "meitou-launcher";
    icon = "meitou-launcher";
    categories = [ "Game" ];
  };
in
buildFHSEnv {
  pname = "meitou-launcher";
  inherit version;
  # Game releases downloaded by the launcher are upstream's self-contained Linux
  # binaries, which need an FHS loader and libraries on NixOS. No AppImage is used.
  targetPkgs = pkgs: with pkgs; [
    alsa-lib dbus fontconfig freetype glib gtk3 icu libGL libx11 libxcursor libxext
    libxfixes libxi libxkbcommon libxrandr libxrender libvpx openal openssl
    stdenv.cc.cc.lib vulkan-loader wayland zlib
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
  '';
  runScript = "${launcher}/bin/meitou-launcher";
  nativeBuildInputs = [ copyDesktopItems ];
  desktopItems = [ desktop ];
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${desktop}/share/applications/*.desktop $out/share/applications/
    install -Dm644 ${src}/assets/branding/meitou-icon-2048.png $out/share/icons/hicolor/2048x2048/apps/meitou-launcher.png
    install -Dm644 ${src}/LICENSE $out/share/licenses/meitou-launcher/LICENSE
    install -Dm644 ${src}/LICENSE-EXCEPTION.md $out/share/licenses/meitou-launcher/LICENSE-EXCEPTION.md
    install -Dm644 ${src}/THIRD_PARTY_NOTICES.md $out/share/licenses/meitou-launcher/THIRD_PARTY_NOTICES.md
  '';
  passthru = { inherit src; inherit (launcher) fetch-deps; };
  meta = {
    description = "Meitou game launcher; downloads game versions and requires Kenshi";
    homepage = "https://github.com/VlcekM/MeitouClient";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "meitou-launcher";
  };
}
