{
  lib,
  stdenv,
  kdePackages,
  bzip2,
  dbus,
  python3,
}:

# KDE Connect upstream has macOS support (app bundle, launchd-friendly daemon and
# a KStatusNotifierItem indicator), but nixpkgs marks the package Linux-only and
# wires in the Linux-only dependencies unconditionally. Keep the Qt/KF6 stack
# and drop the pieces that only exist for the X11/Wayland and PulseAudio paths.
#
# On top of that, this variant fills qdbuscpp2xml's empty signatures for Qt's
# D-Bus special types (0001), takes the private dbus daemon/config and icon
# location from the wrapped environment (0002, 0003), and patches kdoctools to
# honour XDG_DATA_DIRS because Qt's macOS QStandardPaths ignores it.
let
  # nixpkgs' KF6 packaging wires in Linux desktop dependencies unconditionally.
  # Upstream CMake disables the corresponding backends (and Python bindings) on
  # Apple, so they are not needed in the Darwin closure.
  linuxOnlyDeps = [
    "acl"
    "attr"
    "libdrm"
    "libei"
    "libevdev"
    "libfakekey"
    "modemmanager-qt"
    "plasma-wayland-protocols"
    "polkit-qt-1"
    "pulseaudio-qt"
    "qtwayland"
    "qtwaylandscanner"
    "wayland"
    "wayland-protocols"
  ];

  isUnneeded =
    pkg:
    let
      name = lib.getName pkg;
    in
    builtins.elem name linuxOnlyDeps
    || (lib.isDerivation pkg && (pkg.pname or "") == "pyside6")
    || (lib.isDerivation pkg && lib.hasPrefix "shiboken6" name)
    || (lib.isDerivation pkg && lib.hasPrefix "python3-" name && lib.hasSuffix "-env" name);

  # Nix rejects evaluation when any derivation in the closure has a
  # hostPlatform outside its meta.platforms, and every KF6 package is tagged
  # Linux/FreeBSD-only even though upstream builds them on macOS. Flip only the
  # metadata, which does not change the derivation outputs.
  markMeta =
    pkg:
    if lib.isDerivation pkg && pkg ? meta then
      pkg.overrideAttrs (old: {
        meta = (old.meta or { }) // {
          platforms = (old.meta.platforms or [ ]) ++ lib.platforms.darwin;
          badPlatforms = [ ];
        };
      })
    else
      pkg;

  markDarwin =
    pkg:
    if lib.isDerivation pkg then
      pkg.overrideAttrs (old: {
        buildInputs =
          builtins.map markMeta (
            builtins.filter (dep: dep != null && !isUnneeded dep) (old.buildInputs or [ ])
          )
          ++ lib.optional (lib.getName pkg == "karchive") bzip2;
        nativeBuildInputs = builtins.map markMeta (
          builtins.filter (dep: dep != null && !isUnneeded dep) (old.nativeBuildInputs or [ ])
        );
        propagatedBuildInputs = builtins.map markMeta (
          builtins.filter (dep: dep != null && !isUnneeded dep) (old.propagatedBuildInputs or [ ])
        );
        cmakeFlags =
          (old.cmakeFlags or [ ])
          ++ [ "-DKF_IGNORE_PLATFORM_CHECK=ON" ]
          ++ lib.optional (lib.getName pkg == "kglobalaccel") "-DWITH_X11=OFF";
        patches =
          (old.patches or [ ])
          ++ lib.optional (lib.getName pkg == "kdoctools") ./kdoctools-xdg-data-dirs.patch;
        meta = (old.meta or { }) // {
          platforms = (old.meta.platforms or [ ]) ++ lib.platforms.darwin;
          badPlatforms = [ ];
        };
      })
    else
      pkg;

  kdePackagesPatched =
    if stdenv.hostPlatform.isDarwin then
      kdePackages.overrideScope (_final: prev: lib.mapAttrs (_name: markDarwin) prev)
    else
      kdePackages;

  base = kdePackagesPatched.kdeconnect-kde;
in
base.overrideAttrs (old: {
  pname = "kdeconnect-kde_patched";

  nativeBuildInputs =
    (old.nativeBuildInputs or [ ]) ++ lib.optional stdenv.hostPlatform.isDarwin python3;
  buildInputs = (old.buildInputs or [ ]) ++ lib.optional stdenv.hostPlatform.isDarwin dbus;

  patches =
    (old.patches or [ ])
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      ./0001-fix-dbus-interface-signatures.patch
      ./0002-darwin-dbus-runtime-path.patch
      ./0003-darwin-icon-search-path.patch
    ];

  postPatch =
    (old.postPatch or "")
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      install -m644 ${./fix-dbus-interface-signatures.py} dbusinterfaces/fix-dbus-interface-signatures.py
    '';

  cmakeFlags =
    if stdenv.hostPlatform.isDarwin then
      builtins.filter (flag: !(lib.hasPrefix "-DQtWaylandScanner_EXECUTABLE" flag)) (
        old.cmakeFlags or [ ]
      )
      ++ [ "-DPython3_EXECUTABLE=${python3}/bin/python3" ]
    else
      old.cmakeFlags or [ ];

  qtWrapperArgs =
    (old.qtWrapperArgs or [ ])
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "--prefix DYLD_LIBRARY_PATH : ${lib.makeLibraryPath [ dbus ]}"
      "--prefix PATH : ${lib.makeBinPath [ dbus ]}"
      "--set KDECONNECT_DBUS_DAEMON ${dbus}/bin/dbus-daemon"
      "--set KDECONNECT_DBUS_CONFIG ${dbus}/share/dbus-1/session.conf"
      "--set KDECONNECT_ICON_DIR ${placeholder "out"}/share/kdeconnect-icons"
    ];

  preFixup = (old.preFixup or "") + ''
    if [ -d "$out/Applications/KDE/KDE Connect.app/Contents/Frameworks" ]; then
    # wrapQtAppsHook wraps every executable under Applications/, including the
    # bundle's dylibs, which would make them unloadable by dyld.
      chmod a-x "$out/Applications/KDE/KDE Connect.app/Contents/Frameworks"/*.dylib
    fi
  '';

  postFixup = (old.postFixup or "") + ''
    bundle="$out/Applications/KDE/KDE Connect.app/Contents"
    if [ -d "$bundle" ]; then
      mkdir -p "$out/bin" "$out/lib"
      for lib in "$bundle"/Frameworks/*.dylib; do
        [ -e "$lib" ] || continue
        ln -sfn "../Applications/KDE/KDE Connect.app/Contents/Frameworks/$(basename "$lib")" "$out/lib/$(basename "$lib")"
      done
      for exe in kdeconnect-cli kdeconnectd kdeconnect-handler kdeconnect-sms; do
        ln -sfn "../Applications/KDE/KDE Connect.app/Contents/MacOS/$exe" "$out/bin/$exe"
      done
      ln -sfn "../Applications/KDE/KDE Connect.app/Contents/MacOS/KDE Connect" "$out/bin/kdeconnect-indicator"
    fi
  '';

  meta = (old.meta or { }) // {
    platforms = (old.meta.platforms or [ ]) ++ lib.platforms.darwin;
    mainProgram = "kdeconnect-indicator";
  };
})
