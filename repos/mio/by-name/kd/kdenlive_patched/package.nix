{
  lib,
  stdenv,
  kdePackages,
  bzip2,
  opentimelineio,
}:

# nixpkgs' Kdenlive is packaged for Linux only, and its KF6 dependencies are
# likewise only exercised on Linux/FreeBSD. Upstream has a macOS target, so
# build it against a KF6 scope with the Linux-only desktop inputs removed.
let
  isDarwin = stdenv.hostPlatform.isDarwin;

  linuxOnlyDeps = [
    "acl"
    "attr"
    "kpipewire"
    "kwayland"
    "libappimage"
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

  markMeta =
    pkg:
    if lib.isDerivation pkg && pkg ? meta && !(lib.meta.availableOn stdenv.hostPlatform pkg) then
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
    if isDarwin then
      # Only wrap KDE packages. Re-wrapping the Qt packages would create a
      # second Qtdeclarative in the closure, and QML plugins registered against
      # one copy are invisible to the other engine.
      kdePackages.overrideScope (
        _final: prev:
        let
          packageNames =
            builtins.attrNames (prev.frameworks or { })
            ++ builtins.attrNames (prev.gear or { })
            ++ builtins.attrNames (prev.plasma or { })
            ++ [
              "glaxnimate"
            ];
        in
        lib.genAttrs packageNames (name: markDarwin prev.${name})
      )
    else
      kdePackages;

  # KIO extras, the ffmpeg thumbnailer, and V4L are Linux-only helpers. Kdenlive
  # does its own thumbnails through MLT and captures through AVFoundation on
  # macOS, so none of them are needed in the bundle.
  linuxOnlyBuildInputs = [
    "ffmpegthumbs"
    "kio-extras"
    "v4l-utils"
  ];

  base = kdePackagesPatched.kdenlive;
in
base.overrideAttrs (old: {
  pname = "kdenlive_patched";

  buildInputs =
    if isDarwin then
      builtins.filter (pkg: !builtins.elem (lib.getName pkg) linuxOnlyBuildInputs) (
        old.buildInputs or [ ]
      )
    else
      old.buildInputs or [ ];

  postPatch =
    (old.postPatch or "")
    + lib.optionalString isDarwin ''
      substituteInPlace src/kdenlivesettings.kcfg \
        --replace-fail "/share/mlt-7/profiles" "/share/mlt/profiles"
    '';

  qtWrapperArgs =
    (old.qtWrapperArgs or [ ]) ++ lib.optionals isDarwin [ "--prefix PATH : ${placeholder "out"}/bin" ];

  meta = (old.meta or { }) // {
    platforms = (old.meta.platforms or [ ]) ++ lib.platforms.darwin;
  };

  preFixup =
    (old.preFixup or "")
    + lib.optionalString isDarwin ''
      bundle="$out/bin/kdenlive.app"
      if [ -d "$bundle/Contents/Frameworks" ]; then
        # wrapQtAppsHook wraps every executable under bin/, including bundled
        # dylibs, which would make them unloadable by dyld.
        chmod a-x "$bundle/Contents/Frameworks"/*.dylib
      fi
    '';

  postFixup =
    (old.postFixup or "")
    + lib.optionalString isDarwin ''
      bundle="$out/bin/kdenlive.app"
      exe="$bundle/Contents/MacOS/kdenlive"
      if [ -x "$exe" ]; then
        ln -sfn "../../../share" "$bundle/Contents/Resources"
        for lib in ${opentimelineio}/lib/libopentime*.dylib ${opentimelineio}/lib/libopentimelineio*.dylib; do
          ln -sfn "$lib" "$bundle/Contents/MacOS/$(basename "$lib")"
        done
        ln -sfn "kdenlive.app/Contents/MacOS/kdenlive" "$out/bin/kdenlive"
        mkdir -p "$out/Applications"
        ln -sfn "../bin/kdenlive.app" "$out/Applications/kdenlive.app"
      fi
    '';
})
