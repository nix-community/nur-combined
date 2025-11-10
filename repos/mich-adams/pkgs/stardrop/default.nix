# Szanko/Stardrop/nix-packaging
{
  lib,
  imagemagick,
  fetchFromGitHub,
  buildFHSEnv,
  appimageTools,
  buildDotnetModule,
  dotnetCorePackages,
  dotnet-sdk_8,
  writeShellScript,
  makeDesktopItem,
  copyDesktopItems,
makeWrapper,
zip,
}:
  buildDotnetModule rec {
  pname = "StarDrop";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "SZanko";
    repo = "Stardrop";
    rev = "cbe07f90d852607d2ce19d3dd586ce3cb9464482";
    hash = "sha256-rKeIhyCRq2FZiN3CDoYYdiWpNuB4nHlVRSHjPpraIpE=";
  };


    projectFile = "Stardrop/Stardrop.sln";
    executables = [ "Stardrop" ];

    dotnet-sdk = dotnet-sdk_8;
    dotnet-runtime = dotnetCorePackages.runtime_8_0;
    nugetDeps = ./deps.json;
	packNupkg = true;

    nativeBuildInputs = [
                       copyDesktopItems
                        makeWrapper
                        zip
                        imagemagick
    ];
            dotnetFlags = [ "-p:SelfContained=false" "-p:RuntimeIdentifier=" ];
    postInstall = ''
                      install -Dm644 "Stardrop/Assets/stardrop.svg" \
                        "$out/share/icons/hicolor/scaleable/apps/stardrop.svg"
	'';

	desktopItems = [
      (makeDesktopItem {
        name = "stardrop";
        desktopName = "Stardrop";
	genericName = "Stardew Valley Mod Manager";
        comment = "Manage Stardew Valley mods";
        exec = "stardrop --nxm %u";
        icon = "stardrop";
        categories = [ "Game" "Utility" ];
        startupWMClass = "stardrop";
        mimeTypes = [ "x-scheme-handler/nxm" ];
      })
    ];

  meta = {
    description = "Open-source, cross-platform mod manager for the game Stardew Valley";
    homepage = "https://github.com/Floogen/Stardrop";
    license = lib.licenses.gpl3Only;
    platforms = ["x86_64-linux"];
  };
}

