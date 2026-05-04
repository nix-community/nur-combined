# ─────────────────────────────────────────────────────────────────────────────
# nix/windows.nix — Windows cross-compilation: toolchain + apps.
#   • installer — nix run .#windows-installer → ie-r-setup-vVERSION.exe (NSIS)
#   • bundle    — nix run .#windows-bundle    → ie-r-portable-vVERSION.zip
# Windows cross-build: mingw toolchain, shared shell fragments (env / icon
# generation / bundle assembly) and two apps (NSIS installer + portable zip).
# Re-exports mingw bits because flake's devShell needs them too.
# ─────────────────────────────────────────────────────────────────────────────
{ pkgs
, version
, rustToolchain
, copyCommonDocs
}:

let
  # ── Cross-compilation toolchain ──────────────────────────────────────
  mingwCC       = pkgs.pkgsCross.mingwW64.stdenv.cc;
  mingwPthreads = pkgs.pkgsCross.mingwW64.windows.pthreads;
  libclangPath  = "${pkgs.llvmPackages.libclang.lib}/lib";

  # Cargo + linker env for Windows cross-builds. Used by both win-apps below.
  winEnv = '' # bash
      export PATH="${rustToolchain}/bin:${mingwCC}/bin:$PATH"
      export LIBCLANG_PATH="${libclangPath}"
      export CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER="${mingwCC}/bin/x86_64-w64-mingw32-gcc"
      export CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS="-L ${mingwPthreads}/lib"
  '';

  # Generate Windows .ico from SVG (5 sizes) and compile the C tray launcher.
  # Sets $_TRAY_EXE for later steps; trap cleans temps. --raw= embeds the
  # 256px PNG verbatim (Vista format) — pure-BMP 256px breaks windres.
  winArtifacts = '' # bash
      echo "🎨 Generating native icons..."
      _ICO_TMP=$(mktemp -d)
      _TRAY_OBJ=$(mktemp --suffix=.o)
      _TRAY_EXE=$(mktemp --suffix=.exe)
      trap "rm -rf $_ICO_TMP $_TRAY_OBJ $_TRAY_EXE" EXIT
      for SZ in 256 64 48 32 16; do
          ${pkgs.imagemagick}/bin/magick -background none assets/ie-r.svg \
              -resize ''${SZ}x''${SZ} PNG32:$_ICO_TMP/''${SZ}.png
      done
      ${pkgs.icoutils}/bin/icotool -c \
          --raw=$_ICO_TMP/256.png \
          -o assets/ie-r.ico \
          $_ICO_TMP/64.png $_ICO_TMP/48.png \
          $_ICO_TMP/32.png $_ICO_TMP/16.png

      echo "🔧 Compiling C tray launcher..."
      ${mingwCC}/bin/x86_64-w64-mingw32-windres launcher/ie-r-tray.rc --codepage 65001 -O coff -o "$_TRAY_OBJ"
      ${mingwCC}/bin/x86_64-w64-mingw32-gcc -mwindows -O2 -s launcher/ie-r-tray.c "$_TRAY_OBJ" -o "$_TRAY_EXE"
  '';

  # Lay out the bundle dir (exe + tray.exe + fonts + docs). Installer wraps it
  # with NSIS, bundle wraps it with zip. Requires winArtifacts already ran
  # and cargo build for the windows target completed.
  winBundleAssembly = dest: '' # bash
      rm -rf "${dest}"
      mkdir -p "${dest}/fonts"
      cp target/x86_64-pc-windows-gnu/release/ie-r.exe "${dest}/ie-r.exe"
      cp "$_TRAY_EXE"                                   "${dest}/ie-r-tray.exe"
      cp ${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf "${dest}/fonts/JetBrainsMono-Regular.ttf"
      cp ${../assets/fonts/OFL.txt}       "${dest}/fonts/OFL.txt"
      cp ${../README.portable.windows.md} "${dest}/README.md"
      ${copyCommonDocs "${dest}"}
  '';

  # ── Apps ──────────────────────────────────────────────────────────────
  # Each app is a shell script: winArtifacts → winEnv → cargo cross-build
  # → winBundleAssembly → finalize (NSIS / zip).

  # NSIS installer — produces ie-r-setup-vVERSION.exe
  installer = {
    type = "app";
    meta.description = "Build Windows NSIS installer (ie-r-setup-vVERSION.exe)";
    program = let
      script = pkgs.writeShellScriptBin "windows-installer-ie-r" '' # bash
          echo -e "\033[1;32m📦 Building IE-R Windows Installer...\033[0m"
          ${winArtifacts}
          ${winEnv}
          cargo build --release --target x86_64-pc-windows-gnu --bin ie-r || exit 1

          BUNDLE="$PWD/tmp/installer-bundle"
          ${winBundleAssembly "$BUNDLE"}

          ${pkgs.nsis}/bin/makensis \
              -DBUNDLE="$BUNDLE" \
              -DOUTDIR="$PWD" \
              ${../assets/installer.nsi}

          rm -rf "$BUNDLE"
          echo -e "\033[1;32m✅ Done! ie-r-setup-v${version}.exe ready.\033[0m"
      '';
    in "${script}/bin/windows-installer-ie-r";
  };

  # Portable bundle — produces ie-r-portable-vVERSION.zip
  bundle = {
    type = "app";
    meta.description = "Build Windows portable bundle (ie-r-portable-vVERSION.zip)";
    program = let
      script = pkgs.writeShellScriptBin "windows-bundle-ie-r" '' # bash
          echo -e "\033[1;32m🪟 Building IE-R Windows Portable...\033[0m"
          ${winArtifacts}
          ${winEnv}
          cargo build --release --target x86_64-pc-windows-gnu --bin ie-r || exit 1

          VERSION="v${version}"
          STAGE_DIR="tmp/staging-windows"
          FINAL_DIR="ie-r"
          ZIP_NAME="ie-r-portable-$VERSION.zip"

          echo "📦 Assembling bundle..."
          rm -rf "$STAGE_DIR" "$ZIP_NAME"
          ${winBundleAssembly "$STAGE_DIR/$FINAL_DIR"}

          echo "⚡ Archiving to $ZIP_NAME..."
          cd "$STAGE_DIR"
          ${pkgs.zip}/bin/zip -rq "../../$ZIP_NAME" "$FINAL_DIR"
          cd - > /dev/null

          echo -e "\033[1;32m✅ Done! Archive ready: ./$ZIP_NAME\033[0m"
          echo "📂 ie-r/{ie-r.exe, fonts/, LICENSE, README.md, PRIVACY.md, SECURITY.md}"
      '';
    in "${script}/bin/windows-bundle-ie-r";
  };
in
{
  inherit mingwCC mingwPthreads;  # re-exported for flake's devShell
  inherit installer bundle;       # apps wired into apps.${system}
}
