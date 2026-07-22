{
  lib,
  stdenv,
  llvmPackages,
  fixDarwinDylibNames,
  fetchFromGitLab,
  pkg-config,
  meson,
  ninja,
  cmake,
  git,
  criterion,
  gdk-pixbuf,
  librsvg,
  adwaita-icon-theme,
  hicolor-icon-theme,
  shared-mime-info,
  # Optional: puts solve-field on PATH for siril's "local astrometry.net" solver.
  astrometry-net ? null,
  gtk3,
  gtksourceview4,
  libconfig,
  gnuplot,
  opencv,
  python3,
  json-glib,
  fftwFloat,
  cfitsio,
  gsl,
  exiv2,
  librtprocess,
  wcslib,
  ffmpeg,
  libraw,
  libtiff,
  libpng,
  libgit2,
  libjpeg,
  libjxl,
  libheif,
  libxisf,
  ffms,
  wrapGAppsHook3,
  curl,
  yyjson,
  versionCheckHook,
  nix-update-script,
}:

let
  # libxisf is a plain CMake library (lz4/pugixml/zlib/zstd, all cross-platform);
  # upstream nixpkgs only marks it linux because it was never tested on darwin.
  libxisf' = libxisf.overrideAttrs (old: {
    meta = old.meta // {
      platforms = old.meta.platforms ++ [ "aarch64-darwin" ];
    };
  });

  # wcslib builds its dylib with a bare install id ("libwcs.8.dylib") instead of
  # an absolute store path, so anything linking it fails to load at runtime on
  # darwin. fixDarwinDylibNames rewrites the id (and references) to $out/lib.
  wcslib' = wcslib.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ fixDarwinDylibNames ];
  });

