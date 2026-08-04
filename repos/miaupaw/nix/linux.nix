# ─────────────────────────────────────────────────────────────────────────────
# nix/linux.nix — Linux distribution outputs.
#   • appimage           — AppImage Type 2: pinned type2-runtime + squashfs(AppDir).
# Linux distribution outputs: relocatable portable + (broken) appimage + zip
# wrapper. Plus the two #!/bin/sh scripts shipped inside portable. defaultPkg
# is the built ie-r from package.nix; linux.nix adds distribution scaffolding.
# ─────────────────────────────────────────────────────────────────────────────
{ pkgs, version, copyCommonDocs, defaultPkg  } : # the built ie-r derivation (packages.default)

let
  # ── Portable Scripts ──────────────────────────────────────────────────
  # MUST use #!/bin/sh — these scripts run on non-Nix systems. pkgs.writeShellScript
  # would embed #!/nix/store/... which breaks portability.
  # AppRun — AppImage entry point. Does two things:
  #   1. Desktop integration: creates/updates ie-r.desktop if missing or Exec= path changed
  #      (user moved the AppImage). Cache updates run in background — no startup delay.
  #   2. Launch: execs $APPDIR/bin/ie-r (portableLauncher handles ld-linux + env vars).
  # $APPIMAGE and $APPDIR are set by type2-runtime before AppRun is called.
  appRun = pkgs.writeTextFile {
    name = "AppRun";
    executable = true;
    text = ''
        #!/bin/sh
        # bash
        DESKTOP="$HOME/.local/share/applications/ie-r.desktop"
        ICON_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"
        ICON_SYMBOLIC_DIR="$HOME/.local/share/icons/hicolor/symbolic/apps"
        CURRENT_EXEC=$(grep "^Exec=" "$DESKTOP" 2>/dev/null | cut -d= -f2-)

        if [ ! -f "$DESKTOP" ] || [ "$CURRENT_EXEC" != "$APPIMAGE" ]; then
            mkdir -p "$HOME/.local/share/applications" "$ICON_DIR" "$ICON_SYMBOLIC_DIR"

            printf '%s\n' \
                '[Desktop Entry]' \
                'Name=Instant Eyedropper Reborn' \
                'Comment=Pixel-perfect color picker. Native Wayland/X11.' \
                "Exec=$APPIMAGE" \
                'Icon=ie-r' \
                'Type=Application' \
                'Categories=Utility;Graphics;Development;' \
                'StartupNotify=false' \
                'Terminal=false' \
                'StartupWMClass=ie-r' \
                'SkipTaskbar=true' \
                'X-KDE-DBUS-Restricted-Interfaces=org.kde.KWin.ScreenShot2' \
                > "$DESKTOP"

            cp "$APPDIR/ie-r.svg" "$ICON_DIR/ie-r.svg" 2>/dev/null
            cp "$APPDIR/share/icons/hicolor/symbolic/apps/ie-r-symbolic.svg" "$ICON_SYMBOLIC_DIR/ie-r-symbolic.svg" 2>/dev/null

            update-desktop-database "$HOME/.local/share/applications" 2>/dev/null &
            gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null &
        fi

        exec "$APPDIR/bin/ie-r" "$@"
    '';
  };

  portableLauncher = pkgs.writeTextFile {
    name = "ie-r";
    executable = true;
    # higlighter token on second string for correct appimage assembly
    text = ''
        #!/bin/sh
        # bash
        HERE="$(dirname "$(readlink -f "$0")")"
        export XKB_CONFIG_ROOT="$HERE/../share/xkb"
        export XLOCALEDIR="$HERE/../share/X11/locale"
        export IE_R_ICON_THEME_PATH="$HERE/../share/icons"
        export IE_R_FONT_DIR="$HERE/../fonts"
        exec "$HERE/../lib/ld-linux-x86-64.so.2" --library-path "$HERE/../lib" "$HERE/.ie-r-raw" "$@"
    '';
  };

  postinstallScript = pkgs.writeTextFile {
    name = "postinstall";
    executable = true;
    # higlighter token on second string for correct appimage assembly
    text = ''
        #!/bin/sh
        # bash
        HERE="$(dirname "$(readlink -f "$0")")"
        DESKTOP_DIR="$HOME/.local/share/applications"
        AUTOSTART_DIR="$HOME/.config/autostart"
        ICON_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"
        ICON_SYMBOLIC_DIR="$HOME/.local/share/icons/hicolor/symbolic/apps"
        mkdir -p "$DESKTOP_DIR" "$AUTOSTART_DIR" "$ICON_DIR" "$ICON_SYMBOLIC_DIR"

        printf '%s\n' \
            '[Desktop Entry]' \
            'Name=Instant Eyedropper Reborn' \
            'Comment=Pixel-perfect color picker. Native Wayland/X11.' \
            "Exec=$HERE/bin/ie-r" \
            'Icon=ie-r' \
            'Type=Application' \
            'Categories=Utility;Graphics;Development;' \
            'StartupNotify=false' \
            'Terminal=false' \
            'StartupWMClass=ie-r' \
            'SkipTaskbar=true' \
            'X-KDE-DBUS-Restricted-Interfaces=org.kde.KWin.ScreenShot2' \
            > "$DESKTOP_DIR/ie-r.desktop"

        chmod +x "$DESKTOP_DIR/ie-r.desktop"

        cp "$HERE/share/icons/hicolor/scalable/apps/ie-r.svg" "$ICON_DIR/ie-r.svg"
        cp "$HERE/share/icons/hicolor/symbolic/apps/ie-r-symbolic.svg" "$ICON_SYMBOLIC_DIR/ie-r-symbolic.svg"

        update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

        echo "✔ Desktop integration complete! IE-R is now in your application menu."

        printf "? Add IE-R to Autostart? (y/N): "
        read -r choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            cp "$DESKTOP_DIR/ie-r.desktop" "$AUTOSTART_DIR/"
            echo "✔ Added to autostart!"
        fi

        echo "--------------------------------------------------"
        echo "※ WAYLAND HOTKEYS TIP:"
        echo "Global hotkeys can be tricky on Wayland (GNOME/KDE)."
        echo "For perfect reliability, set a 'Custom Shortcut' in your OS settings:"
        echo "   Command: /usr/bin/pkill -SIGUSR1 -f ie-r"
        echo "--------------------------------------------------"
        echo "→ Points to: $HERE/bin/ie-r"
    '';
  };

  # ── Relocatable Bundle ────────────────────────────────────────────────
  # Surgical lib-harvest: ldd the binary + force-include dlopen entry points
  # (X11/Wayland), then recursive ldd to pull libxcb/libXau/etc. Bundles
  # ld-linux + trimmed xkb/locale data → self-contained on any glibc Linux.
  portable = pkgs.stdenv.mkDerivation {
    name = "ie-r-portable";
    nativeBuildInputs = [ pkgs.patchelf ];
    phases = [ "installPhase" ];

    installPhase = '' # bash
        mkdir -p $out/{bin,lib,share/X11/locale}

        # 1. Binary & Library Gathering (Surgical approach)
        cp -v ${defaultPkg}/bin/ie-r $out/bin/.ie-r-raw
        chmod +w $out/bin/.ie-r-raw

        echo "▸ Harvesting REQUIRED runtime libraries..."
        # 1a. Gather direct dependencies of the binary
        ldd $out/bin/.ie-r-raw | awk '{print $3}' | grep "^/nix/store" > libs_list

        # 1b. Force-include X11/Wayland entry points for dlopen()
        echo "▸ Locating dlopen entry points (X11 + Wayland)..."
        for lib in \
            ${pkgs.wayland}/lib/libwayland-client.so.0 \
            ${pkgs.libx11}/lib/libX11.so.6 \
            ${pkgs.libx11}/lib/libX11-xcb.so.1 \
            ${pkgs.libxcursor}/lib/libXcursor.so.1 \
            ${pkgs.libxrandr}/lib/libXrandr.so.2 \
            ${pkgs.libxi}/lib/libXi.so.6 \
            ${pkgs.libxrender}/lib/libXrender.so.1 \
            ${pkgs.libxkbcommon}/lib/libxkbcommon-x11.so.0; \
        do
            echo "$lib" >> libs_list
        done

        # 1c. First pass copy (following symlinks to be standalone)
        sort -u libs_list | xargs -I{} cp -nL {} $out/lib/ 2>/dev/null || true

        # 1d. Recursive pass: trace dependencies of everything gathered so far
        # This pulls in libxcb, libXau, libXdmcp, etc.
        ldd $out/lib/*.so* 2>/dev/null | awk '{print $3}' | grep "^/nix/store" | sort -u | xargs -I{} cp -nL {} $out/lib/ 2>/dev/null || true

        # 2. Assets, Loader & Permissions
        chmod +w $out/lib/* $out/bin/.ie-r-raw
        cp -vL "${pkgs.glibc.out}/lib/ld-linux-x86-64.so.2" $out/lib/

        echo "▸ Trimming XKB and Locale fat..."
        mkdir -p $out/share/xkb/{rules,keycodes,symbols,types,compat}
        cp -R ${pkgs.xkeyboard_config}/share/X11/xkb/rules/evdev*         $out/share/xkb/rules/
        cp -R ${pkgs.xkeyboard_config}/share/X11/xkb/keycodes/evdev       $out/share/xkb/keycodes/
        cp -R ${pkgs.xkeyboard_config}/share/X11/xkb/keycodes/aliases     $out/share/xkb/keycodes/
        cp -R ${pkgs.xkeyboard_config}/share/X11/xkb/symbols/{pc,us,inet,srvr_ctrl,group,keypad} $out/share/xkb/symbols/
        cp -R ${pkgs.xkeyboard_config}/share/X11/xkb/types/*              $out/share/xkb/types/
        cp -R ${pkgs.xkeyboard_config}/share/X11/xkb/compat/*             $out/share/xkb/compat/

        mkdir -p $out/share/X11/locale
        cp -R ${pkgs.libx11}/share/X11/locale/en_US.UTF-8 $out/share/X11/locale/
        cp -R ${pkgs.libx11}/share/X11/locale/compose.dir $out/share/X11/locale/
        cp -R ${pkgs.libx11}/share/X11/locale/locale.alias $out/share/X11/locale/
        cp -R ${pkgs.libx11}/share/X11/locale/locale.dir   $out/share/X11/locale/

        mkdir -p $out/share/icons/hicolor/scalable/apps
        mkdir -p $out/share/icons/hicolor/symbolic/apps
        cp ${defaultPkg}/share/icons/hicolor/scalable/apps/ie-r.svg $out/share/icons/hicolor/scalable/apps/
        cp ${defaultPkg}/share/icons/hicolor/symbolic/apps/ie-r-symbolic.svg $out/share/icons/hicolor/symbolic/apps/
        printf '%s\n' \
            '[Icon Theme]'              \
            'Name=hicolor'              \
            'Comment=Hicolor theme'     \
            'Directories=scalable/apps symbolic/apps' \
            '[scalable/apps]'           \
            'Size=48'                   \
            'MinSize=1'                 \
            'MaxSize=512'               \
            'Type=Scalable'             \
            '[symbolic/apps]'           \
            'Size=16'                   \
            'MinSize=16'                \
            'MaxSize=512'               \
            'Type=Scalable'             \
            > $out/share/icons/hicolor/index.theme
        cp ${defaultPkg}/share/applications/ie-r.desktop $out/share/

        mkdir -p $out/fonts
        cp ${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf $out/fonts/
        cp ${../assets/fonts/OFL.txt} $out/fonts/OFL.txt  # explicit name to strip nix-hash prefix
        cp ${../docs/README.portable.linux.md} $out/README.md
        ${copyCommonDocs "$out"}

        patchelf --set-rpath '$ORIGIN/../lib' $out/bin/.ie-r-raw

        # 3. Scripts
        cp ${postinstallScript} $out/postinstall.sh
        chmod +x $out/postinstall.sh

        cp ${portableLauncher} $out/bin/ie-r
        chmod +x $out/bin/ie-r
    '';
  };

  # ── AppImage ──────────────────────────────────────────────────────────
  appimage-runtime = pkgs.fetchurl {
    url  = "https://github.com/AppImage/type2-runtime/releases/download/20251108/runtime-x86_64";
    hash = "sha256-L8qLRDySUQ8Ug6iD9gBhrQm0a5eLJjHIB82HOkfsJg0=";
  };

  appimage = pkgs.stdenv.mkDerivation {
    pname = "ie-r-appimage";
    inherit version;
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.squashfsTools ];

    buildPhase = '' # bash
        mkdir AppDir
        cp -rL ${portable}/* AppDir/
        chmod -R u+w AppDir

        cp ${appRun} AppDir/AppRun
        chmod +x AppDir/AppRun
        cp AppDir/share/ie-r.desktop AppDir/ie-r.desktop
        cp AppDir/share/icons/hicolor/scalable/apps/ie-r.svg AppDir/ie-r.svg
        ln -s ie-r.svg AppDir/.DirIcon

        mksquashfs AppDir appdir.sqfs -root-owned -noappend -comp gzip
    '';

    installPhase = '' # bash
        mkdir -p $out
        cat ${appimage-runtime} appdir.sqfs > $out/ie-r-v${version}-linux-x86_64.AppImage
        chmod +x $out/ie-r-v${version}-linux-x86_64.AppImage
    '';
  };

  # ── App: nix run .#appimage ──────────────────────────────────────────
  # Copies the built AppImage into builds/. AppImages cannot run directly on
  # NixOS (no standard FHS); test on Ubuntu/Fedora after export.
  appimage-export = {
    type = "app";
    meta.description = "Export IE-R AppImage (builds/ie-r-vVERSION-linux-x86_64.AppImage)";
    program = let
      script = pkgs.writeShellScriptBin "appimage-ie-r" '' # bash
          APPIMAGE="ie-r-v${version}-linux-x86_64.AppImage"
          echo -e "\033[1;32m▸ Exporting AppImage to builds/...\033[0m"
          mkdir -p "./builds"
          rm -f "./builds/$APPIMAGE"
          cp "${appimage}/$APPIMAGE" "./builds/$APPIMAGE"
          chmod 755 "./builds/$APPIMAGE"
          echo -e "\033[1;32m✔ Done! ./builds/$APPIMAGE\033[0m"
      '';
    in "${script}/bin/appimage-ie-r";
  };

  # ── App: nix run .#bundle ─────────────────────────────────────────────
  # Wraps .#portable into builds/ie-r-vVERSION-linux-x86_64-portable.zip (built
  # derivation is read-only, so we copy + chmod 755 before zipping).
  bundle = {
    type = "app";
    meta.description = "Build Linux portable bundle (builds/ie-r-vVERSION-linux-x86_64-portable.zip)";
    program = let
      script = pkgs.writeShellScriptBin "bundle-ie-r" '' # bash
          echo -e "\033[1;32m▸ Starting Divine Distribution...\033[0m"

          BUNDLE_PATH=$(nix build .#portable --no-link --print-out-paths)
          if [ -z "$BUNDLE_PATH" ]; then
              echo -e "\033[1;31m✖ Build failed\033[0m"
              exit 1
          fi

          VERSION="v${version}"
          STAGE_DIR="tmp/staging"
          FINAL_DIR="ie-r"
          ZIP_NAME="ie-r-$VERSION-linux-x86_64-portable.zip"

          echo "▸ Extracting and cleaning structure..."
          mkdir -p ../../builds
          rm -rf "$STAGE_DIR" "../../builds/$ZIP_NAME"
          mkdir -p "$STAGE_DIR/$FINAL_DIR"

          cp -rL "$BUNDLE_PATH"/* "$STAGE_DIR/$FINAL_DIR/"

          echo "▸ Leveling permissions (755)..."
          chmod -R 755 "$STAGE_DIR/$FINAL_DIR"

          echo "▸ Archiving to builds/$ZIP_NAME..."
          cd "$STAGE_DIR"
          ${pkgs.zip}/bin/zip -rq "../../builds/$ZIP_NAME" "$FINAL_DIR"
          cd - > /dev/null

          echo -e "\033[1;32m✔ Done! Archive ready: ./builds/$ZIP_NAME\033[0m"
          echo "· Internal structure: $FINAL_DIR/{bin,lib,share}"
      '';
    in "${script}/bin/bundle-ie-r";
  };
in
{
  inherit portable appimage appimage-export bundle appRun portableLauncher postinstallScript;
}
