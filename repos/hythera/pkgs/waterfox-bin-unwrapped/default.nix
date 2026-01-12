{
  adwaita-icon-theme,
  alsa-lib,
  autoPatchelfHook,
  curl,
  dbus-glib,
  fetchurl,
  gtk3,
  lib,
  libva,
  libXtst,
  patchelfUnstable,
  pciutils,
  pipewire,
  stdenv,
  wrapGAppsHook3,
}:
let
  binaryName = "waterfox";
  mozillaPlatforms = {
    x86_64-linux = "Linux_x86_64";
  };

  throwSystem = throw "Unsupported system: ${stdenv.hostPlatform.system}";
  arch = mozillaPlatforms.${stdenv.hostPlatform.system} or throwSystem;
  pname = "waterfox-bin-unwrapped";
  version = "6.6.8";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://cdn.waterfox.com/waterfox/releases/${version}/${arch}/waterfox-${version}.tar.bz2";
    hash =
      {
        x86_64-linux = "sha256-Pvf7J3vhhe+7ooKgbuO0ALv9PN4vQ0U4GcKgobiIzYk=";
      }
      .${stdenv.hostPlatform.system} or throwSystem;
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    autoPatchelfHook
    patchelfUnstable
  ];

  buildInputs = [
    gtk3
    adwaita-icon-theme
    alsa-lib
    dbus-glib
    libXtst
  ];

  runtimeDependencies = [
    curl
    libva.out
    pciutils
  ];

  appendRunpaths = [ "${pipewire}/lib" ];

  # Firefox uses "relrhack" to manually process relocations from a fixed offset
  patchelfFlags = [ "--no-clobber-old-sections" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $prefix/lib $out/bin
    cp -r . $prefix/lib/waterfox-bin-${version}
    ln -s $prefix/lib/waterfox-bin-${version}/waterfox $out/bin/${binaryName}

    chmod +x $out/bin/waterfox

    runHook postInstall
  '';

  passthru = {
    inherit binaryName;
    applicationName = "Waterfox";
    libName = "waterfox-bin-${version}";
    ffmpegSupport = true;
    gssSupport = true;
    gtk3 = gtk3;
  };

  meta = {
    description = "A privacy-focused Firefox Fork (upstream binary release)";
    homepage = "https://www.waterfox.com";
    license = lib.licenses.mpl20;
    platforms = builtins.attrNames mozillaPlatforms;
    mainProgram = "waterfox";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
