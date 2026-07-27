{
  sources,

  lib,
  stdenv,
  config,
  formats,

  adwaita-icon-theme,
  alsa-lib,
  autoPatchelfHook,
  curl,
  gtk3,
  libva,
  patchelfUnstable,
  pciutils,
  pipewire,
  vulkan-loader,
  wrapGAppsHook3,

  policies ? { },
}:
let
  source =
    if stdenv.isAarch64 then
      sources.glide-bin-unwrapped-aarch64-linux
    else
      sources.glide-bin-unwrapped-x86_64-linux;

  inherit (source) version;

  libName = "glide-bin-${version}";
in
stdenv.mkDerivation {
  pname = "glide-bin-unwrapped";
  inherit version;
  inherit (source) src;

  nativeBuildInputs = [
    autoPatchelfHook
    patchelfUnstable
    wrapGAppsHook3
  ];

  patchelfFlags = [ "--no-clobber-old-sections" ];

  buildInputs = [
    alsa-lib
    stdenv.cc.cc.lib
    gtk3
    adwaita-icon-theme
  ];

  runtimeDependencies = [
    curl
    libva
    pciutils
    pipewire
    vulkan-loader
  ];

  buildPhase =
    let
      policies' = (formats.json { }).generate "glide-policies" {
        policies = (config.glide-browser.policies or { }) // policies;
      };
    in
    ''
      runHook preBuild

      mkdir -p $out/{lib/${libName},bin}
      cp -r * $out/lib/${libName}
      ln -s $out/lib/${libName}/glide $out/bin/glide

      mkdir -p $out/lib/${libName}/distribution
      ln -s ${policies'} $out/lib/${libName}/distribution/policies.json

      runHook postBuild
    '';

  passthru = {
    applicationName = "Glide";
    binaryName = "glide";
    inherit libName;
    inherit gtk3;
    ffmpegSupport = true;
    gssSupport = true;
    pipewireSupport = true;
  };

  meta = {
    description = "Extensible and keyboard-focused web browser";
    homepage = "https://glide-browser.app";
    license = lib.licenses.mpl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "glide";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
