{
  lib,
  stdenv,
  fetchurl,
  config,
  wrapFirefox,
  autoPatchelfHook,
  patchelfUnstable,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  wrapGAppsHook3,
  adwaita-icon-theme,
  alsa-lib,
  curl,
  dbus-glib,
  gtk3,
  libxtst,
  libva,
  pciutils,
  pipewire,
}:

let
  version = "151.0";
  tag = "firefox-53";

  hashes = {
    aarch64-linux = "sha256-va47ri/0NFxJUINsaBrUTQSdO2PkMjQKWPa6aUxAX8c=";
    x86_64-linux = "sha256-4G9HUySEaYMQaX+2jfGDDCUm7FaoOHEwxP0giVZfDI4=";
  };

  arch = {
    aarch64-linux = "linux-arm64";
    x86_64-linux = "linux-x86_64";
  };

  binaryName = "firefox";
  applicationName = "Firefox";
  libName = "invisible-firefox-bin-${version}";

  policies = {
    DisableAppUpdate = true;
  }
  // (config.firefox.policies or { });

  unwrapped = stdenv.mkDerivation (finalAttrs: {
    pname = "invisible-firefox-bin-unwrapped";
    inherit version;

    src = fetchurl {
      url = "https://github.com/feder-cr/firefox_antidetect_patch/releases/download/${tag}/firefox-${version}-stealth-${
        arch.${stdenv.hostPlatform.system}
      }.tar.gz";
      hash = hashes.${stdenv.hostPlatform.system};
    };

    __structuredAttrs = true;
    strictDeps = true;

    sourceRoot = ".";

    noDumpEnvVars = true;

    nativeBuildInputs = [
      autoPatchelfHook
      patchelfUnstable
      versionCheckHook
      writableTmpDirAsHomeHook
      wrapGAppsHook3
    ];

    buildInputs = [
      gtk3
      adwaita-icon-theme
      alsa-lib
      dbus-glib
      libxtst
    ];

    runtimeDependencies = [
      curl
      pciutils
      (lib.getLib libva)
    ];

    appendRunpaths = [ "${pipewire}/lib" ];

    patchelfFlags = [ "--no-clobber-old-sections" ];

    dontConfigure = true;
    dontBuild = true;

    doInstallCheck = true;
    versionCheckKeepEnvironment = "HOME";

    passthru = {
      inherit applicationName binaryName libName;
      inherit gtk3;
    };

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/lib/${libName}"
      cp -r * "$out/lib/${libName}"

      mkdir -p "$out/bin"
      ln -s "$out/lib/${libName}/firefox" "$out/bin/${binaryName}"

      runHook postInstall
    '';

    meta = {
      changelog = "https://github.com/feder-cr/firefox_antidetect_patch/releases";
      description = "Anti-fingerprinting Firefox, packaged from upstream prebuilt Linux binaries";
      homepage = "https://github.com/feder-cr/firefox_antidetect_patch";
      license = lib.licenses.mkLicense {
        shortName = "firefox";
        fullName = "Firefox Terms of Use";
        url = "https://www.mozilla.org/about/legal/terms/firefox/";
        free = false;
        redistributable = true;
      };
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      platforms = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      hydraPlatforms = [ ];
      maintainers = with lib.maintainers; [ xddxdd ];
      mainProgram = binaryName;
    };
  });
in
(wrapFirefox unwrapped {
  pname = "invisible-firefox-bin";
  extraPolicies = policies;
}).overrideAttrs
  (old: {
    passthru = old.passthru // {
      updateScript = [ (toString ./update.sh) ];
    };
  })
