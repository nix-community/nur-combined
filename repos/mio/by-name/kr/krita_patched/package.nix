{
  lib,
  stdenv,
  krita,
  krita-unwrapped,
  kdePackages,
  bzip2,
  symlinkJoin,
  kseexpr,
}:

# nixpkgs' Krita is packaged for Linux only. Its KDE Frameworks 6 dependencies
# are likewise only exercised on Linux/FreeBSD, so several of them pull in
# Linux-only inputs (ACL/xattr, Wayland, polkit) that cannot build on darwin.
#
# This variant keeps the same source and patches, but points Krita at a KF6
# scope with those Linux-only inputs removed on darwin, and packages the result
# as a normal macOS app bundle. On other platforms it is plain nixpkgs' Krita.
let
  isDarwin = stdenv.hostPlatform.isDarwin;

  # Widening `platforms` is only metadata; it is what lets a framework be used
  # as an input of a darwin build at all.
  forAllPlatforms =
    drv:
    drv.overrideAttrs (old: {
      meta = (old.meta or { }) // {
        platforms = lib.platforms.all;
      };
    });

  # Drop inputs whose name is in `names`, so the framework uses its upstream
  # darwin code paths instead of the Linux-only ones.
  withoutInputs =
    inputs: names: lib.filter (input: !(builtins.elem (lib.getName input) names)) inputs;

  waylandInputs = [
    "plasma-wayland-protocols"
    "qtwayland"
    "wayland"
    "wayland-protocols"
  ];

  # KF6 only lists Linux/FreeBSD in `platforms`, and some frameworks take
  # Linux-only inputs unconditionally.
  kdePackages' = kdePackages.overrideScope (
    self: super:
    let
      frameworks = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = forAllPlatforms super.${name};
        }) (builtins.attrNames super.frameworks)
      );
    in
    frameworks
    // {
      mlt = forAllPlatforms super.mlt;
      poppler = forAllPlatforms super.poppler;
      libkdcraw = forAllPlatforms super.libkdcraw;
      quazip = forAllPlatforms super.quazip;
      kseexpr = forAllPlatforms super.kseexpr;

      kdoctools = forAllPlatforms (
        super.kdoctools.overrideAttrs (old: {
          # macOS' QStandardPaths ignores XDG_DATA_DIRS, so the only catalog
          # lookup left is kdoctools' compiled-in datadir, which is broken in
          # Nix builds (see the patch).
          patches = (old.patches or [ ]) ++ [ ./kdoctools-absolute-datadir.patch ];
        })
      );

      karchive = forAllPlatforms (
        super.karchive.overrideAttrs (old: {
          # Upstream requires BZip2 on every platform; nixpkgs only gets it
          # transitively on Linux.
          buildInputs = (old.buildInputs or [ ]) ++ [ bzip2 ];
        })
      );

      kguiaddons = forAllPlatforms (
        super.kguiaddons.overrideAttrs (old: {
          buildInputs = withoutInputs (old.buildInputs or [ ]) [ "qtwayland" ];
          propagatedBuildInputs = withoutInputs (old.propagatedBuildInputs or [ ]) waylandInputs;
        })
      );

      kwindowsystem = forAllPlatforms (
        super.kwindowsystem.overrideAttrs (old: {
          buildInputs = withoutInputs (old.buildInputs or [ ]) [ "qtwayland" ];
          propagatedBuildInputs = withoutInputs (old.propagatedBuildInputs or [ ]) waylandInputs;
        })
      );

      kio = forAllPlatforms (
        super.kio.overrideAttrs (old: {
          # KIO only uses ACL/xattr and Linux mount support on Linux.
          buildInputs = withoutInputs (old.buildInputs or [ ]) [
            "acl"
            "attr"
            "util-linux"
          ];
        })
      );

      kauth = forAllPlatforms (
        super.kauth.overrideAttrs (old: {
          # KAuth has a native macOS backend; the polkit one is Linux-only.
          propagatedBuildInputs = withoutInputs (old.propagatedBuildInputs or [ ]) [
            "polkit-qt-1"
          ];
        })
      );
    }
  );

  # kseexpr is a top-level nixpkgs package that builds against the stock KF6
  # scope, so point it at the darwin-capable one as well.
  kseexpr' = forAllPlatforms (kseexpr.override { kdePackages = kdePackages'; });

  unwrapped = forAllPlatforms (
    (krita-unwrapped.override {
      kdePackages = kdePackages';
      kseexpr = kseexpr';
    }).overrideAttrs
      (old: {
        # The Finder plugins are built with `xcodebuild archive`, which needs a
        # real Xcode and cannot run in the Nix build, and the Qt6 macOS build
        # needs one header included by its class name (see the patches).
        patches = (old.patches or [ ]) ++ [
          ./krita-skip-macos-integration.patch
          ./krita-qt6-macos-qmutex.patch
        ];
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DKRITA_SKIP_MACOS_INTEGRATION=ON" ];
      })
  );
in
if !isDarwin then
  krita
else
  symlinkJoin {
    pname = "krita_patched";
    inherit (unwrapped) version;

    paths = [ unwrapped ];

    # Krita's own install rules already produce a self-contained bundle at
    # bin/krita.app; expose it under Applications and give it a PATH entry.
    postBuild = ''
      mkdir -p $out/Applications
      ln -s ../bin/krita.app $out/Applications/Krita.app
      ln -s ../Applications/Krita.app/Contents/MacOS/krita $out/bin/krita
    '';

    meta = (unwrapped.meta or { }) // {
      platforms = lib.platforms.darwin;
      mainProgram = "krita";
    };
  }
