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
  # Arguments that the NixOS firefox module injects through `cfg.package
  # .override`. Forward them to the wrapper: `lib.makeOverridable` attaches
  # `override` at THIS level (shadowing the wrapper's own), so an override
  # here lands back on these outer-argument defaults and must be passed
  # through.
  cfg ? null,
  extraPrefsFiles ? [ ],
  nativeMessagingHosts ? [ ],
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
(wrapFirefox unwrapped (
  # Only pass cfg when the module injects it, so a direct `pkgs.nur-xddxdd
  # .invisible-firefox-bin` call still gets the wrapper's own default (read
  # from `config.${applicationName}`).
  {
    pname = "invisible-firefox-bin";
    extraPolicies = policies;
    inherit extraPrefsFiles nativeMessagingHosts;
  }
  // lib.optionalAttrs (cfg != null) {
    inherit cfg;
  }
)).overrideAttrs
  (old: {
    passthru = old.passthru // {
      updateScript = [ (toString ./update.sh) ];
    };
  })