in
stdenv.mkDerivation (finalAttrs: {
  pname = "siril";
  version = "1.4.4";

  src = fetchFromGitLab {
    owner = "free-astro";
    repo = "siril";
    tag = finalAttrs.version;
    hash = "sha256-UgG/efOMVeQJ1r219YOPkgkPqEdaXJquqXyWZW0oWgI=";
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
    git
    criterion
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    cfitsio
    gsl
    exiv2
    gnuplot
    gtksourceview4
    opencv
    fftwFloat
    librtprocess
    wcslib'
    libconfig
    libraw
    libtiff
    libpng
    libgit2
    libjpeg
    libjxl
    libheif
    libxisf'
    ffms
    ffmpeg
    json-glib
    curl
    yyjson
    # GTK runtime data: adwaita/hicolor supply the themed icons the UI asks for
    # (e.g. "user-home-ltr", symbolic check marks) and shared-mime-info supplies
    # the MIME database GTK sniffs against. wrapGAppsHook3 does NOT auto-add
    # dependency icon/mime dirs to XDG_DATA_DIRS, so postInstall wires their
    # share dirs into the wrapper explicitly; without them the app logs
    # "hicolor theme was not found" and can't resolve stock icons.
    adwaita-icon-theme
    hicolor-icon-theme
    shared-mime-info
  ]
  # macOS clang ships no bundled OpenMP runtime; siril's meson build enables
  # OpenMP unconditionally, so provide omp.h and libomp explicitly on darwin.
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.openmp
  ];

  propagatedBuildInputs = [ python3 ];

  # Necessary because project uses default build dir for flatpaks/snaps
  mesonBuildDir = "nixbld";

  # On darwin, "relocatable-bundle" defaults to "yes", which makes siril resolve
  # its data dir (python_module/pyproject.toml, catalogues, scripts, locale) via
  # the $SIRIL_RELOCATED_RES_DIR env var expected inside a .app/.dmg. Under Nix
  # everything lives at a fixed absolute PACKAGE_DATA_DIR ($out/share/siril), so
  # disable relocation — otherwise the data dir is NULL and e.g. the Python venv
  # setup fails with 'Failed to open file "pyproject.toml"'.
  mesonFlags = [
    (lib.mesonOption "relocatable-bundle" "no")
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # --- SVG pixbuf loader repair ------------------------------------------
    # librsvg's gdk-pixbuf SVG loader is linked against "@rpath/librsvg-2.2.dylib"
    # but ships no LC_RPATH on aarch64-darwin, so dyld can't dlopen it. That makes
    # gdk-pixbuf-query-loaders drop it (librsvg's own loaders.cache has an empty
    # svg entry), and every SVG the GTK UI touches — symbolic icons, menu
    # check-marks, the logo — fails with "Unrecognized image file format".
    #
    # Rather than rebuild librsvg (its compiled loader is fine, only a Mach-O
    # load command is wrong), copy the loader into our own output, rewrite the
    # dangling dependency to the absolute dylib, and regenerate a loaders.cache
    # that lists it. install_name_tool re-signs ad-hoc on its own, so no codesign
    # is needed. The absolute references keep librsvg in siril's runtime closure.
    loaderDir="$out/lib/gdk-pixbuf-2.0/2.10.0/loaders"
    mkdir -p "$loaderDir"
    cp ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader_svg.dylib "$loaderDir/"
    chmod u+w "$loaderDir/libpixbufloader_svg.dylib"
    install_name_tool \
      -id "$loaderDir/libpixbufloader_svg.dylib" \
      -change @rpath/librsvg-2.2.dylib ${librsvg}/lib/librsvg-2.2.dylib \
      "$loaderDir/libpixbufloader_svg.dylib"
    ${lib.getDev gdk-pixbuf}/bin/gdk-pixbuf-query-loaders \
      ${lib.getLib gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders/*.so \
      "$loaderDir/libpixbufloader_svg.dylib" \
      > "$out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
    # wrapGAppsHook3 bakes the current $GDK_PIXBUF_MODULE_FILE into the launcher
    # during fixup (later, same shell), so override it here to our fixed cache.
    export GDK_PIXBUF_MODULE_FILE="$out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"

    # --- icon themes + MIME database ---------------------------------------
    # wrapGAppsHook3 only folds siril's own share and the gsettings schemas into
    # XDG_DATA_DIRS — not dependency icon themes or the MIME db — so listing them
    # in buildInputs alone leaves them invisible to the launcher. Add them to the
    # wrapper explicitly (gappsWrapperArgs is consumed later, during fixup).
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${adwaita-icon-theme}/share"
      --prefix XDG_DATA_DIRS : "${hicolor-icon-theme}/share"
      --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"
    )
    ${lib.optionalString (astrometry-net != null) ''
      gappsWrapperArgs+=(--prefix PATH : "${lib.getBin astrometry-net}/bin")
    ''}

  '';

  # Build the macOS .app in postFixup — AFTER wrapGAppsHook3 has produced the
  # wrapped launcher ($out/bin/.siril-wrapped) and fully populated
  # gappsWrapperArgs. A real desktop app (Finder/Spotlight/Dock) rather than a
  # bare CLI binary.
  #
  # The naive approach — symlink Contents/MacOS/siril -> $out/bin/siril — gives a
  # blank Dock icon and shows the app as ".siril-wrapped": that launcher is a
  # makeBinaryWrapper that re-execs $out/bin/.siril-wrapped *outside* the bundle,
  # so by the time GTK initialises, _NSGetExecutablePath() points into /nix/store
  # and AppKit can't find the bundle's Info.plist (no CFBundleName, no icon).
  #
  # Keep the running process inside the bundle instead: hard-link the real GTK
  # binary into Contents/MacOS (a real file, unlike a symlink into the store, so
  # AppKit resolves the bundle from it) and point a fresh env-wrapper — reusing
  # the exact gappsWrapperArgs so the GTK runtime env matches bin/siril — at that
  # in-bundle copy. Now _NSGetExecutablePath() resolves to Siril.app, so the Dock
  # shows the icns icon and the menu bar shows CFBundleName ("Siril").
  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    appDir="$out/Applications/Siril.app"
    mkdir -p "$appDir/Contents/MacOS" "$appDir/Contents/Resources"

    ln "$out/bin/.siril-wrapped" "$appDir/Contents/MacOS/siril-bin"
    makeWrapper "$appDir/Contents/MacOS/siril-bin" "$appDir/Contents/MacOS/Siril" \
      "''${gappsWrapperArgs[@]}"

    cp "$src/platform-specific/macos/siril.icns" "$appDir/Contents/Resources/siril.icns"

    cat > "$appDir/Contents/Info.plist" <<PLIST
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleDevelopmentRegion</key><string>en</string>
      <key>CFBundleExecutable</key><string>Siril</string>
      <key>CFBundleIconFile</key><string>siril</string>
      <key>CFBundleIdentifier</key><string>org.siril.Siril</string>
      <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
      <key>CFBundleName</key><string>Siril</string>
      <key>CFBundleDisplayName</key><string>Siril</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleShortVersionString</key><string>${finalAttrs.version}</string>
      <key>CFBundleVersion</key><string>${finalAttrs.version}</string>
      <key>LSMinimumSystemVersion</key><string>11.0</string>
      <key>NSHighResolutionCapable</key><true/>
    </dict>
    </plist>
    PLIST

    printf 'APPL????' > "$appDir/Contents/PkgInfo"
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    homepage = "https://www.siril.org/";
    description = "Astrophotographic image processing tool";
    license = lib.licenses.gpl3Plus;
    changelog = "https://gitlab.com/free-astro/siril/-/blob/HEAD/ChangeLog";
    maintainers = with lib.maintainers; [ congee ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "siril";
  };
})
