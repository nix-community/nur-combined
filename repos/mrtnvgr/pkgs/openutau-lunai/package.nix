{
  alsa-lib,
  lib,
  stdenv,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  dbus,
  fontconfig,
  portaudio,
  libxi,
  copyDesktopItems,
  makeDesktopItem,
}:

buildDotnetModule rec {
  pname = "openutau-lunai";
  version = "0.2.1.0";

  src = fetchFromGitHub {
    owner = "keirokeer";
    repo = "OpenUtau-lunai";
    tag = version;
    hash = "sha256-D7mCyiVs3BpLfd9avUeyagXQEz/Sp7ST5peubzxCC68=";
  };

  nativeBuildInputs = [ copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "OpenUtau Lunai";
      startupWMClass = "OpenUtau-Lunai";
      icon = pname;
      genericName = "Utau";
      comment = "Open source singing synthesis platform and UTAU successor";
      exec = "OpenUtau-Lunai";
      categories = [
        "AudioVideo"
        "Audio"
        "Midi"
      ];
    })
  ];

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  # The "GenerateDepsFile" task fails when multiple projects are built in parallel.
  enableParallelBuilding = false;

  # Do not publish the whole solution: the OpenUtau.Test project has
  # DebugType disabled in Release via Directory.Build.targets, and publishing
  # it with --no-build fails with MSB3030 because the expected .pdb is missing.
  projectFile = "OpenUtau/OpenUtau.csproj";
  testProjectFile = "OpenUtau.Test/OpenUtau.Test.csproj";
  nugetDeps = ./deps.json;

  executables = [ "OpenUtau-Lunai" ];

  runtimeDeps = [
    dbus
    portaudio
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    fontconfig
    libxi
  ];

  dotnetInstallFlags = [ "-p:PublishReadyToRun=false" ];

  # socket cannot bind to localhost on darwin for tests
  doCheck = !stdenv.hostPlatform.isDarwin;

  # need to make sure proprietary worldline resampler is copied
  postInstall =
    let
      runtime =
        if (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64) then
          "linux-x64"
        else if (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) then
          "linux-arm64"
        else if stdenv.hostPlatform.isDarwin then
          "osx"
        else
          null;
      shouldInstallResampler = lib.optionalString (runtime != null) ''
        cp runtimes/${runtime}/native/libworldline${stdenv.hostPlatform.extensions.sharedLibrary} $out/lib/${pname}/
      '';
      shouldInstallDesktopItem = lib.optionalString stdenv.hostPlatform.isLinux ''
        install -Dm644 Logo/openutau.svg $out/share/icons/hicolor/scalable/apps/${pname}.svg
      '';
    in
    ''
      ${shouldInstallResampler}
      ${shouldInstallDesktopItem}
    '';

  meta = {
    description = "OpenUtau fork focused on making DiffSinger easier and more enjoyable to use";
    homepage = "https://github.com/keirokeer/OpenUtau-lunai";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # deps
      binaryBytecode
      # some deps and worldline resampler
      binaryNativeCode
    ];
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "OpenUtau-Lunai";
  };
}
