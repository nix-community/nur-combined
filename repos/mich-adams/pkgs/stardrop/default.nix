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

}:
buildDotnetModule rec {
  pname = "StarDrop";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "Floogen";
    repo = "Stardrop";
    rev = "v${version}";
    hash = "sha256-bwyY0UYveDve6mK59Wn6bpTU8pbEbJWmjIFSDO6EB34=";
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

  postInstall = ''
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
