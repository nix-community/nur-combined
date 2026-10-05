{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  _7zz-rar,
  cacert,
  curl-impersonate,
  gnutar,
  unzip,
  makeDesktopItem,
  copyDesktopItems,
  nix-update-script,
}:
buildDotnetModule (finalAttrs: {
  pname = "stalker-gamma-cli";
  version = "1.34.0";

  src = fetchFromGitHub {
    owner = "FaithBeam";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    sha256 = "sha256-yRa1RCqCNgQwWQZXstDaVUV3jpNgFaUNW4mcHiG9JjE=";
  };

  projectFile = "stalker-gamma-cli/stalker-gamma-cli.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  dotnetInstallFlags = [ "-p:AssemblyVersion=1.0.0" ];
  executables = [ "stalker-gamma" ];

  runtimeDeps = [ curl-impersonate ];

  nativeBuildInputs = [ copyDesktopItems ];

  patches = [
    ./fix-build.patch
  ];

  postPatch = ''
    substituteInPlace LibCurlImpersonate/CurlHttp.cs \
      --replace-fail 'private static readonly string PathToCacert = Path.Join(CurDir, "cacert.pem");' \
      'private static readonly string PathToCacert = "${cacert}/etc/ssl/certs/ca-bundle.crt";'
    substituteInPlace Stalker.Gamma/Models/StalkerGammaSettings.cs \
      --replace-fail 'public string PathToUnzip = "unzip";' \
        'public string PathToUnzip = "${lib.getExe unzip}";' \
      --replace-fail 'public string PathTo7Z = OperatingSystem.IsWindows() ? "7zz.exe" : "7zz";' \
        'public string PathTo7Z = "${lib.getExe _7zz-rar}";' \
      --replace-fail 'public string PathToTar = "tar";' \
        'public string PathToTar = "${lib.getExe gnutar}";'
    substituteInPlace stalker-gamma-cli/Commands/Anomaly.cs \
      --replace-fail 'var resourcesPath = Path.Join(Path.GetDirectoryName(AppContext.BaseDirectory), "resources");
        stalkerGammaSettings.PathTo7Z = Path.Join(
            resourcesPath,
            OperatingSystem.IsWindows() ? "7zz.exe" : "7zz"
        );' \
      'stalkerGammaSettings.PathToTar = "${lib.getExe gnutar}";'
    substituteInPlace stalker-gamma-cli/Services/SetupUtilitiesService.cs \
      --replace-fail 'settings.PathTo7Z = Path.Join(
            ResourcesPath,
            OperatingSystem.IsWindows() ? "7zz.exe" : "7zz"
        );' \
      'settings.PathTo7Z = "${lib.getExe _7zz-rar}";'
  '';

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp $src/build/linux/stalker-gamma.AppDir/stalker-gamma.png $out/share/icons/hicolor/256x256/apps/stalker-gamma.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "stalker-gamma";
      desktopName = "Stalker GAMMA";
      genericName = "Stalker GAMMA";
      exec = "stalker-gamma";
      icon = "stalker-gamma";
      categories = [ "Utility" ];
      type = "Application";
      terminal = true;
    })
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "stalker-gamma-cli"
    ];
  };

  meta = {
    description = "A CLI to install Stalker GAMMA";
    homepage = "https://github.com/FaithBeam/stalker-gamma-cli";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "stalker-gamma";
  };
})
