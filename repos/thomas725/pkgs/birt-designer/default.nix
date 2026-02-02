{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  patchelfUnstable,
  jdk,
  gtk3, # needed for GSettings schemas + GTK file chooser
}:

let
  libc = stdenv.cc.libc;
  dynamicLinker = stdenv.cc.bintools.dynamicLinker;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "birt-designer";
  version = "4.22.0-202512100727";

  src = fetchurl {
    # https://download.eclipse.org/birt/updates/release/latest/
    # https://www.eclipse.org/downloads/download.php?file=/birt/updates/release/4.22.0/downloads/birt-report-designer-all-in-one-4.22.0-202512100727-linux.gtk.x86_64.tar.gz&mirror_id=1285
    url = "https://mirror.ibcp.fr/pub/eclipse/birt/updates/release/4.22.0/downloads/birt-report-designer-all-in-one-${finalAttrs.version}-linux.gtk.x86_64.tar.gz";
    hash = "sha256-xLs4fKZtFw8xPJqS3oSegonYgRW2XlBuS5/9gQ0HDJk=";
  };

  nativeBuildInputs = [
    makeWrapper
    patchelfUnstable
  ];

  buildInputs = [
    libc
    jdk
  ];

  propagatedBuildInputs = [
    gtk3
  ];

  installPhase = ''
    runHook preInstall

    appdir="$out/share/birt-designer"
    mkdir -p "$appdir"

    # Remove bundled JustJ JRE + feature from the extracted tree first
    echo "Removing bundled JustJ JRE from source tree..."
    rm -rf \
      ./features/org.eclipse.justj.epp_* \
      ./plugins/org.eclipse.justj.openjdk.hotspot.jre.full*

    # Now copy the cleaned tree into the output
    cp -r ./* "$appdir/"

    launcher="$appdir/birt"
    iniFile="$appdir/birt.ini"

    if [ ! -e "$launcher" ]; then
      echo "ERROR: launcher file does not exist: $launcher"
      ls -l "$appdir"
      exit 1
    fi

    chmod +x "$launcher"

    ############################################################################
    # Patch launcher:
    #  - Set the dynamic loader to NixOS' libc loader
    ############################################################################
    echo "Patching launcher with NixOS libc loader..."
    patchelf \
      --set-interpreter "${dynamicLinker}" \
      --set-rpath "${lib.makeLibraryPath [ libc ]}" \
      "$launcher"

    ############################################################################
    # birt.ini cleanup:
    #  - Remove the embedded JustJ JRE (-vm + following line)
    #    so we can use a Nix‑provided JDK instead.
    ############################################################################
    if [ -f "$iniFile" ]; then
      awk '
        BEGIN { skip = 0 }
        /^-vm$/ { skip = 2; next }
        { if (skip > 0) { skip--; next } }
        { print }
      ' "$iniFile" > "$iniFile.tmp"
      mv "$iniFile.tmp" "$iniFile"
    fi

    mkdir -p "$out/bin"

    ############################################################################
    # GTK / GSettings wiring:
    #
    # BIRT’s GTK file chooser crashes on NixOS with:
    #   GLib-GIO-ERROR **: No GSettings schemas are installed on the system
    #
    # This is because the GTK GSettings schemas (org.gtk.Settings.FileChooser)
    # are not visible by default. We:
    #
    #   - Add gtk3 to buildInputs (above), and
    #   - Point GSETTINGS_SCHEMA_DIR and XDG_DATA_DIRS at gtk3’s schema dir.
    #
    # This fixes the file picker crash.
    ############################################################################
    gtk_schema_dir="${gtk3}/share/gsettings-schemas/${gtk3.name}/glib-2.0/schemas"

    ############################################################################
    # SWT / GTK setup:
    #
    # SWT_GTK3=1:
    #   Forces SWT to use the GTK3 backend (more modern, plays nicer with
    #   dark themes on Plasma 6). We deliberately do NOT set GTK_THEME here:
    #   - Decorations and global menu are controlled by KDE Plasma.
    #   - Plasma’s GTK integration is already configured to a dark theme.
    #   - Letting the DE choose the GTK theme keeps decorations + content
    #     visually consistent.
    ############################################################################

    makeWrapper "$launcher" "$out/bin/birt-designer" \
      --set ECLIPSE_HOME "$appdir" \
      --set JAVA_HOME "${jdk}" \
      --prefix PATH : "${jdk}/bin" \
      --set GSETTINGS_SCHEMA_DIR "$gtk_schema_dir" \
      --suffix XDG_DATA_DIRS : "${gtk3}/share" \
      --set SWT_GTK3 "1"

    runHook postInstall
  '';

  meta = {
    description = "Eclipse BIRT Report Designer all-in-one, using NixOS JDK";
    homepage = "https://www.eclipse.org/birt/";
    mainProgram = "birt-designer";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.epl20;
    platforms = [ "x86_64-linux" ];
  };
})
