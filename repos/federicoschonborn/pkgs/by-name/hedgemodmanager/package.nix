{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  writeScript,
}:

let
  version = "8.0.0-beta4";
in

buildDotnetModule {
  pname = "hedgemodmanager";
  inherit version;

  src = fetchFromGitHub {
    owner = "hedge-dev";
    repo = "HedgeModManager";
    rev = version;
    hash = "sha256-1uwcpeyOxwKI0fyAmchYEMqStF52wXkCZej+ZQ+aFeY=";
  };

  projectFile = "Source/HedgeModManager.UI/HedgeModManager.UI.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  postPatch = ''
    substituteInPlace flatpak/hedgemodmanager.desktop --replace-fail "/app/bin/HedgeModManager.UI" "$out/bin/HedgeModManager.UI"
  '';

  postInstall = ''
    install -Dm644 flatpak/hedgemodmanager.png $out/share/icons/hicolor/256x256/apps/io.github.hedge_dev.hedgemodmanager.png
    install -Dm644 flatpak/hedgemodmanager.metainfo.xml $out/share/metainfo/io.github.hedge_dev.hedgemodmanager.metainfo.xml
    install -Dm644 flatpak/hedgemodmanager.desktop $out/share/applications/io.github.hedge_dev.hedgemodmanager.desktop
  '';

  passthru.updateScript = writeScript "update.sh" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p nix-update
    set -euo pipefail

    nix-update --version unstable hedgemodmanager
    eval "$(nix-build . -A hedgemodmanager.fetch-deps --no-out-link)"
  '';

  meta = {
    mainProgram = "HedgeModManager.UI";
    description = "Multiplatform rewrite of Hedge Mod Manager";
    homepage = "https://github.com/hedge-dev/HedgeModManager";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.windows;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
