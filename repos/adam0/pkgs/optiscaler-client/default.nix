{
  # keep-sorted start
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  buildDotnetModule,
  cairo,
  dbus,
  dotnetCorePackages,
  fetchFromGitHub,
  findutils,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gnugrep,
  gtk3,
  icu,
  lib,
  libdrm,
  libglvnd,
  libice,
  libsm,
  libunwind,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  openssl,
  pango,
  pciutils,
  procps,
  stdenv,
  util-linux,
  zlib,
  # keep-sorted end
}: let
  pname = "optiscaler-client";
  version = "1.0.8";

  runtimeLibs = [
    # keep-sorted start
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
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
    libice
    libsm
    libunwind
    libx11
    libxcursor
    libxext
    libxi
    libxkbcommon
    libxrandr
    libxrender
    openssl
    pango
    stdenv.cc.cc.lib
    zlib
    # keep-sorted end
  ];
in
  buildDotnetModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "Agustinm28";
      repo = "Optiscaler-Client";
      rev = "1a4135de7fce2ea87b37404b533ba2949e40a173";
      hash = "sha256-6Kz5OE3/6h8tm6RxVLIVmpYwyoFD5GMHBlGLSMqF9os=";
    };

    dotnet-sdk = dotnetCorePackages.sdk_10_0;

    projectFile = "OptiscalerClient.csproj";
    executables = ["OptiscalerClient"];
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
        # keep-sorted start
        findutils
        gnugrep
        pciutils
        procps
        util-linux
        # keep-sorted end
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

    passthru.updateScript = null;

    meta = {
      # keep-sorted start
      description = "Modern manager for OptiScaler";
      homepage = "https://github.com/Agustinm28/Optiscaler-Client";
      license = lib.licenses.gpl3Plus;
      mainProgram = "optiscaler-client";
      platforms = ["aarch64-linux" "x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.fromSource lib.sourceTypes.binaryBytecode lib.sourceTypes.binaryNativeCode];
      # keep-sorted end
    };
  }
