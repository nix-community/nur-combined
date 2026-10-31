{
  vulkan-loader,
  libpulseaudio,
  libxkbcommon,
  makeWrapper,
  buildFHSEnv,
  stdenvNoCC,
  libxcursor,
  fontconfig,
  libxrandr,
  mangohud,
  freetype,
  alsa-lib,
  libglvnd,
  fetchurl,
  gamemode,
  libxext,
  python3,
  wayland,
  libxcb,
  libdrm,
  libx11,
  jdk25,
  unzip,
  libxi,
  mesa,
  udev,
  dbus,
  zlib,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "horizon-launcher";
  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Launcher for Horizon, a Rust rewrite of the Minecraft: Java Edition client";
    homepage = "https://playhorizon.dev/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = pname;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
        inherit pname version src meta;

        nativeBuildInputs = [
          makeWrapper
          unzip
        ];

        unpackPhase = ''
          runHook preUnpack
          unzip $src
          runHook postUnpack
        '';

        extraInstall = ''
          mkdir -p $out/bin
          ln -s "$out/Applications/Horizon.app/Contents/MacOS/horizon-launcher" "$out/bin/${pname}"
        '';

        postFixup = ''
          wrapProgram "$out/Applications/Horizon.app/Contents/MacOS/horizon-launcher" \
            --set JAVA_HOME "${jdk25.home}" \
            --prefix PATH : "${lib.makeBinPath [jdk25 jdk25.home python3]}" \
            --set HORIZON_LAUNCHER_NO_SELF_UPDATE 1
        '';
      }
      // {
        dontStrip = true;
      })
  else let
    unwrapped = stdenvNoCC.mkDerivation {
      pname = "${pname}-unwrapped";
      inherit version src;

      sourceRoot = ".";
      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        runHook preInstall
        install -Dm755 horizon-launcher $out/bin/${pname}
        runHook postInstall
      '';

      inherit meta;
    };
  in
    buildFHSEnv {
      inherit pname version;

      targetPkgs = _: [
        vulkan-loader
        libpulseaudio
        libxkbcommon
        libxcursor
        fontconfig
        unwrapped
        libxrandr
        libglvnd
        alsa-lib
        freetype
        gamemode
        mangohud
        python3
        libxext
        wayland
        libx11
        libdrm
        libxcb
        jdk25
        libxi
        mesa
        udev
        dbus
        zlib
      ];

      profile = ''
        export JAVA_HOME="${jdk25.home}"
        export HORIZON_LAUNCHER_NO_SELF_UPDATE=1
      '';

      runScript = "${unwrapped}/bin/${pname}";

      inherit meta;
    }
