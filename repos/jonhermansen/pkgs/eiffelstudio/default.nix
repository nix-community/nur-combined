{
  fetchurl,
  lib,
  makeDesktopItem,
  stdenv,

  # nativeBuildInputs
  copyDesktopItems,
  dotnet-sdk,
  libicns,
  makeWrapper,
  pax,
  pkg-config,
  wrapGAppsHook3,

  # buildInputs
  adwaita-icon-theme,
  cairo,
  dotnet-runtime,
  gdk-pixbuf,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  pango,
  xorg,

  dotnetSupport ? false, # Untested integration with .NET, disabled for now
}:

let
  isDarwin = stdenv.hostPlatform.isDarwin;
  platformName =
    {
      "x86_64-linux" = "linux-x86-64";
      "aarch64-linux" = "linux-arm64";
      # ISE ships a single macOS spec ("macosx-x86-64"); native clang still
      # emits arm64 on Apple Silicon (matches Homebrew, which uses it for all macOS).
      "x86_64-darwin" = "macosx-x86-64";
      "aarch64-darwin" = "macosx-x86-64";
    }
    .${stdenv.system} or null;
in
stdenv.mkDerivation rec {
  pname = "eiffelstudio";
  version = "25.02.98732";

  src = fetchurl {
    # Use the version-pinned directory, not "latest/" — "latest" tracks the
    # current release and 404s for every older pinned version (and is non-reproducible).
    url = "https://ftp.eiffel.com/pub/download/${lib.versions.majorMinor version}/pp/PorterPackage_${lib.versions.majorMinor version}_rev_${lib.versions.patch version}.tar";
    sha256 = "sha256-/XoewqCeh1NfB3ve9UL+0WZfZ5DEa4N7REl67Ftlxt0=";
  };

  nativeBuildInputs = [
    makeWrapper
    pax
    pkg-config
    wrapGAppsHook3
  ]
  ++ lib.optional isDarwin libicns
  ++ lib.optional (!isDarwin) copyDesktopItems
  ++ lib.optional dotnetSupport dotnet-sdk;

  buildInputs = [
    adwaita-icon-theme
    cairo
    gdk-pixbuf
    glib
    gsettings-desktop-schemas
    gtk3
    pango
    xorg.libX11
    xorg.libXtst
  ]
  ++ lib.optional dotnetSupport dotnet-runtime;

  # We run makeWrapper by hand (below), so let wrapGAppsHook3 only assemble the
  # GTK/GIO runtime env into gappsWrapperArgs and not wrap the binaries itself.
  dontWrapGApps = true;

  sourceRoot = "PorterPackage";
  postPatch = ''
    # A script inside this tarball depends on hardcoded coreutils + gnused paths
    tar -xf c.tar.bz2

    # CONFIGS hardcodes absolute tool paths (coreutils under /bin, but sed under
    # /usr/bin on macOS). Map them to bare PATH lookups. Match the surrounding
    # quotes so "'/bin/sed'" can't mangle "'/usr/bin/sed'" into "/usrsed".
    for i in cp ln mv rm sed; do
      substituteInPlace C/CONFIGS/${platformName} \
        --replace-quiet "'/usr/bin/$i'" "'$i'" \
        --replace-quiet "'/bin/$i'" "'$i'"
    done
  ''
  + lib.optionalString isDarwin ''
    # Modern macOS ld rejects the legacy flat-namespace flags (matches Homebrew).
    substituteInPlace C/CONFIGS/${platformName} \
      --replace-fail "-flat_namespace -undefined suppress" "-undefined dynamic_lookup"

    # Link shared libs through the compiler driver, not bare `ld`: `-dynamiclib`
    # is a cc/clang driver flag, and nix's wrapped `ld` rejects it (Apple's ld64
    # happens to accept it, which is why upstream/Homebrew get away with `ld`).
    substituteInPlace C/CONFIGS/${platformName} \
      --replace-fail 'sharedlink=$ld' 'sharedlink=$cc'
  ''
  + ''
    # Re-assemble the tarball with fixed up paths and clean up after ourselves
    rm c.tar.bz2
    tar -cjSf c.tar.bz2 C
    rm -rf C
  '';

  hardeningDisable = [ "format" ]; # Allow printf without a format string
  # Better explained here: https://fedoraproject.org/wiki/Format-Security-FAQ

  # clang 15+ (Xcode 15 / Apple clang 21 here) turns incompatible function
  # pointer types into a hard error; ISE's generated C trips it on macOS.
  env.NIX_CFLAGS_COMPILE = lib.optionalString isDarwin "-Wno-incompatible-function-pointer-types";

  buildPhase = ''
    runHook preBuild
    ./compile_exes ${platformName}
    ./make_images ${platformName}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt

    cp -r Eiffel_${lib.versions.majorMinor version} $out/opt
    install -Dm444 packaging/logo.png $out/share/icons/estudio.png

    runHook postInstall
  '';

  # Wrap in preFixup so wrapGAppsHook3 has already populated gappsWrapperArgs
  # (its hook runs at the start of fixupPhase, after installPhase).
  preFixup = ''
    ise_eiffel=$out/opt/Eiffel_${lib.versions.majorMinor version}

    # `ec` is the command-line compiler; it needs only the ISE runtime env.
    makeWrapper $ise_eiffel/studio/spec/${platformName}/bin/ec $out/bin/ec \
      --set ISE_EIFFEL $ise_eiffel \
      --set ISE_PLATFORM ${platformName}

    # `estudio` is the GTK IDE; give it the GTK/GIO env plus a readable default
    # theme (GTK's quartz backend has no system theme, which rendered white-on-
    # white). --set-default lets a user's own GTK_THEME still win.
    makeWrapper $ise_eiffel/studio/spec/${platformName}/bin/estudio $out/bin/estudio \
      "''${gappsWrapperArgs[@]}" \
      --set ISE_EIFFEL $ise_eiffel \
      --set ISE_PLATFORM ${platformName} \
      --set-default GTK_THEME Adwaita
  ''
  + lib.optionalString isDarwin ''
    # Ship a real .app bundle so LaunchServices treats EiffelStudio as an app:
    # dock icon, foreground activation on launch, and .ecf/.e file association.
    # nix-darwin and home-manager link $out/Applications/*.app into ~/Applications
    # automatically, so the GUI experience comes from this same package.
    app=$out/Applications/EiffelStudio.app
    mkdir -p $app/Contents/MacOS $app/Contents/Resources

    # Thin launcher that execs the PATH wrapper, so the bundle inherits the same
    # GTK/ISE env; keeps the bundle's main executable a regular file (not a symlink,
    # which LaunchServices dislikes).
    makeWrapper $out/bin/estudio $app/Contents/MacOS/EiffelStudio

    # PNG logo -> .icns. If the source png isn't a size png2icns accepts, skip the
    # icon rather than fail the build (Finder then shows the generic app icon).
    png2icns $app/Contents/Resources/estudio.icns $out/share/icons/estudio.png || true

    cat > $app/Contents/Info.plist <<'PLIST'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleName</key><string>EiffelStudio</string>
      <key>CFBundleDisplayName</key><string>EiffelStudio</string>
      <key>CFBundleIdentifier</key><string>com.eiffel.eiffelstudio</string>
      <key>CFBundleExecutable</key><string>EiffelStudio</string>
      <key>CFBundleIconFile</key><string>estudio</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleShortVersionString</key><string>${lib.versions.majorMinor version}</string>
      <key>CFBundleVersion</key><string>${version}</string>
      <key>LSApplicationCategoryType</key><string>public.app-category.developer-tools</string>
      <key>LSMinimumSystemVersion</key><string>10.12</string>
      <key>NSHighResolutionCapable</key><true/>
      <key>CFBundleDocumentTypes</key>
      <array>
        <dict>
          <key>CFBundleTypeName</key><string>Eiffel Configuration File</string>
          <key>CFBundleTypeExtensions</key><array><string>ecf</string></array>
          <key>CFBundleTypeRole</key><string>Editor</string>
        </dict>
        <dict>
          <key>CFBundleTypeName</key><string>Eiffel Source File</string>
          <key>CFBundleTypeExtensions</key><array><string>e</string></array>
          <key>CFBundleTypeRole</key><string>Editor</string>
        </dict>
      </array>
    </dict>
    </plist>
    PLIST
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "estudio";
      desktopName = "EiffelStudio";
      exec = "estudio %F";
      keywords = [ "Development" ];
      categories = [ "Development" ];
      icon = "estudio";
      mimeTypes = [ "text/x-eiffel" ];
    })
  ];

  meta = {
    description = "IDE for the Eiffel language";
    longDescription = ''
      EiffelStudio is a software application that provides comprehensive
      facilities to programmers for software development, powered by the Eiffel
      language. It has a suite of tools and services that enable programmers to
      produce correct, reliable, and maintainable software and control the
      development process.
    '';
    license = lib.licenses.gpl2Only;
    homepage = "https://dev.eiffel.com";
    platforms = lib.platforms.unix;
    mainProgram = "estudio";
  };
}
