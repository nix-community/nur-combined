{
  lib,
  stdenv,
  config,
  wrapGAppsHook3,
  autoPatchelfHook,
  alsa-lib,
  curl,
  dbus-glib,
  gtk3,
  libxtst,
  libva,
  pciutils,
  pipewire,
  adwaita-icon-theme,
  writeText,
  patchelfUnstable,
  undmg,
  sources,
}:

let
  mozillaPlatforms = {
    x86_64-linux = "linux-x86_64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "macos-x86_64";
    aarch64-darwin = "macos-arm64";
  };

  arch =
    mozillaPlatforms.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  source = sources."invisible-firefox-bin-${arch}";
  inherit (source) version src;

  binaryName = "firefox";
  applicationName = "Firefox";

  policies = {
    DisableAppUpdate = true;
  }
  // config.firefox.policies or { };

  policiesJson = writeText "firefox-policies.json" (builtins.toJSON { inherit policies; });

  pname = "invisible-firefox-bin-unwrapped";
in
stdenv.mkDerivation {
  inherit pname version src;

  sourceRoot = ".";

  nativeBuildInputs = [
    wrapGAppsHook3
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    autoPatchelfHook
    patchelfUnstable
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    undmg
  ];

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    gtk3
    adwaita-icon-theme
    alsa-lib
    dbus-glib
    libxtst
  ];

  runtimeDependencies = [
    curl
    pciutils
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libva.out
  ];

  appendRunpaths = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    "${pipewire}/lib"
  ];

  patchelfFlags = [ "--no-clobber-old-sections" ];

  dontFixup = stdenv.hostPlatform.isDarwin;

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        runHook preInstall
        mkdir -p $out/Applications
        mv Firefox*.app "$out/Applications/${applicationName}.app"
        runHook postInstall
      ''
    else
      ''
        runHook preInstall
        mkdir -p "$prefix/lib/firefox-bin-${version}"
        cp -r * "$prefix/lib/firefox-bin-${version}"

        mkdir -p "$out/bin"
        ln -s "$prefix/lib/firefox-bin-${version}/firefox" "$out/bin/${binaryName}"

        mkdir -p "$out/lib/firefox-bin-${version}/distribution"
        ln -s ${policiesJson} "$out/lib/firefox-bin-${version}/distribution/policies.json"
        runHook postInstall
      '';

  passthru = {
    inherit applicationName binaryName;
    libName = "firefox-bin-${version}";
    ffmpegSupport = true;
    gssSupport = true;
    inherit gtk3;
  };

  meta = {
    changelog = "https://github.com/feder-cr/invisible_playwright/releases";
    description = "Firefox with anti fingerprinting modifications (binary package)";
    homepage = "https://github.com/feder-cr/invisible_playwright";
    license = {
      shortName = "firefox";
      fullName = "Firefox Terms of Use";
      url = "https://www.mozilla.org/about/legal/terms/firefox/";
      free = false;
      redistributable = true;
    };
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames mozillaPlatforms;
    hydraPlatforms = [ ];
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = binaryName;
  };
}
