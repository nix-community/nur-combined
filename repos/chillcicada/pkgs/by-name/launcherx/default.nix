{
  lib,
  fetchzip,
  stdenv,
  autoPatchcilHook,
  fontconfig,
  libICE,
  libSM,
  libX11,
  libXcursor,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "launcherx";
  version = "2.603.2435.0";

  src = fetchzip {
    url = "https://api.corona.studio/Build/get/344c111b-d982-4941-95a3-9becc12effac/net9.0-linux.linux-x64.zip";
    hash = "sha256-2p4psuNlJM98rhm9QFNY8zEcxAiD81wi94QaHSdgw64=";
  };

  sourceRoot = ".";

  dontBuild = true;
  dontStrip = true;

  autoPatchcilRuntimeId = "linux-x64";

  nativeBuildInputs = [
    autoPatchcilHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    fontconfig.lib
    libICE
    libSM
    libX11
    libXcursor
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 source/LauncherX.Avalonia $out/bin/LauncherX.Avalonia

    runHook postInstall
  '';

  preFixup = ''
    patchelf \
      --add-needed libfontconfig.so.1 \
      --add-needed libXcursor.so.1 --add-needed libICE.so.6 \
      --add-needed libSM.so.6 --add-needed libX11.so.6 \
      --add-rpath "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      $out/bin/LauncherX.Avalonia
  '';

  meta = {
    description = "Next-generation Minecraft Launcher";
    license = lib.licenses.unfree;
    mainProgram = "LauncherX.Avalonia";
    platforms = lib.platforms.linux;
  };
})
