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
  replaceVars,
  # _experimental-update-script-combinators,
  # gitUpdater,
}:
buildDotnetModule (finalAttrs: {
  pname = "stalker-gamma-cli";
  version = "1.30.0";

  src = fetchFromGitHub {
    owner = "FaithBeam";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    sha256 = "sha256-37negE/XHlX8KS4e731O1vTFGyhfBQXTgqqAUh2cc3Y=";
  };

  projectFile = "stalker-gamma-cli/stalker-gamma-cli.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  dotnetInstallFlags = [ "-p:AssemblyVersion=1.0.0" ];
  executables = [ "stalker-gamma" ];

  nativeBuildInputs = [ copyDesktopItems ];

  patches = [
    ./fix-build.patch
    (replaceVars ./fix-paths.patch {
      _7zz = lib.getExe _7zz-rar;
      curl = lib.getExe curl-impersonate;
      tar = lib.getExe gnutar;
      unzip = lib.getExe unzip;
      cacert = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    })
  ];

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

  # passthru.updateScript = _experimental-update-script-combinators.sequence [
  #   (gitUpdater { }).command
  #   (finalAttrs.passthru.fetch-deps)
  # ];

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
