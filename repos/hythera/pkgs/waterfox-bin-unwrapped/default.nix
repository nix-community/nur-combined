{
  _7zz,
  adwaita-icon-theme,
  alsa-lib,
  applicationName ? "Waterfox",
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
  pname = "waterfox-bin-unwrapped";
  version = "6.6.8";

  binaryName = "waterfox";
  mozillaPlatforms = {
    aarch64-darwin = "Darwin_x86_64-aarch64";
    x86_64-darwin = "Darwin_x86_64-aarch64";
    x86_64-linux = "Linux_x86_64";
  };

  throwSystem = throw "Unsupported system: ${stdenv.hostPlatform.system}";
  arch = mozillaPlatforms.${stdenv.hostPlatform.system} or throwSystem;
in
stdenv.mkDerivation {
  inherit pname version;

  src =
    if stdenv.hostPlatform.isLinux then
      fetchurl {
        url = "https://cdn.waterfox.com/waterfox/releases/${version}/${arch}/waterfox-${version}.tar.bz2";
        hash = "sha256-Vj94tSPxGxMyl6D2jgz9KBZHjjpmWAfIQeklIYztcYg=";
      }
    else
      fetchurl {
        url = "https://cdn.waterfox.com/waterfox/releases/${version}/${arch}/Waterfox%20${version}.dmg";
        name = "waterfox-${version}.dmg";
        hash = "sha256-Nyd7AXgowlvdsefQGejOH//d1TPxHX71j61/K+rLJNA=";
      };

  sourceRoot = lib.optional stdenv.hostPlatform.isDarwin ".";

  nativeBuildInputs = [
    wrapGAppsHook3
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    autoPatchelfHook
    patchelfUnstable
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    _7zz
  ];

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    gtk3
    adwaita-icon-theme
    alsa-lib
    dbus-glib
    libXtst
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

  # Firefox uses "relrhack" to manually process relocations from a fixed offset
  patchelfFlags = [ "--no-clobber-old-sections" ];

  # don't break code signing
  dontFixup = stdenv.hostPlatform.isDarwin;

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        mkdir -p $out/Applications
        mv Waterfox*.app "$out/Applications/${applicationName}.app"
      ''
    else
      ''
        runHook preInstall

        mkdir -p $prefix/lib $out/bin
        cp -r . $prefix/lib/waterfox-bin-${version}
        ln -s $prefix/lib/waterfox-bin-${version}/waterfox $out/bin/${binaryName}

        chmod +x $out/bin/waterfox

        runHook postInstall
      '';

  passthru = {
    inherit applicationName binaryName;
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
