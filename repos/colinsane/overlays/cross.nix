# tracking:
# - all cross compilation PRs: <https://github.com/NixOS/nixpkgs/labels/6.topic%3A%20cross-compilation>
# - potential idiom to fix cross cargo-inside-meson: <https://github.com/NixOS/nixpkgs/pull/434878>

final: prev:
let
  inherit (prev) lib;
  ## package override helpers
  addInputs = { buildInputs ? [], nativeBuildInputs ? [], depsBuildBuild ? [] }: pkg: pkg.overrideAttrs (upstream: {
    buildInputs = upstream.buildInputs or [] ++ buildInputs;
    nativeBuildInputs = upstream.nativeBuildInputs or [] ++ nativeBuildInputs;
    depsBuildBuild = upstream.depsBuildBuild or [] ++ depsBuildBuild;
  });
  addNativeInputs = nativeBuildInputs: addInputs { inherit nativeBuildInputs; };
  addBuildInputs = buildInputs: addInputs { inherit buildInputs; };
  addDepsBuildBuild = depsBuildBuild: addInputs { inherit depsBuildBuild; };
  mvToNativeInputs = nativeBuildInputs: mvInputs { inherit nativeBuildInputs; };
  mvToBuildInputs = buildInputs: mvInputs { inherit buildInputs; };
  mvToDepsBuildBuild = depsBuildBuild: mvInputs { inherit depsBuildBuild; };
  rmInputs = { buildInputs ? [], depsBuildBuild ? [], nativeBuildInputs ? [] }: pkg: pkg.overrideAttrs (upstream: {
    buildInputs = lib.filter
      (p: !lib.any (rm: p == rm || (p ? name && rm ? name && p.name == rm.name)) buildInputs)
      (upstream.buildInputs or [])
    ;
    depsBuildBuild = lib.filter
      (p: !lib.any (rm: p == rm || (p ? name && rm ? name && p.name == rm.name)) depsBuildBuild)
      (upstream.depsBuildBuild or [])
    ;
    nativeBuildInputs = lib.filter
      (p: !lib.any (rm: p == rm || (p ? name && rm ? name && p.name == rm.name)) nativeBuildInputs)
      (upstream.nativeBuildInputs or [])
    ;
  });
  rmBuildInputs = buildInputs: rmInputs { inherit buildInputs; };
  rmNativeInputs = nativeBuildInputs: rmInputs { inherit nativeBuildInputs; };
  # move items from buildInputs into nativeBuildInputs, or vice-versa.
  # arguments represent the final location of specific inputs.
  mvInputs = { buildInputs ? [], depsBuildBuild ? [], nativeBuildInputs ? [] }: pkg:
    addInputs { inherit buildInputs depsBuildBuild nativeBuildInputs; }
    (
      rmInputs
        {
          buildInputs = depsBuildBuild ++ nativeBuildInputs;
          depsBuildBuild = buildInputs ++ nativeBuildInputs;
          nativeBuildInputs = buildInputs ++ depsBuildBuild;
        }
        pkg
    );

  # build a GI_TYPELIB_PATH out of some packages, useful for build-time tools which otherwise
  # try to load gobject-introspection files for the wrong platform (e.g. `gjspack`).
  typelibPath = pkgs: lib.concatStringsSep ":" (builtins.map (p: "${lib.getLib p}/lib/girepository-1.0") pkgs);

  # `cargo` which adds the correct env vars and `--target` flag when invoked from meson build scripts.
  # use like `foo = prev.foo.override { cargo = crossCargo; }`.
  # the nixpkgs-upstreaming compatible patch looks more like this:
  # - <https://github.com/NixOS/nixpkgs/pull/437748/files>
  # 1. `env.CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;`
  # 2. `postPatch += ...` to patch `rust_target` to `'${stdenv.hostPlatform.rust.cargoShortTarget}'` in meson.build
  crossCargo = let
    inherit (final.pkgsBuildHost) cargo;
    inherit (final.rust.envVars) setEnv rustHostPlatformSpec;
  in (final.pkgsBuildBuild.writeShellScriptBin "cargo" ''
    targetDir=target
    isFlavored=
    outDir=
    profile=

    cargoArgs=("$@")
    nextIsOutDir=
    nextIsProfile=
    nextIsTargetDir=
    for arg in "''${cargoArgs[@]}"; do
      if [[ -n "$nextIsOutDir" ]]; then
        nextIsOutDir=
        outDir="$arg"
      elif [[ -n "$nextIsProfile" ]]; then
        nextIsProfile=
        profile="$arg"
      elif [[ -n "$nextIsTargetDir" ]]; then
        nextIsTargetDir=
        targetDir="$arg"
      elif [[ "$arg" = "build" ]]; then
        isFlavored=1
      elif [[ "$arg" = "--out-dir" ]]; then
        nextIsOutDir=1
      elif [[ "$arg" = "--profile" ]]; then
        nextIsProfile=1
      elif [[ "$arg" = "--release" ]]; then
        profile=release
      elif [[ "$arg" = "--target-dir" ]]; then
        nextIsTargetDir=1
      fi
    done

    extraFlags=()

    # not all subcommands support flavored arguments like `--target`
    if [ -n "$isFlavored" ]; then
      # pass the target triple to cargo so it will cross compile
      # and fix so it places outputs in the same directory as non-cross, see: <https://doc.rust-lang.org/cargo/guide/build-cache.html>
      extraFlags+=(
        --target "${rustHostPlatformSpec}"
        -Z unstable-options
      )
      if [ -z "$outDir" ]; then
        extraFlags+=(
          --out-dir "$targetDir"/''${profile:-debug}
        )
      fi
    fi

    exec ${setEnv} "${lib.getExe cargo}" "$@" "''${extraFlags[@]}"
  '').overrideAttrs {
    inherit (cargo) meta;
  };
