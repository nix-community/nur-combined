# Fork from https://github.com/drakon64/nixos-xivlauncher-rb
{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  SDL2,
  libsecret,
  glib,
  gnutls,
  aria2,
  steam,
  gst_all_1,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  useSteamRun ? true,
  useGameMode ? false,
  useMangoHud ? false,
  nvngxPath ? "",
}:

let
  tag = "1.3.1.2";
in
buildDotnetModule rec {
  pname = "xivlauncher-rb";
  version = tag;

  src = fetchFromGitHub {
    owner = "rankynbass";
    repo = "XIVLauncher.Core";
    rev = "rb-v${tag}";
    hash = "sha256-f2Nia+XRCY8FtjjdZajkpKBKnFVtWYzNpr2ht74jsy8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];

  projectFile = "src/XIVLauncher.Core/XIVLauncher.Core.csproj";
  nugetDeps = ./deps.json; # File generated with `nix-build -A xivlauncher-rb.passthru.fetch-deps`

  # please do not unpin these even if they match the defaults, xivlauncher is sensitive to .NET versions
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  dotnetFlags = [
    "-p:BuildHash=${tag}"
    "-p:PublishSingleFile=false"
  ];

  postPatch = ''
    substituteInPlace lib/FFXIVQuickLauncher/src/XIVLauncher.Common/Game/Patch/Acquisition/Aria/AriaPatchAcquisition.cs \
      --replace-fail 'ariaPath = "aria2c"' 'ariaPath = "${aria2}/bin/aria2c"'
  '';

  postInstall = ''
    mkdir -p $out/share/pixmaps
    cp src/XIVLauncher.Core/Resources/logo.png $out/share/pixmaps/xivlauncher.png
  '';

  postFixup =
    lib.optionalString useSteamRun (
      let
        steam-run =
          (steam.override {
            extraPkgs =
              pkgs:
              [
                pkgs.libunwind
                pkgs.zstd
              ]
              ++ lib.optional useGameMode pkgs.gamemode
              ++ lib.optional useMangoHud pkgs.mangohud;
            extraProfile = ''
              unset TZ
            '';
          }).run;
      in
      ''
        substituteInPlace $out/bin/XIVLauncher.Core \
          --replace 'exec' 'exec ${steam-run}/bin/steam-run'
      ''
    )
    + ''
      wrapProgram $out/bin/XIVLauncher.Core --prefix GST_PLUGIN_SYSTEM_PATH_1_0 ":" "$GST_PLUGIN_SYSTEM_PATH_1_0" --prefix XL_NVNGXPATH ":" ${nvngxPath}
      # the reference to aria2 gets mangled as UTF-16LE and isn't detectable by nix: https://github.com/NixOS/nixpkgs/issues/220065
      mkdir -p $out/nix-support
      echo ${aria2} >> $out/nix-support/depends
    '';

  executables = [ "XIVLauncher.Core" ];

  runtimeDeps = [
    SDL2
    libsecret
    glib
    gnutls
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "xivlauncher-rb";
      exec = "XIVLauncher.Core";
      icon = "xivlauncher";
      desktopName = "XIVLauncher-RB";
      comment = meta.description;
      categories = [ "Game" ];
      startupWMClass = "XIVLauncher.Core";
    })
  ];

  meta = with lib; {
    description = "Custom launcher for FFXIV";
    homepage = "https://github.com/rankynbass/XIVLauncher.Core";
    license = if useSteamRun then licenses.unfree else licenses.gpl3;
    #maintainers = with maintainers; [ sersorrel witchof0x20 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "XIVLauncher.Core";
    broken = false;
  };
}
