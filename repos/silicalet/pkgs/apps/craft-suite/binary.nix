{
  appName,
  description,
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  dbus,
  fontconfig,
  freetype,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  vulkan-loader,
  wayland,
  xdg-utils,
}:
let
  system = stdenv.hostPlatform.system;
  sourceFile = ./sources + "/${system}.json";
  source =
    if builtins.pathExists sourceFile then
      (builtins.fromJSON (builtins.readFile sourceFile)).${appName}
    else
      throw "${appName}-bin is unsupported on ${system}";
  repo = if appName == "artcraft-launcher" then "craft-launcher" else appName;
  # winit/wgpu load these with dlopen, so autoPatchelf alone cannot find them.
  runtimeLibraries = [
    alsa-lib
    dbus
    fontconfig
    freetype
    libGL
    libx11
    libxcb
    libxcursor
    libxi
    libxkbcommon
    libxrandr
    vulkan-loader
    wayland
  ];
in
stdenv.mkDerivation {
  pname = "${appName}-bin";
  inherit (source) version;
  src = fetchurl { inherit (source) url hash; };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ stdenv.cc.cc.lib ] ++ runtimeLibraries;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r bin share "$out/"
    runHook postInstall
  '';

  postFixup = ''
    for program in "$out"/bin/*; do
      wrapProgram "$program" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}" \
        --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}"
    done
  '';

  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck
    for program in "$out"/bin/*-cli; do
      if [ -x "$program" ]; then
        "$program" --help > /dev/null
      fi
    done
    runHook postInstallCheck
  '';

  meta = {
    inherit description;
    homepage = "https://github.com/storytold/${repo}";
    changelog = "https://github.com/storytold/${repo}/releases/tag/v${source.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = appName;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
