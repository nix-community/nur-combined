{ lib, stdenv, buildDotnetModule, dotnetCorePackages, fetchFromGitHub, makeDesktopItem, copyDesktopItems,
  libGL, vulkan-loader, libx11, libxcursor, libxext, libxi, libxrandr, libice, libsm, libGLU, openal, glfw }:
buildDotnetModule rec {
  pname = "meitou-client";
  version = "0.17.1";
  src = fetchFromGitHub {
    owner = "VlcekM";
    repo = "MeitouClient";
    rev = "v${version}";
    hash = "sha256-oXaIWs9gSHqTe+xkTUYJQMO3COv224O1YRlhuvKB7Ug=";
  };
  projectFile = "src/Meitou.Game/Meitou.Game.csproj";
  nugetDeps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  executables = [ "MeitouClient" ];
  dotnetBuildFlags = [ "-p:BuildGitTag=v${version}" ];
  dotnetInstallFlags = [ "-p:BuildGitTag=v${version}" ];
  runtimeDeps = [ libGL libGLU vulkan-loader libx11 libxcursor libxext libxi libxrandr libice libsm openal glfw stdenv.cc.cc.lib ];
  nativeBuildInputs = [ copyDesktopItems ];
  desktopItems = [ (makeDesktopItem {
    name = "meitou-client";
    desktopName = "Meitou Client";
    comment = "Open-source Kenshi engine; requires your own game installation";
    exec = "MeitouClient";
    icon = "meitou-client";
    categories = [ "Game" ];
    terminal = true;
  }) ];
  postInstall = ''
    install -Dm644 assets/branding/meitou-icon-2048.png $out/share/icons/hicolor/2048x2048/apps/meitou-client.png
    install -Dm644 LICENSE $out/share/licenses/meitou-client/LICENSE
    install -Dm644 LICENSE-EXCEPTION.md $out/share/licenses/meitou-client/LICENSE-EXCEPTION.md
    install -Dm644 THIRD_PARTY_NOTICES.md $out/share/licenses/meitou-client/THIRD_PARTY_NOTICES.md
  '';
  meta = {
    description = "Open-source Kenshi engine reimplementation; requires a game installation";
    homepage = "https://github.com/VlcekM/MeitouClient";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "MeitouClient";
  };
}
