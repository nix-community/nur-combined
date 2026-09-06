{
  autoPatchelfHook,
  lib,
  libGL,
  libx11,
  makeWrapper,
  requireFile,
  stdenv,
  vulkan-loader,
  wayland,
  xkeyboard_config,
}:

stdenv.mkDerivation {
  __structuredAttrs = true;

  pname = "delta";
  version = "0.6.1";

  src = requireFile {
    name = "delta-linux-x86_64.tar.gz";
    hash = "sha256-Q/CSFKlIDd47DwQk/QatfBs8AtM/ObTA3TFOTvggcsE=";
    message = ''
      Copy delta-linux-x86_64.tar.gz to the current directory, then add it
      to the Nix store with:

        nix-prefetch-url file://$PWD/delta-linux-x86_64.tar.gz
    '';
  };

  sourceRoot = "Delta";

  strictDeps = true;
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  runtimeDependencies = map lib.getLib [
    libGL
    vulkan-loader
    wayland
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a bin lib share $out/

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/delta \
      --set-default XKB_CONFIG_ROOT ${xkeyboard_config}/share/X11/xkb \
      --set-default XLOCALEDIR ${libx11}/share/X11/locale
  '';

  meta = {
    description = "AI-native code editor";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "delta";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
