{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  mesa,
  glib,
  nspr,
  nss,
  dbus,
  atk,
  cups,
  cairo,
  gtk3,
  pango,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libxshmfence,
  libxkbfile,
  expat,
  libxkbcommon,
  udev,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  libdrm,
  webkitgtk_4_1,
  libsoup_3,
  libsecret,
  callPackage,
  curl,
  jq,
}:

let
  current = lib.trivial.importJSON ./version.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "antigravity";
  version = current.version;

  # https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.13.3-4533425205018624/linux-x64/Antigravity.tar.gz
  src = fetchurl {
    url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${finalAttrs.version}/linux-x64/Antigravity${lib.optionalString (lib.versionAtLeast finalAttrs.version "2.0.0") "%20IDE"}.tar.gz";
    hash = current.hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    glib
    nspr
    nss
    dbus
    atk
    cups
    cairo
    gtk3
    pango
    mesa
    expat
    libxkbcommon
    udev
    alsa-lib
    at-spi2-atk
    at-spi2-core
    libdrm
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxshmfence
    libxkbfile
    webkitgtk_4_1
    libsoup_3
    libsecret
  ];

    binaryName = if lib.versionAtLeast finalAttrs.version "2.0.0" then "antigravity-ide" else "antigravity";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/antigravity
    cp -r * $out/share/antigravity

    mkdir -p $out/bin
    makeWrapper $out/share/antigravity/$binaryName $out/bin/antigravity \
      --set ELECTRON_OZONE_PLATFORM_HINT auto \
      --add-flags "--enable-features=UseOzonePlatform --ozone-platform-hint=auto --enable-wayland-ime" \
      --unset NODE_OPTIONS \
      --set TMPDIR /tmp \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}"

    runHook postInstall
  '';

  passthru.updateScript = callPackage ../../utils/update.nix {
    pname = "antigravity";
    versionFile = "pkgs/antigravity/version.json";
    fetchMetaCommand = lib.getExe (
      callPackage ../../utils/json.nix {
        commands = {
          version = ''
            ${lib.getExe curl} -fsSL --max-time 30 \
              'https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/releases' \
            | ${lib.getExe jq} -er '.[0] | .version + "-" + .execution_id | select(test("^[0-9]+[.][0-9]+[.][0-9]+-[0-9]+$"))'
          '';
        };
      }
    );
  };

  meta = {
    description = "Google Antigravity — an internal Chrome/Electron-based development and onboarding tool";
    homepage = "https://research.google/";
    mainProgram = "antigravity";
    binaryNativeCode = true;
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