in with final; {
  armTrustedFirmwareRK3399 = prev.armTrustedFirmwareRK3399.overrideAttrs (upstream: {
    # 2025-10-06: fixes "arm-none-eabi-ld: /build/source/build/rk3399/release/m0/rk3399m0pmu.elf: error: PHDR segment not covered by LOAD segment".
    # TODO: send this to upstream arm-trusted-firmware, then PR a cherry-pick into nixpkgs
    patches = (upstream.patches or []) ++ [
      (pkgs.fetchpatch2 {
        name = "fix(rockchip): set no-pie option when building m0 elf file";
        url = "https://git.uninsane.org/colin/arm-trusted-firmare/commit/c192c366b8c423a6bf4293573fccfc258e801c87.patch";
        hash = "sha256-oXAJe3pahe3dnYfpmmW8KbSpN8XIzc1Zpm1CvXNrnAY=";
      })
    ];
  });
  # binutils = prev.binutils.override {
  #   # fix that resulting binary files would specify build #!sh as their interpreter.
  #   # dtrx is the primary beneficiary of this.
  #   # this doesn't actually cause mass rebuilding.
  #   # note that this isn't enough to remove all build references:
  #   # - expand-response-params still references build stuff.
  #   shell = runtimeShell;
  # };


  # 2025/08/31: upstreaming is unblocked, but a cleaner solution than this doesn't seem to exist yet
  confy = prev.confy.overrideAttrs (upstream: {
    # meson's `python.find_installation` method somehow just doesn't support cross compilation.
    # - <https://mesonbuild.com/Python-module.html#find_installation>
    # so, build it to target build python, then patch in the host python
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      python3.pythonOnBuildForHost
    ];
    postFixup = ''
      substituteInPlace $out/bin/.confy-wrapped --replace-fail ${python3.pythonOnBuildForHost} ${python3.withPackages (
        ps: with ps; [
          icalendar
          pygobject3
        ]
      )}
    '';
  });

  # 2025/07/27: upstreaming is unblocked
  # dtrx = prev.dtrx.override {
  #   # `binutils` is the nix wrapper, which reads nix-related env vars
  #   # before passing on to e.g. `ld`.
  #   # dtrx probably only needs `ar` at runtime, not even `ld`.
  #   # this isn't required to fix the _build_, nor even runtime behavior (probably); it's a cleanliness fix (fewer build packages in runtime closure)
  #   binutils = binutils-unwrapped;
  # };

  # envelope = prev.envelope.override {
  #   cargo = crossCargo;
  # };

  # 2025/08/31: upstreaming is blocked on mailutils -> gss -> shishi
  # emacs = prev.emacs.override {
  #   nativeComp = false;  # will be renamed to `withNativeCompilation` in future
  #   # future: we can specify 'action-if-cross-compiling' to actually invoke the test programs:
  #   # <https://www.gnu.org/software/autoconf/manual/autoconf-2.63/html_node/Runtime.html>
  # };

  # 2025/08/31: upstreaming is unblocked
  # firejail = prev.firejail.overrideAttrs (upstream: {
  #   # firejail executes its build outputs to produce the default filter list.
  #   # i think we *could* copy the default filters from pkgsBuildBuild, but that doesn't seem future proof
  #   # for any (future) arch-specific filtering
  #   postPatch = (upstream.postPatch or "") + (let
  #     emulator = stdenv.hostPlatform.emulator buildPackages;
  #   in lib.optionalString (!prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform) ''
  #     substituteInPlace Makefile \
  #       --replace-fail '	src/fseccomp/fseccomp' '	${emulator} src/fseccomp/fseccomp' \
  #       --replace-fail '	src/fsec-optimize/fsec-optimize' '	${emulator} src/fsec-optimize/fsec-optimize'
  #   '');
  # });

  # 2025/08/31: upstreaming is unblocked
  # flare-signal = prev.flare-signal.overrideAttrs (upstream: {
  #    env = let
  #      inherit buildPackages stdenv rust;
  #      ccForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc";
  #      cxxForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}c++";
  #      ccForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";
  #      cxxForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++";
  #      rustBuildPlatform = stdenv.buildPlatform.rust.rustcTarget;
  #      rustTargetPlatform = stdenv.hostPlatform.rust.rustcTarget;
  #      rustTargetPlatformSpec = stdenv.hostPlatform.rust.rustcTargetSpec;
  #    in {
  #      # taken from <pkgs/build-support/rust/hooks/default.nix>
  #      # fixes "cargo:warning=aarch64-unknown-linux-gnu-gcc: error: unrecognized command-line option ‘-m64’"
  #      # XXX: these aren't necessarily valid environment variables: the referenced nix file is more clever to get them to work.
  #      "CC_${rustBuildPlatform}" = "${ccForBuild}";
  #      "CXX_${rustBuildPlatform}" = "${cxxForBuild}";
  #      "CC_${rustTargetPlatform}" = "${ccForHost}";
  #      "CXX_${rustTargetPlatform}" = "${cxxForHost}";
  #    };
  # });

  # 2025/08/26: upstreaming is unblocked, out for PR: <https://github.com/NixOS/nixpkgs/pull/437038>
  # fractal = prev.fractal.override {
  #   cargo = crossCargo;
  # };

  # 2025/07/27: upstreaming is blocked on gnome-shell
  # fixes: "gdbus-codegen not found or executable"
  # gnome-session = mvToNativeInputs [ glib ] super.gnome-session;

  # 2025/08/31: upstreaming is blocked on evolution-data-server -> gnome-online-accounts -> gvfs -> ... -> ruby
  # gnome-shell = super.gnome-shell.overrideAttrs (orig: {
  #   # fixes "meson.build:128:0: ERROR: Program 'gjs' not found or not executable"
  #   # does not fix "_giscanner.cpython-310-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory"  (python import failure)
  #   nativeBuildInputs = orig.nativeBuildInputs ++ [ gjs gobject-introspection ];
  #   # try to reduce gobject-introspection/shew dependencies
  #   mesonFlags = [
  #     "-Dextensions_app=false"
  #     "-Dextensions_tool=false"
  #     "-Dman=false"
  #   ];
  #   # fixes "gvc| Build-time dependency gobject-introspection-1.0 found: NO"
  #   # inspired by gupnp_1_6
  #   # outputs = [ "out" "dev" ]
  #   #   ++ lib.optionals (prev.stdenv.buildPlatform == prev.stdenv.hostPlatform) [ "devdoc" ];
  #   # mesonFlags = [
  #   #   "-Dgtk_doc=${lib.boolToString (prev.stdenv.buildPlatform == prev.stdenv.hostPlatform)}"
  #   # ];
  # });
  # gnome-shell = super.gnome-shell.overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     gjs  # fixes "meson.build:128:0: ERROR: Program 'gjs' not found or not executable"
  #   ];
  # });

  # 2025/07/27: upstreaming is unblocked
  # # gnustep is going to need a *lot* of work/domain-specific knowledge to truly cross-compile,
  # gnustep-base = prev.gnustep-base.overrideAttrs (upstream: {
  #   # fixes: "checking FFI library usage... ./configure: line 11028: pkg-config: command not found"
  #   # nixpkgs has this in nativeBuildInputs... but that's failing when we partially emulate things.
  #   buildInputs = (upstream.buildInputs or []) ++ [ prev.pkg-config ];
  # });

  # hyprland = prev.hyprland.override {
  #   # 2025/07/18: NOT FOR UPSTREAM.
  #   # hyprland uses gcc15Stdenv, with mold patch -> doesn't apply when cross compiling.
  #   # the package fails even after fixing stdenv, though.
  #   # stdenv = gcc14Stdenv;
  #   # stdenv = prev.stdenv;
  # };
  # only `nwg-panel` uses hyprland; `null`ing it seems to Just Work.
  hyprland = null;

  # 2025/07/27: blocked on hyprutils, hyprlang, hyprland-qt.
  # used by hyprland (which is an indirect dep of waybar, nwg-panel, etc),
  # which it shells out to at runtime (and hence, not ever used by me).
  hyprland-qtutils = null;

  # 2025/07/27: upstreaming is blocked on java-service-wrapper
  # "setup: line 1595: ant: command not found"
  # i2p = mvToNativeInputs [ ant gettext ] prev.i2p;

  # 2024/08/12: upstreaming is blocked on lua, lpeg, pandoc, unicode-collation, etc
  # iotas = prev.iotas.overrideAttrs (_: {
  #   # error: "<iotas> is not allowed to refer to the following paths: <build python>"
  #   # disallowedReferences = [];
  #   postPatch = ''
  #     # @PYTHON@ becomes the build python, but this file isn't executable anyway so shouldn't have a shebang
  #     substituteInPlace iotas/const.py.in \
  #       --replace-fail '#!@PYTHON@' ""
  #   '';
  # });

  # jellyfin-media-player = mvToBuildInputs
  #   [ libsForQt5.wrapQtAppsHook ]  # this shouldn't be: but otherwise we get mixed qtbase deps
  #   (prev.jellyfin-media-player.overrideAttrs (upstream: {
  #     meta = upstream.meta // {
  #       platforms = upstream.meta.platforms ++ [
  #         "aarch64-linux"
  #       ];
  #     };
  #   }));
  # jellyfin-media-player-qt6 = prev.jellyfin-media-player-qt6.overrideAttrs (upstream: {
  #   # nativeBuildInputs => result targets x86.
  #   # buildInputs => result targets correct platform, but doesn't wrap the runtime deps
  #   # TODO: fix the hook in qt6 itself?
  #   depsHostHost = upstream.depsHostHost or [] ++ [ qt6.wrapQtAppsHook ];
  #   nativeBuildInputs = lib.remove [ qt6.wrapQtAppsHook ] upstream.nativeBuildInputs;
  # });

  # 2025/09/06: upstreaming is blocked on xdp-tools; out for PR: <https://github.com/NixOS/nixpkgs/pull/442827>
  # knot-dns = addNativeInputs [ buildPackages.protobufc ] prev.knot-dns;

  # lemoa = prev.lemoa.override { cargo = crossCargo; };

  libglycin = prev.libglycin.override {
    cargo = crossCargo;
  };

  # libsForQt5 = prev.libsForQt5.overrideScope (self: super: {
  #   # 2025/07/27: upstreaming is blocked on qtsvg
  #   phonon = super.phonon.overrideAttrs (orig: {
  #     # fixes "ECM (required version >= 5.60), Extra CMake Modules"
  #     buildInputs = orig.buildInputs ++ [ extra-cmake-modules ];
  #   });
  # });
  # libsForQt5 = prev.libsForQt5.overrideScope (self: super: {
  #   # emulate all the qt5 packages, but rework `libsForQt5.callPackage` and `mkDerivation`
  #   # to use non-emulated stdenv by default.
  #   mkDerivation = self.mkDerivationWith stdenv.mkDerivation;
  #   callPackage = self.newScope { inherit (self) qtCompatVersion qtModule srcs; inherit stdenv; };
  # });

  # 2024/11/19: upstreaming is unblocked
  mepo = (prev.mepo.override {
    # nixpkgs mepo correctly puts `zig_0_13.hook` in nativeBuildInputs,
    # but for some reason that tries to use the host zig instead of the build zig.
    zig_0_14 = buildPackages.zig_0_14;
  }).overrideAttrs (upstream: {
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      # zig hardcodes the /lib/ld-linux.so interpreter which breaks nix dynamic linking & dep tracking.
      # this shouldn't have to be buildPackages.autoPatchelfHook...
      # but without specifying `buildPackages` the host coreutils ends up on the builder's path and breaks things
      buildPackages.autoPatchelfHook
    ];
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace src/sdlshim.zig \
        --replace-fail 'cInclude("SDL2/SDL2_gfxPrimitives.h")' 'cInclude("SDL2_gfxPrimitives.h")' \
        --replace-fail 'cInclude("SDL2/SDL_image.h")' 'cInclude("SDL_image.h")' \
        --replace-fail 'cInclude("SDL2/SDL_ttf.h")' 'cInclude("SDL_ttf.h")'
    '';
    # fix the self-documenting build of share/doc/mepo/documentation.md
    postInstall = lib.replaceStrings
      [ "$out/bin/mepo " ]
      [ "${stdenv.hostPlatform.emulator buildPackages} $out/bin/mepo " ]
      ''
        autoPatchelf "$out"
        ${upstream.postInstall}
      '';
    # optional `zig build` debugging flags:
    # - --verbose
    # - --verbose-cimport
    # - --help
    zigBuildFlags = [ "-Dtarget=aarch64-linux-gnu" ];
  });

  # fixes: "ar: command not found"
  # `ar` is provided by bintools
  # 2025/07/27: upstreaming is unblocked by deps; but turns out to not be this simple
  # ncftp = addNativeInputs [ bintools ] prev.ncftp;

  # fixes "properties/gresource.xml: Permission denied"
  #   - by providing glib-compile-resources
  # 2025/07/27: upstreaming is blocked on gst-plugins-good, qtkeychain, qtmultimedia, qtquick3d, qt-jdenticon
  # nheko = (prev.nheko.override {
  #   gst_all_1 = gst_all_1 // {
  #     # don't build gst-plugins-good with "qt5 support"
  #     # alternative build fix is to remove `qtbase` from nativeBuildInputs:
  #     # - that avoids the mixd qt5 deps, but forces a rebuild of gst-plugins-good and +20MB to closure
  #     gst-plugins-good.override = attrs: gst_all_1.gst-plugins-good.override (builtins.removeAttrs attrs [ "qt5Support" ]);
  #   };
  # }).overrideAttrs (orig: {
  #   # fixes "fatal error: lmdb++.h: No such file or directory
  #   buildInputs = orig.buildInputs ++ [ lmdbxx ];
  # });
  # 2025/07/27: upstreaming blocked on emacs, ruby (via vim-gems)
  # - previous upstreaming attempt: <https://github.com/NixOS/nixpkgs/pull/225111/files>
  # notmuch = prev.notmuch.overrideAttrs (upstream: {
  #   # fixes "Error: The dependencies of notmuch could not be satisfied"  (xapian, gmime, glib, talloc)
  #   # when cross-compiling, we only have a triple-prefixed pkg-config which notmuch's configure script doesn't know how to find.
  #   # so just replace these with the nix-supplied env-var which resolves to the relevant pkg-config.
  #   postPatch = upstream.postPatch or "" + ''
  #     sed -i 's/pkg-config/\$PKG_CONFIG/g' configure
  #   '';
  #   XAPIAN_CONFIG = buildPackages.writeShellScript "xapian-config" ''
  #     exec ${lib.getBin xapian}/bin/xapian-config $@
  #   '';
  #   # depsBuildBuild = [ gnupg ];
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     gnupg  # nixpkgs specifies gpg as a buildInput instead of a nativeBuildInput
  #     perl  # used to build manpages
  #     # pythonPackages.python
  #     # shared-mime-info
  #   ];
  #   buildInputs = [
  #     xapian gmime3 talloc zlib  # dependencies described in INSTALL
  #     # perl
  #     # pythonPackages.python
  #     ruby  # notmuch links against ruby.so
  #   ];
  #   # buildInputs =
  #   #   (lib.remove
  #   #     perl
  #   #     (lib.remove
  #   #       gmime
  #   #       (lib.remove gnupg upstream.buildInputs)
  #   #     )
  #   #   ) ++ [ gmime ];
  # });
  # notmuch = prev.notmuch.overrideAttrs (upstream: {
  #   # fixes "Error: The dependencies of notmuch could not be satisfied"  (xapian, gmime, glib, talloc)
  #   # when cross-compiling, we only have a triple-prefixed pkg-config which notmuch's configure script doesn't know how to find.
  #   # so just replace these with the nix-supplied env-var which resolves to the relevant pkg-config.
  #   postPatch = upstream.postPatch or "" + ''
  #     sed -i 's/pkg-config/\$PKG_CONFIG/g' configure
  #     sed -i 's: gpg : ${buildPackages.gnupg}/bin/gpg :' configure
  #   '';
  #   XAPIAN_CONFIG = buildPackages.writeShellScript "xapian-config" ''
  #     exec ${lib.getBin xapian}/bin/xapian-config $@
  #   '';
  #   # depsBuildBuild = upstream.depsBuildBuild or [] ++ [
  #   #   buildPackages.stdenv.cc
  #   # ];
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     # gnupg
  #     perl
  #   ];
  #   # buildInputs = lib.remove gnupg upstream.buildInputs;
  # });

  # 2025/08/31: upstreaming is unblocked, but most of this belongs in _oils_ repo
  oils-for-unix = prev.oils-for-unix.overrideAttrs (upstream: {
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace _build/oils.sh \
        --replace-fail ' strip ' ' ${stdenv.cc.targetPrefix}strip '
    '';

    buildPhase = lib.replaceStrings
      [ "_build/oils.sh" ]
      [ "_build/oils.sh --cxx ${stdenv.cc.targetPrefix}c++" ]
      upstream.buildPhase
    ;

    installPhase = lib.replaceStrings
      [ "./install" ]
      [ "./install _bin/${stdenv.cc.targetPrefix}c++-opt-sh/oils-for-unix.stripped" ]
      upstream.installPhase
    ;

    configureFlags = upstream.configureFlags ++ [
      "--cxx-for-configure=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++"
    ];
  });

  # 2025/08/31: upstreaming is unblocked; out for review: <https://github.com/NixOS/nixpkgs/pull/437704>
  # papers = prev.papers.override {
  #   cargo = crossCargo;
  # };

  # 2025/07/27: upstreaming is blocked on gnome-session (itself blocked on gnome-shell)
  # phosh = prev.phosh.overrideAttrs (upstream: {
  #   buildInputs = upstream.buildInputs ++ [
  #     libadwaita  # "plugins/meson.build:41:2: ERROR: Dependency "libadwaita-1" not found, tried pkgconfig"
  #   ];
  #   mesonFlags = upstream.mesonFlags ++ [
  #     "-Dphoc_tests=disabled"  # "tests/meson.build:20:0: ERROR: Program 'phoc' not found or not executable"
  #   ];
  #   # postPatch = upstream.postPatch or "" + ''
  #   #   sed -i 's:gio_querymodules = :gio_querymodules = "${buildPackages.glib.dev}/bin/gio-querymodules" if True else :' build-aux/post_install.py
  #   # '';
  # });
  # 2024/05/31: upstreaming is blocked on qtsvg, libgweather, webp-pixbuf-loader, appstream, gnome-color-manager, apache-httpd, ibus, freerdp (mostly gnome-shell i think)
  # phosh-mobile-settings = mvInputs {
  #   # fixes "meson.build:26:0: ERROR: Dependency "phosh-plugins" not found, tried pkgconfig"
  #   # phosh is used only for its plugins; these are specified as a runtime dep in src.
  #   # it's correct for them to be runtime dep: src/ms-lockscreen-panel.c loads stuff from
  #   buildInputs = [ phosh ];
  #   nativeBuildInputs = [
  #     gettext  # fixes "data/meson.build:1:0: ERROR: Program 'msgfmt' not found or not executable"
  #     wayland-scanner  # fixes "protocols/meson.build:7:0: ERROR: Program 'wayland-scanner' not found or not executable"
  #     glib  # fixes "src/meson.build:1:0: ERROR: Program 'glib-mkenums mkenums' not found or not executable"
  #     desktop-file-utils  # fixes "meson.build:116:8: ERROR: Program 'update-desktop-database' not found or not executable"
  #   ];
  # } prev.phosh-mobile-settings;

  # pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
  #   (pyself: pysuper: {
  #     # 2025/07/23: upstreaming is unblocked, but solution is untested.
  #     # the references here are a result of the cython build process.
  #     # cython is using the #include files from the build python, and leaving those paths in code comments.
  #     # better solution is to get cython to use the HOST python??
  #     #
  #     # python3Packages.srsly is required by `newelle` program.
  #     srsly = pysuper.srsly.overridePythonAttrs (upstream: {
  #       nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
  #         removeReferencesTo
  #       ];
  #       postFixup = (upstream.postFixup or "") + ''
  #         remove-references-to -t ${pyself.python.pythonOnBuildForHost} $out/${pyself.python.sitePackages}/srsly/msgpack/*.cpp
  #       '';
  #     });
  #   })
  # ];

  # qt6 = prev.qt6.overrideScope (self: super: {
  #   # qtbase = super.qtbase.overrideAttrs (upstream: {
  #   #   # cmakeFlags = upstream.cmakeFlags ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
  #   #   cmakeFlags = upstream.cmakeFlags ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
  #   #     # "-DCMAKE_CROSSCOMPILING=True" # fails to solve QT_HOST_PATH error
  #   #     "-DQT_HOST_PATH=${buildPackages.qt6.full}"
  #   #   ];
  #   # });
  #   # qtModule = args: (super.qtModule args).overrideAttrs (upstream: {
  #   #   # the nixpkgs comment about libexec seems to be outdated:
  #   #   # it's just that cross-compiled syncqt.pl doesn't get its #!/usr/bin/env shebang replaced.
  #   #   preConfigure = lib.replaceStrings
  #   #     ["${lib.getDev self.qtbase}/libexec/syncqt.pl"]
  #   #     ["perl ${lib.getDev self.qtbase}/libexec/syncqt.pl"]
  #   #     upstream.preConfigure;
  #   # });
  #   # # qtwayland = super.qtwayland.overrideAttrs (upstream: {
  #   # #   preConfigure = "fixQtBuiltinPaths . '*.pr?'";
  #   # # });
  #   # # qtwayland = super.qtwayland.override {
  #   # #   inherit (self) qtbase;
  #   # # };

  #   qtwebengine = super.qtwebengine.overrideAttrs (upstream: {
  #     # depsBuildBuild = upstream.depsBuildBuild or [] ++ [ pkg-config ];
  #     # XXX: qt seems to use its own terminology for "host" and "target":
  #     # - <https://www.qt.io/blog/qt6-development-hosts-and-targets>
  #     # - "host" = machine invoking the compiler
  #     # - "target" = machine on which the resulting qtwebengine.so binaries will run
  #     # XXX: NIX_CFLAGS_COMPILE_<machine> is how we get the `-isystem <dir>` flags.
  #     #      probably we shouldn't blindly copy these from host machine to build machine,
  #     #      as the headers could reasonably make different assumptions.
  #     preConfigure = upstream.preConfigure + ''
  #       # export PKG_CONFIG_HOST="$PKG_CONFIG"
  #       export PKG_CONFIG_HOST="$PKG_CONFIG_FOR_BUILD"
  #       # expose -isystem <zlib> to x86 builds
  #       export NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu="$NIX_CFLAGS_COMPILE"
  #       export NIX_LDFLAGS_x86_64_unknown_linux_gnu="-L${buildPackages.zlib}/lib"
  #     '';
  #     patches = upstream.patches or [] ++ [
  #       # ./qtwebengine-host-pkg-config.patch
  #       # alternatively, look at dlopenBuildInputs
  #       ./qtwebengine-host-cc.patch
  #     ];
  #     # patch the qt pkg-config script to show us more debug info
  #     postPatch = upstream.postPatch or "" + ''
  #       sed -i s/options.debug/True/g src/3rdparty/chromium/build/config/linux/pkg-config.py
  #     '';
  #     nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #       bintools-unwrapped  # for readelf
  #       buildPackages.cups  # for cups-config
  #       buildPackages.fontconfig
  #       buildPackages.glib
  #       buildPackages.harfbuzz
  #       buildPackages.icu
  #       buildPackages.libjpeg
  #       buildPackages.libpng
  #       buildPackages.libwebp
  #       buildPackages.nss
  #       # gcc-unwrapped.libgcc  # for libgcc_s.so
  #       buildPackages.zlib
  #     ];
  #     depsBuildBuild = upstream.depsBuildBuild or [] ++ [ pkg-config ];
  #     # buildInputs = upstream.buildInputs ++ [
  #     #   gcc-unwrapped.libgcc  # for libgcc_s.so. this gets loaded during build, suggesting i surely messed something up
  #     # ];
  #     # buildInputs = upstream.buildInputs ++ [
  #     #   gcc-unwrapped.libgcc
  #     # ];
  #     # nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     #   icu
  #     # ];
  #     # buildInputs = upstream.buildInputs ++ [
  #     #   icu
  #     # ];
  #     # env.NIX_DEBUG="1";
  #     # env.NIX_DEBUG="7";
  #     # cmakeFlags = lib.remove "-DQT_FEATURE_webengine_system_icu=ON" upstream.cmakeFlags;
  #     cmakeFlags = upstream.cmakeFlags ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
  #       # "--host-cc=${buildPackages.stdenv.cc}/bin/cc"
  #       # "--host-cxx=${buildPackages.stdenv.cc}/bin/c++"
  #       # these are my own vars, used by my own patch
  #       "-DCMAKE_HOST_C_COMPILER=${buildPackages.stdenv.cc}/bin/gcc"
  #       "-DCMAKE_HOST_CXX_COMPILER=${buildPackages.stdenv.cc}/bin/g++"
  #       "-DCMAKE_HOST_AR=${buildPackages.stdenv.cc}/bin/ar"
  #       "-DCMAKE_HOST_NM=${buildPackages.stdenv.cc}/bin/nm"
  #     ];
  #   });
  # });

  # signal-desktop = prev.signal-desktop.overrideAttrs (upstream: {
  #   # 2025/07/06: upstreaming is blocked on:
  #   # - <https://github.com/NixOS/nixpkgs/pull/422938>
  #   # - <https://github.com/NixOS/nixpkgs/pull/423089>
  #   # - ibusMinimal (fixed in staging)
  #   # see nixpkgs branch `pr-npm-patch-shebangs` (abandoned):
  #   # pkgs/build-support/node/build-npm-package/hooks/npm-config-hook.sh (or pnpm.configHook)
  #   # calls patchShebangs on the node_modules/ directory, which causes us to take a ref to the build nodejs, needlessly.
  #   # postUnpack = ''
  #   #   eval real_"$(declare -f patchShebangs)"
  #   #   patchShebangs() {
  #   #     if [[ -z "''${dontMockPatchShebangs-}" ]]; then
  #   #       echo "MOCKING patchShebangs"
  #   #     else
  #   #       echo "NOT MOCKING patchShebangs"
  #   #       real_patchShebangs "$@"
  #   #     fi
  #   #   }
  #   # '';
  #   # # only mock this for unpack/config phase; fixup can patchShebangsAuto
  #   # preBuild = ''
  #   #   export dontMockPatchShebangs=1
  #   # '';
  #   buildPhase = lib.replaceStrings
  #     # ["-c.electronDist"]
  #     # ["${lib.optionalString stdenv.hostPlatform.isAarch64 "--arm64 "}-c.electronDist"]
  #       # ["--config.linux.target.arch=arm64 -c.electronDist"]
  #     ["--dir"]
  #     # [''"--config.$npm_config_platform.target.target=dir" "--config.$npm_config_platform.target.arch=$npm_config_arch"'']
  #     ["--linux dir:arm64"]
  #     # ["--dir:arm64"]
  #     # ["--dir --arm64"]
  #     upstream.buildPhase
  #   ;
  #   # preBuild = ''
  #   #   export ELECTRON_ARCH=$npm_config_arch
  #   # '';
  #   # # fixup the app.asar to not hold a ref to any build-time tools
  #   # nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #   #   final.asar
  #   #   final.removeReferencesTo
  #   # ];
  #   # preFixup = (upstream.preFixup or "") + ''
  #   #   # the asar includes both runtime and build-time files (e.g. build scripts):
  #   #   # it's impractical to properly split out the node files which aren't needed at runtime,
  #   #   # but we can patch them to not refer to the build tools to reduce closure size and to make potential packaging/cross-compilation bugs more obvious.
  #   #   asar extract $out/share/signal-desktop/app.asar asar-unpacked
  #   #   rm $out/share/signal-desktop/app.asar
  #   #   find asar-unpacked/node_modules -type f -executable -exec remove-references-to -t ${buildPackages.nodejs_22} -t ${buildPackages.bashNonInteractive} '{}' \;
  #   #   asar pack asar-unpacked $out/share/signal-desktop/app.asar
  #   # '';
  # });

  # 2025/08/26: upstreaming is unblocked; implemented on desko `pr-snapshot-cross` branch
  # snapshot = prev.snapshot.override {
  #   # fixes "error: linker `cc` not found"
  #   cargo = crossCargo;
  # };

  # 2025/08/26: upstreaming is unblocked; patched on desko branch `pr-spot-cross`
  # spot = prev.spot.override {
  #   cargo = crossCargo;
  # };

  # 2025/07/27: upstreaming is unblocked
  # squeekboard = prev.squeekboard.overrideAttrs (upstream: {
  #   # fixes: "meson.build:1:0: ERROR: 'rust' compiler binary not defined in cross or native file"
  #   # new error: "meson.build:1:0: ERROR: Rust compiler rustc --target aarch64-unknown-linux-gnu -C linker=aarch64-unknown-linux-gnu-gcc can not compile programs."
  #   # NB(2023/03/04): upstream nixpkgs has a new squeekboard that's closer to cross-compiling; use that
  #   # NB(2023/08/24): this emulates the entire rust build process
  #   mesonFlags =
  #     let
  #       # ERROR: 'rust' compiler binary not defined in cross or native file
  #       crossFile = writeText "cross-file.conf" ''
  #         [binaries]
  #         rust = [ 'rustc', '--target', '${stdenv.hostPlatform.rust.rustcTargetSpec}' ]
  #       '';
  #     in
  #       # upstream.mesonFlags or [] ++
  #       [
  #         "-Dtests=false"
  #         "-Dnewer=true"
  #         "-Donline=false"
  #       ]
  #       ++ lib.optional
  #         (stdenv.hostPlatform != stdenv.buildPlatform)
  #         "--cross-file=${crossFile}"
  #       ;

  #   # cargoDeps = null;
  #   # cargoVendorDir = "vendor";

  #   # depsBuildBuild = (upstream.depsBuildBuild or []) ++ [
  #   #   pkg-config
  #   # ];
  #   # this is identical to upstream, but somehow build fails if i remove it??
  #   nativeBuildInputs = [
  #     meson
  #     ninja
  #     pkg-config
  #     glib
  #     wayland
  #     rustPlatform.cargoSetupHook
  #     cargo
  #     rustc
  #   ];
  # });

  # 2025/08/31: upstreaming blocked on gvfs -> udisks -> libblockdev -> {thin-provisioning-tools,libndctl -> ... -> ruby}
  swaynotificationcenter = mvToNativeInputs [ buildPackages.wayland-scanner ] prev.swaynotificationcenter;

  # 2025/07/27: upstreaming is unblocked
  tangram = prev.tangram.overrideAttrs (upstream: {
    # gsjpack has a shebang for the host gjs. patchShebangs --build doesn't fix that: just manually specify the build gjs.
    # the proper way to patch this for nixpkgs is:
    # 1. split `gjspack` into its own package.
    #   - right now it's a submodule of all of sonnyp's repos,
    #     and each nix package re-builds it (forge-sparks, junction, tangram).
    # 2. wrap `gjspack` the same way i did blueprint-compiler, and put it in nativeBuildInputs
    postPatch = let
      gjspack' = buildPackages.writeShellScriptBin "gjspack" ''
        export GI_TYPELIB_PATH=${typelibPath [ buildPackages.glib ]}:$GI_TYPELIB_PATH
        exec ${buildPackages.gjs}/bin/gjs $@
      '';
    in (upstream.postPatch or "") + ''
      substituteInPlace src/meson.build \
        --replace-fail "find_program('gjs').full_path()" "'${gjs}/bin/gjs'" \
        --replace-fail "gjspack,"  "'${gjspack'}/bin/gjspack', '-m', gjspack,"
    '';
    # postPatch = (upstream.postPatch or "") + ''
    #   substituteInPlace src/meson.build \
    #     --replace-fail "find_program('gjs').full_path()" "'${gjs}/bin/gjs'" \
    #     --replace-fail "gjspack," "'env', 'GI_TYPELIB_PATH=${typelibPath [
    #       buildPackages.glib
    #     ]}', '${buildPackages.gjs}/bin/gjs', '-m', gjspack,"
    # '';
  });

  # fixes: "ar: command not found"
  # `ar` is provided by bintools
  # 2025/04/04: upstreaming is blocked on gnustep-base cross compilation
  # unar = addNativeInputs [ bintools ] prev.unar;

  # unixODBCDrivers = prev.unixODBCDrivers // {
  #   # TODO: should this package be deduped with toplevel psqlodbc in upstream nixpkgs?
  #   # N.B.: psqlodbc is a WAY MORE DIFFICULT PACKAGE TO GET CROSS COMPILING
  #   # - even after fixing configurePhase to actually find all its shit, there are actual C compilation errors like
  #   #   > misc.h:23:17: error: conflicting types for 'strlcat';
  #   psql = prev.unixODBCDrivers.psql.overrideAttrs (_upstream: {
  #     # XXX: these are both available as configureFlags, if we prefer that (we probably do, so as to make them available only during specific parts of the build).
  #     ODBC_CONFIG = buildPackages.writeShellScript "odbc_config" ''
  #       exec ${stdenv.hostPlatform.emulator buildPackages} ${unixODBC}/bin/odbc_config $@
  #     '';
  #     PG_CONFIG = buildPackages.writeShellScript "pg_config" ''
  #       exec ${stdenv.hostPlatform.emulator buildPackages} ${postgresql}/bin/pg_config $@
  #     '';
  #   });
  # };

  # 2025/08/26: upstreaming is unblocked; implemented on desko branch `pr-video-trimmer-cross`
  # video-trimmer = prev.video-trimmer.override {
  #   cargo = crossCargo;
  # };

  # 2025/01/13: upstreaming is blocked on arrow-cpp, python-pyarrow, python-contourpy, python-matplotlib, python-h5py, python-pandas, google-cloud-cpp
  # visidata = prev.visidata.override {
  #   # hdf5 / h5py don't cross-compile, but i don't use that file format anyway.
  #   # setting this to null means visidata will work as normal but not be able to load hdf files.
  #   h5py = null;
  # };
  # 2025/07/27: upstreaming is blocked on qtsvg, qtx11extras
  # vlc = prev.vlc.overrideAttrs (orig: {
  #   # fixes: "configure: error: could not find the LUA byte compiler"
  #   # fixes: "configure: error: protoc compiler needed for chromecast was not found"
  #   nativeBuildInputs = orig.nativeBuildInputs ++ [ lua5 protobuf ];
  #   # fix that it can't find the c compiler
  #   # makeFlags = orig.makeFlags or [] ++ [ "CC=${prev.stdenv.cc.targetPrefix}cc" ];
  #   env = orig.env // {
  #     BUILDCC = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";
  #   };
  # });

  # 2025/10/23: upstreaming is unblocked, but i don't like this solution.
  vulkan-tools = prev.vulkan-tools.overrideAttrs (orig: {
    # alternatively: set `strictDeps = false;` (as is the default for vulkan-tools when *not* cross-compiling).
    # cmake seems to just not have any way to disambiguate host and build dependencies when using `pkg_check_modules`
    # - <https://cmake.org/cmake/help/latest/module/FindPkgConfig.html#command:pkg_check_modules>
    env = (orig.env or {}) // {
      PKG_CONFIG_PATH = "${lib.getDev buildPackages.wayland-scanner}/lib/pkgconfig";
    };
  });

  # 2025/07/27: upstreaming is blocked on ruby
  # fixes `hostPrograms.moby.neovim` (but breaks eval of `hostPkgs.moby.neovim` :o)
  # wrapNeovimUnstable = neovim: config: (prev.wrapNeovimUnstable neovim config).overrideAttrs (upstream: {
  #   # nvim wrapper has a sanity check that the plugins will load correctly.
  #   # this is effectively a check phase and should be rewritten as such
  #   postBuild = lib.replaceStrings
  #     [ "! $out/bin/nvim-wrapper" ]
  #     # [ "${stdenv.hostPlatform.emulator buildPackages} $out/bin/nvim-wrapper" ]
  #     [ "false && $out/bin/nvim-wrapper" ]
  #     upstream.postBuild;
  # });

  # fixes
  # > The system library `glib-2.0` required by crate `glib-sys` was not found.
  xdg-desktop-portal-cosmic = addBuildInputs [ glib ] prev.xdg-desktop-portal-cosmic;

  # 2025/09/06: upstreaming is unblocked; out for PR: <https://github.com/NixOS/nixpkgs/pull/442827>
  # xdp-tools = prev.xdp-tools.overrideAttrs {
  #   # when cross compiling, `clang` packages ships binary as `aarch64-...-clang` (wrapper),
  #   # and xdp-tools `configure` detects the unwrapped `clang` instead, doesn't receive nix flags
  #   CLANG = lib.getExe buildPackages.llvmPackages.clang;
  # };

  yt-dlp = prev.yt-dlp.override {
    # TODO(2025-11-17): yt-dlp needs deno (JavaScript) for full capability:
    # <https://github.com/NixOS/nixpkgs/pull/460892>
    javascriptSupport = false;  # a.k.a.: `deno = null;`
  };
}
