# Szanko/Stardrop/nix-packaging
{
  lib,
  imagemagick,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  zip,
  avalonia,
  libx11,
  dbus,
  gtk3,
  wrapGAppsHook3,
  colors ? {
    background = "282828"; # DarkSeaBlue
    borders = "d65d0e"; # NeonOrange
    foreground = "8ec07c"; # NeonMint
    error = "cc241d"; # NeonRed
    modListBackground = "928374"; # PerfectGray
    modListHeader = "3c3836"; # DarkestGray
    modListForeground = "fbf1c7"; # White
    modListForegroundAlt = "504945"; # OffGray
    selected = "689d6a"; # GrayBlue
    update = "d79921"; # NeonYellow
  },
}:
buildDotnetModule rec {
  pname = "Stardrop";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "Floogen";
    repo = "Stardrop";
    rev = "v${version}";
    hash = "sha256-CumU2wLYmT/L3hdV5I/o1j3O+sKIODW7DU+DDOefHd0=";
  };

  projectFile = "Stardrop/Stardrop.csproj";
  executables = [ "Stardrop" ];

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  nugetDeps = ./deps.json;
  #packNupkg = true;
  #dotnetFlags = [ "-p:SelfContained=false" "-p:RuntimeIdentifier=" ];
  #selfContainedBuild = true;

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    zip
    imagemagick
    wrapGAppsHook3
  ];

  buildInputs = [ avalonia ];

  runtimeDeps = [
    dbus
    gtk3
    libx11
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "stardrop";
      desktopName = "Stardrop";
      genericName = "Stardew Valley Mod Manager";
      comment = "Manage Stardew Valley mods";
      exec = "Stardrop %U";
      icon = "stardrop";
      categories = [
        "Game"
        "Utility"
      ];
      terminal = false;
      startupNotify = true;
      mimeTypes = [ "x-scheme-handler/nxm" ];
    })
  ];

  postInstall = with colors; ''
    substituteInPlace $out/lib/Stardrop/Themes/Stardrop.xaml \
        --replace-fail 'ff9f2a' '${borders}' \
        --replace-fail '031332' '${background}' \
        --replace-fail '1cff96' '${foreground}' \
        --replace-fail 'f74040' '${error}' \
        --replace-fail '3abcbc' '${selected}' \
        --replace-fail '6B6B6B' '${modListBackground}' \
        --replace-fail '525252' '${modListForegroundAlt}' \
        --replace-fail '2a2824' '${modListHeader}' \
        --replace-fail 'ffffff' '${modListForeground}'
    install -Dm644 ${./stardrop.svg} \
        "$out/share/icons/hicolor/scaleable/apps/stardrop.svg"
  '';

  meta = {
    mainProgram = "Stardrop";
    description = "Open-source, cross-platform mod manager for the game Stardew Valley";
    homepage = "https://github.com/SZanko/Stardrop";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = [ ];
  };
}
