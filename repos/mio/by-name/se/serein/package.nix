{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  git,
  makeWrapper,
  writeShellApplication,
  nix-update,
  python3,
  swiftPackages,
  apple-sdk_15,
  wrapGAppsHook4,
  autoPatchelfHook,
  glib,
  glib-networking,
  gsettings-desktop-schemas,
  gtk4,
  webkitgtk_6_0,
  cairo,
  pango,
  gdk-pixbuf,
  graphene,
  libsoup_3,
  fontconfig,
  libxkbcommon,
  wayland,
  vulkan-loader,
  libGL,
  libGLX,
  libpulseaudio,
  libglvnd,
  alsa-lib,
  gst_all_1,
  pipewire,
  libx11,
  libxi,
  libxrandr,
  libxcursor,
  bubblewrap,
  xdg-dbus-proxy,
}:

let
  inherit (stdenv.hostPlatform) isLinux isDarwin;

  # webKit stack
  toolkitDeps = [
    glib
    glib-networking
    gsettings-desktop-schemas
    gtk4
    webkitgtk_6_0
    cairo
    pango
    gdk-pixbuf
    graphene
    libsoup_3
    fontconfig
  ];

  graphicsDeps = [
    vulkan-loader
    libGL
    libGLX
    libglvnd
  ];

  windowingDeps = [
    wayland
    libxkbcommon
    libx11
    libxi
    libxrandr
    libxcursor
  ];

  audioDeps = [
    libpulseaudio
    alsa-lib
  ];

  gstPlugins = with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-libav
    gstreamer
    pipewire
  ];

  runtimeTools = [
    bubblewrap
    xdg-dbus-proxy
  ];

  # nixpkgs' swift-collections dylibs lack room for the install-name fixups
  # that its own fixup phase performs, which aborts the SwiftPM build chain.
  swiftPackages' = swiftPackages.overrideScope (
    _final: prev: {
      swift-collections = prev.swift-collections.overrideAttrs (old: {
        preConfigure = (old.preConfigure or "") + ''
          appendToVar cmakeFlags ${lib.escapeShellArg "-DCMAKE_Swift_FLAGS=-Xlinker -headerpad_max_install_names"}
        '';
      });
    }
  );
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "serein";
  version = "1.0.0-unstable-2026-11-20";

  src = fetchFromGitHub {
    owner = "ViceVerse-cz";
    repo = "Serein";
    rev = "39c7c49bbcb1d6b642ff4ce066445d8bc56ff46d";
    hash = "sha256-06q9RokGIyceCNYNukE86ZoJMlCcstZvF/WxJtChO/8=";
  };

  # Keep bundled symbols local so each copy stays consistent.
  env.RUSTFLAGS = lib.optionalString isLinux "-C link-arg=-Wl,--exclude-libs,ALL";

  # nixpkgs now points -sys crates at system libraries before configuring (AWS-LC,
  # SQLite, OpenSSL, ...). The package does not provide them and links the bundled
  # copies, as it did before; keep that.
  dontCargoUseSystemLibs = true;

  cargoHash = "sha256-TSdUW+VZBPFH3kCsHmc8bRVrrz8sMkxKPJVSKzrJjlY=";

  cargoBuildFlags = [
    "--package"
    "serein"
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    makeWrapper
    # BoringSSL (wreq's TLS): btls-sys patches its bundled source with
    # `git apply` and generates bindings through libclang.
    git
    rustPlatform.bindgenHook
  ]
  ++ lib.optionals isLinux [
    wrapGAppsHook4
    autoPatchelfHook
  ]
  # Only the toolchain: the apple-* crates compile a small Swift bridge
  # with `swift build`.
  ++ lib.optionals isDarwin [
    swiftPackages'.swift
    swiftPackages'.swiftpm
    swiftPackages'.stdlib
  ];

  buildInputs =
    lib.optionals isLinux (toolkitDeps ++ graphicsDeps ++ windowingDeps ++ audioDeps ++ gstPlugins)
    ++ lib.optionals isDarwin [ apple-sdk_15 ];

  # winit loads these libraries dynamically; retain them in the runtime RPATH.
  runtimeDependencies = lib.optionals isLinux (graphicsDeps ++ windowingDeps);

  dontUseSwiftpmBuild = true;
  dontUseSwiftpmCheck = true;
  dontUseSwiftpmInstall = true;
  doCheck = false;

  passthru.updateScript = writeShellApplication {
    name = "update-serein";
    runtimeInputs = [
      python3
      nix-update
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="serein"
      exec python3 ${./update.py} "$@"
    '';
  };

  # discord-voice links against the Swift runtime that ships in the SDK.
  preBuild = lib.optionalString isDarwin ''
    export RUSTFLAGS="$RUSTFLAGS -L native=$SDKROOT/usr/lib/swift"
    # The Swift driver shells out to xcrun; point it at the developer dir
    # that owns the active SDK (SDKROOT is <devdir>/Platforms/.../MacOSX.sdk).
    # swift-driver's xcrun lookups use $NIX_BUILD_TOP as developer dir; give
    # it an xcrun there that points back at the packaged SDK.
    devdir=$NIX_BUILD_TOP/.devdir
    realdev=$(realpath "$SDKROOT/../../../../..")
    mkdir -p "$devdir" "$NIX_BUILD_TOP/usr/bin"
    for d in Platforms Toolchains Library; do
      [ -e "$devdir/$d" ] || ln -s "$realdev/$d" "$devdir/$d"
    done
    # xcrun resolves swift/swiftc below $DEVELOPER_DIR/usr/bin, but the SDK
    # package ships only binutils there; merge in the nixpkgs toolchain.
    mkdir -p "$devdir/usr/bin"
    for e in "$realdev"/usr/bin/*; do
      ln -sf "$e" "$devdir/usr/bin/$(basename "$e")"
    done
    ln -sf ${swiftPackages'.swift}/bin/swift "$devdir/usr/bin/swift"
    ln -sf ${swiftPackages'.swift}/bin/swiftc "$devdir/usr/bin/swiftc"
    cat > "$NIX_BUILD_TOP/usr/bin/xcrun" <<EOF
    #!${stdenv.shell}
    # SwiftPM exports a synthetic TOOLCHAINS id that xcrun cannot resolve.
    unset TOOLCHAINS
    export DEVELOPER_DIR=$realdev
    exec $realdev/usr/bin/xcrun "\$@"
    EOF
    chmod +x "$NIX_BUILD_TOP/usr/bin/xcrun"
    export DEVELOPER_DIR=$devdir

    mkdir -p .swift-shim

    # apple-cf/apple-metal bridge builds drive xcbuild, which looks for
    # xcrun; provide one from the packaged SDK.
    cat > .swift-shim/xcrun <<EOF
    #!${stdenv.shell}
    unset TOOLCHAINS
    exec $DEVELOPER_DIR/usr/bin/xcrun "\$@"
    EOF
    chmod +x .swift-shim/xcrun

    cat > .swift-shim/swift <<EOF
    #!${stdenv.shell}
    export DEVELOPER_DIR=$DEVELOPER_DIR
    exec ${swiftPackages'.swift}/bin/swift "\$@"
    EOF
    chmod +x .swift-shim/swift

    cat > .swift-shim/swiftc <<EOF
    #!${stdenv.shell}
    export DEVELOPER_DIR=$DEVELOPER_DIR
    exec ${swiftPackages'.swift}/bin/swiftc "\$@"
    EOF
    chmod +x .swift-shim/swiftc
    export SWIFT_EXEC=$PWD/.swift-shim/swiftc
    export PATH=$PWD/.swift-shim:$PATH
  '';

  preFixup = lib.optionalString isLinux ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath runtimeTools}"
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins
      }"
    )
  '';

  # Mirror `cargo xtask package`: notices, licenses and the corresponding
  # MPL-2.0 hpke-rs source ship with every binary.
  postInstall = ''
    docs="$out/share/doc/serein"
  ''
  + lib.optionalString isDarwin ''
    app="$out/Applications/Serein.app/Contents"
    docs="$app/Resources"
  ''
  + ''
    mkdir -p "$docs/licenses" "$docs/source"
    cp README.md LICENSE-MIT LICENSE-APACHE THIRD_PARTY_NOTICES.md "$docs/"
    cp -R assets/licenses/. "$docs/licenses/"
    cp assets/fonts/*-OFL.txt assets/fonts/*-LICENSE.txt "$docs/licenses/"
    cp assets/sounds/README.md "$docs/licenses/notification-sounds.md"
    cp assets/twemoji/LICENSE-GRAPHICS "$docs/licenses/Twemoji-CC-BY-4.0.txt"
    cp assets/twemoji/LICENSE-UNICODE "$docs/licenses/Unicode-LICENSE.txt"
    cp assets/icons/LICENSE "$docs/licenses/Phosphor-Icons-MIT.txt"
    cp assets/icons/LICENSE-SIMPLE-ICONS "$docs/licenses/Simple-Icons-CC0.txt"
    cp -R vendor/hpke-rs "$docs/source/"
  ''
  + lib.optionalString isLinux ''
    install -Dm444 packaging/linux/serein.desktop \
      $out/share/applications/cz.viceverse.serein.desktop
    substituteInPlace $out/share/applications/cz.viceverse.serein.desktop \
      --replace-fail "Exec=serein" "Exec=$out/bin/serein"
    mkdir -p $out/share/icons
    cp -R packaging/linux/hicolor $out/share/icons/
  ''
  # The executable lives inside the bundle so macOS resolves its Info.plist
  # (privacy usage descriptions, identifier and icon) from the launched binary.
  + lib.optionalString isDarwin ''
    install -Dm444 packaging/macos/Info.plist "$app/Info.plist"
    install -Dm444 packaging/macos/Serein.icns "$app/Resources/Serein.icns"
    mkdir -p "$app/MacOS" "$out/share/doc"
    mv "$out/bin/serein" "$app/MacOS/serein"
    ln -s "$app/MacOS/serein" "$out/bin/serein"
    ln -s "$app/Resources" "$out/share/doc/serein"
  '';

  meta = {
    description = "Tiny, performant, native Discord client written in Rust (egui/wgpu)";
    homepage = "https://github.com/ViceVerse-cz/Serein";
    license = with lib.licenses; [
      mit
      asl20
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "serein";
    maintainers = with lib.maintainers; [ myamusashi ];
  };
})
