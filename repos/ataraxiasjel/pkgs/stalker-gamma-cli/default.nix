{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  _7zz-rar,
  cacert,
  curl-impersonate,
  unzip,
  makeDesktopItem,
  copyDesktopItems,
  # _experimental-update-script-combinators,
  # gitUpdater,
}:
buildDotnetModule (finalAttrs: {
  pname = "stalker-gamma-cli";
  version = "1.29.0";

  src = fetchFromGitHub {
    owner = "FaithBeam";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    sha256 = "sha256-UwEXxf7NZPhoIwiOWxtFv4VD8+eAzQyeH5jnh54QdjE=";
  };

  projectFile = "stalker-gamma-cli/stalker-gamma-cli.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  dotnetInstallFlags = [ "-p:AssemblyVersion=${finalAttrs.version}" ];
  executables = [ "stalker-gamma" ];

  nativeBuildInputs = [ copyDesktopItems ];

  postPatch = ''
    substituteInPlace "Directory.Build.props" --replace-fail "<PublishAot>true</PublishAot>" ""
    substituteInPlace "Stalker.Gamma/Utilities/CurlUtility.cs" --replace-fail \
        "Path.Join(AppContext.BaseDirectory, \"resources\", \"cacert.pem\")" \
        "\"${cacert}/etc/ssl/certs/ca-bundle.crt\""
  '';

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp $src/build/linux/stalker-gamma.AppDir/stalker-gamma.png $out/share/icons/hicolor/256x256/apps/stalker-gamma.png
  '';

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        _7zz-rar
        curl-impersonate
        unzip
      ]
    }"
    "--inherit-argv0"
  ];

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

  meta = with lib; {
    description = "A CLI to install Stalker GAMMA";
    homepage = "https://github.com/FaithBeam/stalker-gamma-cli";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "stalker-gamma";
  };
})
