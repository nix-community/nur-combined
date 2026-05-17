{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  dbus,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  icu,
  libdrm,
  libglvnd,
  libunwind,
  libxkbcommon,
  openssl,
  pango,
  zlib,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  libxrender,
  pciutils,
  procps,
  util-linux,
  findutils,
  gnugrep,
}:

let
  pname = "optiscaler-client";
  version = "1.0.5";

  runtimeLibs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    dbus
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    icu
    libdrm
    libglvnd
    libunwind
    libxkbcommon
    openssl
    pango
    stdenv.cc.cc.lib
    libice
    libsm
    libx11
    libxcursor
    libxext
    libxi
    libxrandr
    libxrender
    zlib
  ];
in
buildDotnetModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "Agustinm28";
    repo = "Optiscaler-Client";
    tag = "OptiscalerClient-${version}";
    hash = "sha256-1Cs6DHR7f5MtklmKY96+uOi4esFP2VkAWsR/j9bwdqs=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  projectFile = "OptiscalerClient.csproj";
  executables = [ "OptiscalerClient" ];
  nugetDeps = ./deps.json;

  selfContainedBuild = true;
  useAppHost = true;

  runtimeDeps = runtimeLibs;

  dotnetFlags = [
    "-p:PublishSingleFile=true"
    "-p:SelfContained=true"
    "-p:PublishTrimmed=false"
    "-p:EnableCompressionInSingleFile=true"
    "-p:PublishReadyToRun=true"
    "-p:DebugType=none"
    "-p:DebugSymbols=false"
  ];

  makeWrapperArgs = [
    "--prefix"
    "LD_LIBRARY_PATH"
    ":"
    (lib.makeLibraryPath runtimeLibs)
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      pciutils
      procps
      util-linux
      findutils
      gnugrep
    ])
  ];

  postInstall = ''
    install -Dm644 assets/icon.png $out/share/icons/hicolor/256x256/apps/optiscaler-client.png
    install -d $out/share/applications

    cat > $out/share/applications/optiscaler-client.desktop <<EOF
[Desktop Entry]
Type=Application
Name=OptiScaler Client
Comment=Modern manager for OptiScaler
Exec=optiscaler-client
Icon=optiscaler-client
Terminal=false
Categories=Game;Utility;
EOF
  '';

  postFixup = ''
    mv $out/bin/OptiscalerClient $out/bin/optiscaler-client
  '';

  meta = with lib; {
    description = "Modern manager for OptiScaler";
    homepage = "https://github.com/Agustinm28/Optiscaler-Client";
    license = licenses.gpl3Plus;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "optiscaler-client";
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode
      binaryNativeCode
    ];
  };
}
