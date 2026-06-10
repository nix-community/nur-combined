{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  copyDesktopItems,
  makeDesktopItem,
  libx11,
  fontconfig,
  libGL,
}:

buildDotnetModule rec {
  pname = "banguminet";
  version = "1.0.16";

  src = fetchFromGitHub {
    owner = "ajtn123";
    repo = "BangumiNet";
    rev = "v${version}";
    hash = "sha256-dE9ZKPdukYPLNj1H+zEAOOhXBb9EuKG4HtXIvyO/qT8=";
  };

  projectFile = "BangumiNet/BangumiNet.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  executables = [ "BangumiNet" ];

  runtimeDeps = [
    libx11
    fontconfig.lib
    libGL
  ];

  nativeBuildInputs = [
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "banguminet";
      desktopName = "BangumiNet";
      exec = "banguminet";
      icon = "banguminet";
      comment = "Third-party Bangumi desktop client";
      terminal = false;
      type = "Application";
      categories = [ "Network" ];
    })
  ];

  postInstall = ''
    mkdir -p "$out/bin"
    ln -s "$out/bin/BangumiNet" "$out/bin/banguminet"

    install -Dm644 "$src/BangumiNet/Assets/BangumiNet.ico" \
      "$out/share/pixmaps/banguminet.ico"
  '';

  meta = with lib; {
    description = "Third-party Bangumi desktop client built with .NET and Avalonia";
    homepage = "https://github.com/ajtn123/BangumiNet";
    license = licenses.mit;
    mainProgram = "banguminet";
    platforms = dotnetCorePackages.sdk_10_0.meta.platforms or platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
