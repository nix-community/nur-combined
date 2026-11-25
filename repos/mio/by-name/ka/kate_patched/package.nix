{
  lib,
  stdenv,
  kdePackages,
  bzip2,
}:

# nixpkgs' Kate and its KF6 dependencies are marked Linux/FreeBSD-only, even
# though upstream has a macOS build target with app bundles. Keep the upstream
# source and KDE package definition, but remove the inputs used only by the
# Linux desktop backends and use a KF6 scope with Darwin enabled.
let
  isDarwin = stdenv.hostPlatform.isDarwin;

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
      kdePackages.overrideScope (
        _final: prev:
        let
          packageNames =
            builtins.attrNames (prev.frameworks or { })
            ++ builtins.attrNames (prev.gear or { })
            ++ builtins.attrNames (prev.plasma or { });
        in
        lib.genAttrs packageNames (name: markDarwin prev.${name})
      )
    else
      kdePackages;
in
kdePackagesPatched.kate.overrideAttrs (old: {
  pname = "kate_patched";

  postFixup =
    (old.postFixup or "")
    + lib.optionalString isDarwin ''
      if [ -d "$out/Applications/KDE/kate.app" ]; then
        mkdir -p "$out/bin" "$out/Applications"
        ln -sfn KDE/kate.app "$out/Applications/kate.app"
        ln -sfn KDE/kwrite.app "$out/Applications/kwrite.app"
        ln -sfn ../Applications/KDE/kate.app/Contents/MacOS/kate "$out/bin/kate"
        ln -sfn ../Applications/KDE/kwrite.app/Contents/MacOS/kwrite "$out/bin/kwrite"
      fi
    '';

  meta = (old.meta or { }) // {
    platforms = lib.unique ((old.meta.platforms or [ ]) ++ lib.platforms.darwin);
    mainProgram = "kate";
  };
})
