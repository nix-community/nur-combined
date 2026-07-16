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
  typelibPath = pkgs: lib.concatStringsSep ":" (map (p: "${lib.getLib p}/lib/girepository-1.0") pkgs);

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
      elif [[ "$arg" = "--artifact-dir" ]]; then
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
          --artifact-dir "$targetDir"/''${profile:-debug}
        )
      fi
    fi

    exec ${setEnv} "${lib.getExe cargo}" "$@" "''${extraFlags[@]}"
  '').overrideAttrs {
    inherit (cargo) meta;
  };
in with final; {
  # 2025/12/07: appears to be no longer required
  # armTrustedFirmwareRK3399 = prev.armTrustedFirmwareRK3399.overrideAttrs (upstream: {
  #   # 2025-10-06: fixes "arm-none-eabi-ld: /build/source/build/rk3399/release/m0/rk3399m0pmu.elf: error: PHDR segment not covered by LOAD segment".
  #   # TODO: send this to upstream arm-trusted-firmware, then PR a cherry-pick into nixpkgs
  #   patches = (upstream.patches or []) ++ [
  #     (pkgs.fetchpatch2 {
  #       name = "fix(rockchip): set no-pie option when building m0 elf file";
  #       url = "https://git.uninsane.org/colin/arm-trusted-firmare/commit/c192c366b8c423a6bf4293573fccfc258e801c87.patch";
  #       hash = "sha256-oXAJe3pahe3dnYfpmmW8KbSpN8XIzc1Zpm1CvXNrnAY=";
  #     })
  #   ];
  # });

  # binutils = prev.binutils.override {
  #   # fix that resulting binary files would specify build #!sh as their interpreter.
  #   # dtrx is the primary beneficiary of this.
  #   # this doesn't actually cause mass rebuilding.
  #   # note that this isn't enough to remove all build references:
  #   # - expand-response-params still references build stuff.
  #   shell = runtimeShell;
  # };

  # 2026/01/27: upstreaming is unblocked, but a cleaner solution than this doesn't seem to exist yet
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

  # 2025/12/07: upstreaming is blocked on mailutils -> gss -> shishi
  # emacs = prev.emacs.override {
  #   nativeComp = false;  # will be renamed to `withNativeCompilation` in future
  #   # future: we can specify 'action-if-cross-compiling' to actually invoke the test programs:
  #   # <https://www.gnu.org/software/autoconf/manual/autoconf-2.63/html_node/Runtime.html>
  # };

  # oof, each ffmpeg variant is a unique expression -- not an alias/override; have to override them all
  ffmpeg_8 = prev.ffmpeg_8.override {
    withCudaLLVM = false;
  };
  ffmpeg_8-full = prev.ffmpeg_8-full.override {
    withCudaLLVM = false;
  };
  ffmpeg_8-headless = prev.ffmpeg_8-headless.override {
    withCudaLLVM = false;
  };
  ffmpeg = prev.ffmpeg.override {
    withCudaLLVM = false;
  };
  ffmpeg-full = prev.ffmpeg-full.override {
    withCudaLLVM = false;
  };
  ffmpeg-headless = prev.ffmpeg-headless.override {
    withCudaLLVM = false;
  };

  # 2025/12/07: upstreaming is unblocked
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

  # 2025/12/07: upstreaming is unblocked
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

  # 2026-05-23: out for PR: <https://github.com/NixOS/nixpkgs/pull/523489>
  # gexiv2_0_16 = prev.gexiv2_0_16.overrideAttrs (prevAttrs: {
  #   # 2026-05-22: fixes:
  #   # > Build-time dependency gi-docgen found: NO (tried pkgconfig and cmake)
  #   depsBuildBuild = (prevAttrs.depsBuildBuild or []) ++ [
  #     pkgsBuildBuild.pkg-config
  #   ];
  # });

  # 2026-05-24: upstreaming is unblocked
  gnome-2048 = prev.gnome-2048.override {
    cargo = crossCargo;
  };

  # 2026-06-13: upstreaming is blocked by openblas.
  # rebase `pr-frog-zbar` and send for review once openblas is fixed.
  gnome-frog = prev.gnome-frog.override {
    # upstream's own build files configure zbar this way:
    # <https://github.com/TenderOwl/Frog/blob/40ea293327fc574e9a5be9e6010c5fa7e9d842a6/flatpak/zbar.json#L10>
    zbar = zbar.override { enableVideo = false; };
  };

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

  # 2025/12/07: upstreaming is unblocked
  # # gnustep is going to need a *lot* of work/domain-specific knowledge to truly cross-compile,
  # gnustep-base = prev.gnustep-base.overrideAttrs (upstream: {
  #   # fixes: "checking FFI library usage... ./configure: line 11028: pkg-config: command not found"
  #   # nixpkgs has this in nativeBuildInputs... but that's failing when we partially emulate things.
  #   buildInputs = (upstream.buildInputs or []) ++ [ prev.pkg-config ];
  # });

  gom = prev.gom.overrideAttrs (prevAttrs: {
    # 2026-05-22: fixes:
    # > bindings/python/meson.build:1:27: ERROR: python3 not found
    # note that this isn't a full fix; Gom.py doesn't ship, so the python feature likely can't actually run.
    postPatch = (prevAttrs.postPatch or "") + ''
      substituteInPlace bindings/python/meson.build \
        --replace-fail \
          "import('python').find_installation('python3')" \
          "'${python3.interpreter}'"
      perl -0777 -pe 's/python3\.install_sources\(\n  pygobject_override_files,\n  pure: true,\n  subdir: pygobject_override_dir\)/hostPython/g' bindings/python/meson.build > bindings/python/meson.build
    '';
    nativeBuildInputs = (prevAttrs.nativeBuildInputs or []) ++ [
      buildPackages.perl
    ];
    outputs = [ "out" ];
      # sed -z $'s/python3.install_sources\(\n  pygobject_override_files\n  pure: true,\n  subdir: pygobject_override_dir\)/install_data('"'"'gi\/overrides\/Gom.py'"'"', install_dir: pygobject_override_dir)/g' -i bindings/python/meson.build
  });

  # 2026/01/27: hyprland is blocked on hyprland-qtutils -> hyprland-qt-support
  # hyprland = prev.hyprland.override {
  #   # 2025/07/18: NOT FOR UPSTREAM.
  #   # hyprland uses gcc15Stdenv, with mold patch -> doesn't apply when cross compiling.
  #   # the package fails even after fixing stdenv, though.
  #   # stdenv = gcc14Stdenv;
  #   # stdenv = prev.stdenv;
  # };
  # only `nwg-panel` uses hyprland; `null`ing it seems to Just Work.
  hyprland = null;

  # 2026/01/27: blocked on hyprland-qt-support
  # used by hyprland (which is an indirect dep of waybar, nwg-panel, etc),
  # which it shells out to at runtime (and hence, not ever used by me).
  hyprland-qtutils = null;

  # 2025/12/07: upstreaming is blocked on java-service-wrapper
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

  # lemoa = prev.lemoa.override { cargo = crossCargo; };

  # 2026-03-27: upstreaming is unblocked, out for PR: <https://github.com/NixOS/nixpkgs/pull/504221>
  # libdng = prev.libdng.overrideAttrs (upstream: {
  #   # to find scdoc for cross builds
  #   depsBuildBuild = (upstream.depsBuildBuild or []) ++ [
  #     pkgsBuildBuild.pkg-config
  #   ];
  # });

  # 2026-05-23: out for PR: <https://github.com/NixOS/nixpkgs/pull/523487>
  # libglycin = prev.libglycin.overrideAttrs (prevAttrs: {
  #   postPatch = (prevAttrs.postPatch or "") + ''
  #     substituteInPlace libglycin/meson.build --replace-fail \
  #       "cargo_output = cargo_target_dir / rust_target" \
  #       "cargo_output = cargo_target_dir / '${stdenv.hostPlatform.rust.cargoShortTarget}' / rust_target"
  #   '';
  #   env = (prevAttrs.env or {}) // {
  #     CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;
  #   };
  # });
  # libglycin = prev.libglycin.override {
  #   cargo = crossCargo;
  #   # 2026-02-12: `libglycin.patchVendorHook` partially fixed by <https://github.com/NixOS/nixpkgs/pull/489743>
  #   # XXX(2026-02-04): users like `loupe`, `fractal`, place `libglycin.patchVendorHook` into `nativeBuildInputs`.
  #   # that doesn't splice, and it's generally unclear what the correct solution is to this.
  #   # further, the hook itself mixes build and host dependencies:
  #   # `jq` and `sponge` (moreutils) are used at hook time, whereas `bwrap` is injected by the hook into the package to be built.
  #   # jq = final.buildPackages.jq;
  #   # moreutils = final.buildPackages.moreutils;
  #   # leave bwrap unmodified -- it ought to be a runtime dependency
  # };

  # 2026-05-23: out for PR: <https://github.com/NixOS/nixpkgs/pull/523487>
  # libglycin-gtk4 = prev.libglycin-gtk4.overrideAttrs (prevAttrs: {
  #   postPatch = (prevAttrs.postPatch or "") + ''
  #     substituteInPlace libglycin/meson.build --replace-fail \
  #       "cargo_output = cargo_target_dir / rust_target" \
  #       "cargo_output = cargo_target_dir / '${stdenv.hostPlatform.rust.cargoShortTarget}' / rust_target"
  #   '';
  #   env = (prevAttrs.env or {}) // {
  #     CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;
  #   };
  # });
  # libglycin-gtk4 = prev.libglycin-gtk4.override {
  #   cargo = crossCargo;
  # };

  # 2026-04-28: out for PR: <https://github.com/NixOS/nixpkgs/pull/509396>
  # libqmi = prev.libqmi.overrideAttrs (prevAttrs: {
  #   depsBuildBuild = prevAttrs.depsBuildBuild or [] ++ [
  #     final.pkgsBuildBuild.pkg-config
  #   ];
  #   buildInputs = prevAttrs.buildInputs or [] ++ [
  #     final.bash
  #   ];
  # });

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

  # 2026/01/27: upstreaming is unblocked
  mepo = (prev.mepo.override {
    # nixpkgs mepo correctly puts `zig_0_14.hook` in nativeBuildInputs,
    # but that ends up being the wrong offset: `hook` isn't spliced.
    # see:
    # - pkgs/development/compilers/zig/generic.nix
    # - pkgs/development/compilers/zig/passthru.nix
    # even if `zig_0_14` has a `__spliced` attribute, its _passthru_ isn't spliced:
    # `zig_0_14.passthru.hook` (and others) are designed to run on the _host_.
    # the easiest correct fix is likely `makeScopeWithSplicing`.
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
  # 2025/12/07: upstreaming is unblocked by deps; but turns out to not be this simple
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

  # 2026/01/27: upstreaming is unblocked, but most of this belongs in _oils_ repo
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

  onnxruntime = prev.onnxruntime.override {
    # openvino does not cross compile
    openvinoSupport = false;
  };

  # alternatively, remove all mention of `ARMV9SME` from cmake/arch.cmake
  # openblas = prev.openblas.overrideAttrs (prevAttrs: {
  #   # <https://github.com/NixOS/nixpkgs/pull/513589>
  #   # this fixes `pkgsCross.aarch64-multiplatform.openblas`.
  #   # implemented manually here because it doesn't cherry-pick onto master
  #   # (master, staging-next, staging, ... what will they dream up next?? staging-nixos? nah, nobody could be _that_ retarded)
  #   # version = lib.warnIf (lib.versionOlder "0.3.32" prevAttrs.version) "openblas is updated upstream: remove version override?" "0.3.33";
  #   # src = prevAttrs.src.overrideAttrs {
  #   #   hash = "sha256-EArf0K2Gs+w8IRD5wkMOQv79e8yMoTgQfa9kzjXKn3Y=";
  #   # };
  #   # patches = lib.map
  #   #   (p:
  #   #     if p.url or "" == "https://github.com/OpenMathLib/OpenBLAS/commit/7086a1b075ca317e12cfe79d40a32ad342a30496.patch" then
  #   #       (fetchpatch {
  #   #         url = "https://github.com/OpenMathLib/OpenBLAS/commit/e3ce4623c299068bbd47c35ee87aab334bac73b1.patch";
  #   #         revert = true;
  #   #         hash = "sha256-WrP3RCDk/EbpqVOw9XGLnFI+6/bBGJTIrt2TRYGLVQ4=";
  #   #       })
  #   #     else
  #   #       p
  #   #   )
  #   #   prevAttrs.patches;

  #   # version = lib.warnIf (lib.versionOlder "0.3.32" prevAttrs.version) "openblas is updated upstream: remove version override?" "0.3.33-unstable-2026-04-27";
  #   # src = prevAttrs.src.overrideAttrs {
  #   #   rev = "10cf63eea44f53176444c3767c0a5a8843e91485";
  #   #   hash = "sha256-7h5snfJvDYYgjlxxCDwwWaXH9+RMoqKRQTa6IcKH9HQ=";
  #   # };

  #   # patches = [];

  #   # patches =
  #   # (lib.filter
  #   #   (p: p.url or "" != "https://github.com/OpenMathLib/OpenBLAS/commit/7086a1b075ca317e12cfe79d40a32ad342a30496.patch")
  #   #   prevAttrs.patches
  #   # ) ++ [
  #   #   (fetchpatch {
  #   #     name = "Accumulate results in output register explicitly";
  #   #     url = "https://github.com/OpenMathLib/OpenBLAS/commit/5442aff218e47fdf882dd2828b3552618b4bc761.patch";
  #   #     hash = "sha256-UHXzPAfFfFo11eOjnqmVF0lN1ZITrqSkrc46L4cRdbU=";
  #   #   })
  #   #   (fetchpatch {
  #   #     name = "Declare result as volatile to keep compilers from optimizing it out";
  #   #     url = "https://github.com/OpenMathLib/OpenBLAS/commit/3f6e928d34aca977bd5d4191e6d2c2338a342db5.patch";
  #   #     hash = "sha256-XTEojxcqnLiB/+N/OE/qkfoO2EiqOeAv2v1d9x8Lvic=";
  #   #   })
  #   #   (fetchpatch {
  #   #     name = "Use volatile attribute for SDOT only, to avoid creating new miscompilations";
  #   #     url = "https://github.com/OpenMathLib/OpenBLAS/commit/e3ce4623c299068bbd47c35ee87aab334bac73b1.patch";
  #   #     hash = "sha256-j0zIJjNiAdIVPgdxB+pXiOrOtedDu6Yq+dgaJ/wCquk=";
  #   #   })
  #   #   (fetchpatch {
  #   #     name ="CMake-properly-fix-build-on-macOS-with-Ninja-related-to-response-files";
  #   #     url = "https://github.com/OpenMathLib/OpenBLAS/commit/ca4d867cbbc7896715ddceb142e7fef3945fd6ed.patch";
  #   #     hash = "sha256-wUDLBsxyX1dupQZlEiuQS4f3CQf+kCBiSLIoem9IrLw=";
  #   #   })
  #   # ];

  #   version = lib.warnIf (lib.versionOlder "0.3.32" prevAttrs.version) "openblas is updated upstream: remove version override?" "0.3.31";
  #   src = prevAttrs.src.overrideAttrs {
  #     hash = "sha256-YBR81GOLnTsc0g1SZL+j31/OFucJrBRFqtOTV8lcy8U=";
  #   };

  #   patches = lib.filter
  #     (p:
  #       p.url or "" != "https://github.com/OpenMathLib/OpenBLAS/commit/7086a1b075ca317e12cfe79d40a32ad342a30496.patch"
  #       && p.url or "" != "https://github.com/OpenMathLib/OpenBLAS/commit/3f6e928d34aca977bd5d4191e6d2c2338a342.patch"
  #     )
  #     prevAttrs.patches
  #   ;
  # });

  opencv = prev.opencv.override {
    # fails to link against reference blas implementation, only openblas (currently broken)
    enableBlas = false;
    # `pkgsCross.aarch64-multiplatform.openblas` fails, but the "reference" implementation does compile.
    # blas = final.blas.override { blasProvider = final.lapack-reference; };
  };

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

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyself: pysuper: {
      numpy = pysuper.numpy.override {
        # 2026-04-27: `pkgsCross.aarch64-multiplatform.openblas` fails, but the "reference" implementation does compile.
        blas = final.blas.override { blasProvider = final.lapack-reference; };
        lapack = final.lapack.override { lapackProvider = final.lapack-reference; };
      };
      pip = pysuper.pip.overridePythonAttrs (prevAttrs: {
        # skip shell completions. could be re-enabled by using emulator.
        postInstall = lib.replaceStrings [ "installShellCompletion" ] [ "true || installShellCompletion" ] prevAttrs.postInstall;
      });
      scipy = pysuper.scipy.override {
        blas = final.blas.override { blasProvider = final.lapack-reference; };
        lapack = final.lapack.override { lapackProvider = final.lapack-reference; };
      };
      # 2025/07/23: upstreaming is unblocked, but solution is untested.
      # the references here are a result of the cython build process.
      # cython is using the #include files from the build python, and leaving those paths in code comments.
      # better solution is to get cython to use the HOST python??
      #
      # python3Packages.srsly is required by `newelle` program.
      # srsly = pysuper.srsly.overridePythonAttrs (upstream: {
      #   nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
      #     removeReferencesTo
      #   ];
      #   postFixup = (upstream.postFixup or "") + ''
      #     remove-references-to -t ${pyself.python.pythonOnBuildForHost} $out/${pyself.python.sitePackages}/srsly/msgpack/*.cpp
      #   '';
      # });
    })
  ];

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
  # });

  # 2026/01/27: upstreaming is unblocked
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

  systemd = prev.systemd.overrideAttrs (prevAttrs: {
    # implemented on my 2026-07-11-cross nixpkgs branch
    postPatch = lib.replaceString "substituteInPlace meson.build" "substituteInPlace src/bpf/meson.build" prevAttrs.postPatch;
  });

  # 2026/01/03: upstreaming is unblocked
  # tangram = prev.tangram.overrideAttrs (upstream: {
  #   # gsjpack has a shebang for the host gjs. patchShebangs --build doesn't fix that: just manually specify the build gjs.
  #   # the proper way to patch this for nixpkgs is:
  #   # 1. split `gjspack` into its own package.
  #   #   - right now it's a submodule of all of sonnyp's repos,
  #   #     and each nix package re-builds it (forge-sparks, junction, tangram).
  #   # 2. wrap `gjspack` the same way i did blueprint-compiler, and put it in nativeBuildInputs
  #   postPatch = let
  #     gjspack' = buildPackages.writeShellScriptBin "gjspack" ''
  #       export GI_TYPELIB_PATH=${typelibPath [ buildPackages.glib ]}:$GI_TYPELIB_PATH
  #       exec ${buildPackages.gjs}/bin/gjs $@
  #     '';
  #   in (upstream.postPatch or "") + ''
  #     substituteInPlace src/meson.build \
  #       --replace-fail "find_program('gjs').full_path()" "'${gjs}/bin/gjs'" \
  #       --replace-fail "gjspack,"  "'${gjspack'}/bin/gjspack', '-m', gjspack,"
  #   '';
  #   # postPatch = (upstream.postPatch or "") + ''
  #   #   substituteInPlace src/meson.build \
  #   #     --replace-fail "find_program('gjs').full_path()" "'${gjs}/bin/gjs'" \
  #   #     --replace-fail "gjspack," "'env', 'GI_TYPELIB_PATH=${typelibPath [
  #   #       buildPackages.glib
  #   #     ]}', '${buildPackages.gjs}/bin/gjs', '-m', gjspack,"
  #   # '';
  # });

  # 2026-04-27: upstreaming is unblocked
  # fixes:
  # > error: failed to run custom build command for `rquickjs-sys v0.10.0`
  # > tree-sitter-aarch64-unknown-linux-gnu>   /nix/store/mlwvry8xga608jlh4q4pgsfwkhzh0vdw-glibc-aarch64-unknown-linux-gnu-2.42-61-dev/include/bits/math-vector.h:184:9: error: unknown type name '__SVBool_t'
  # > tree-sitter-aarch64-unknown-linux-gnu>   thread 'main' (4005) panicked at /build/tree-sitter-0.26.8-vendor/source-registry-0/rquickjs-sys-0.10.0/build.rs:352:39:
  # > tree-sitter-aarch64-unknown-linux-gnu>   Unable to generate bindings: ClangDiagnostic("/nix/store/mlwvry8xga608jlh4q4pgsfwkhzh0vdw-glibc-aarch64-unknown-linux-gnu-2.42-61-dev/include/bits/math-vector.h:182:9: error: unknown type name '__SVFloat32_t'\n/nix/store/mlwvry8xga608jlh4q4pgsfwkhzh0vdw-glibc-aarch64-unknown-linux-gnu-2.42-61-dev/include/bits/math-vector.h:183:9: error: unknown type name '__SVFloat64_t'\n/nix/store/mlwvry8xga608jlh4q4pgsfwkhzh0vdw-glibc-aarch64-unknown-linux-gnu-2.42-61-dev/include/bits/math-vector.h:184:9: error: unknown type name '__SVBool_t'\n")
  tree-sitter = prev.tree-sitter.overrideAttrs (finalAttrs: prevAttrs: {
    version = lib.warnIf (lib.versionOlder "0.26.8" prevAttrs.version) "tree-sitter is updated upstream: remove version override?" "0.25.10";
    src = prevAttrs.src.overrideAttrs {
      hash = "sha256-aHszbvLCLqCwAS4F4UmM3wbSb81QuG9FM7BDHTu1ZvM=";
    };
    cargoHash = "sha256-4R5Y9yancbg/w3PhACtsWq0+gieUd2j8YnmEj/5eqkg=";
    # patches = [
    #   (fetchurl {
    #     url = "https://github.com/NixOS/nixpkgs/raw/e881e15c004f6716b8464a0a56566ca3a5ce37a8/pkgs/development/tools/parsing/tree-sitter/remove-web-interface.patch";
    #     hash = "sha256-4iVLr0jRJgmnkFGe35GQBjF/AoB/55VxbEu+YIYHT1A=";
    #   })
    # ];
    patches = lib.map
      (p: if p.url or null == null then
        (fetchurl {
          url = "https://github.com/NixOS/nixpkgs/raw/e881e15c004f6716b8464a0a56566ca3a5ce37a8/pkgs/development/tools/parsing/tree-sitter/remove-web-interface.patch";
          hash = "sha256-4iVLr0jRJgmnkFGe35GQBjF/AoB/55VxbEu+YIYHT1A=";
        })
      else
        p
      )
      prevAttrs.patches;
  });

  # fixes: "ar: command not found"
  # `ar` is provided by bintools
  # 2026/01/27: upstreaming is blocked on gnustep-base cross compilation
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

  # 2025/12/07: upstreaming is blocked on h5py, pyarrow/arrow-cpp, thrift, apache-orc, google-cloud-cpp
  # visidata = prev.visidata.override {
  #   # hdf5 / h5py don't cross-compile, but i don't use that file format anyway.
  #   # setting this to null means visidata will work as normal but not be able to load hdf files.
  #   h5py = null;
  # };
  # 2025/12/07: upstreaming is blocked on qtsvg, qtx11extras
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

  # implemented on my 2026-06-14-wezterm-cross-2 and 2026-06-15-wezterm-cross nixpkgs branches
  wezterm = prev.wezterm.overrideAttrs (prevAttrs: {
    # env = let
    #   prefix = stdenv.buildPlatform.rust.cargoEnvVarTarget;
    # in {
    #   "${prefix}_OPENSSL_LIB_DIR" = "${lib.getLib pkgsBuildBuild.openssl}/lib";
    #   "${prefix}_OPENSSL_INCLUDE_DIR" = "${lib.getDev pkgsBuildBuild.openssl}/include";
    # };
    env = {
      HOST_PKG_CONFIG = lib.getExe pkgsBuildBuild.pkg-config;
      HOST_PKG_CONFIG_PATH = "${lib.getDev buildPackages.openssl}/lib/pkgconfig";
    };
    # depsBuildBuild = (prevAttrs.depsBuildBuild or []) ++ [
    #   pkgsBuildBuild.pkg-config
    # ];
    # nativeBuildInputs = (prevAttrs.nativeBuildInputs or []) ++ [
    #   buildPackages.openssl
    # ];
    # preConfigure = (prevAttrs.preConfigure or "") + ''
    #   export HOST_PKG_CONFIG=$(PKG_CONFIG_FOR_BUILD)
    #   export HOST_PKG_CONFIG_PATH=$(PKG_CONFIG_PATH_FOR_BUILD)
    # '';
    # env.PKG_CONFIG_PATH = "${buildPackages.openssl.dev}/lib/pkgconfig";
    # depsBuildBuild = (prevAttrs.depsBuildBuild or []) ++ [
    #   pkgsBuildBuild.pkg-config
    # ];
    # nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [
    #   buildPackages.openssl
    # ];
  });

  # 2025/12/07: upstreaming is unblocked
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

  # 2026/01/27: upstreaming is unblocked
  xdg-desktop-portal-phosh = prev.xdg-desktop-portal-phosh.overrideAttrs (orig: {
    postPatch = (orig.postPatch or "") + ''
      substituteInPlace src/meson.build --replace-fail \
        "'src' / cargo_target / pmp_exe_name" \
        "'src' / '${stdenv.hostPlatform.rust.cargoShortTarget}' / cargo_target / pmp_exe_name"

      substituteInPlace subprojects/pfs/src/meson.build --replace-fail \
        "'src' / rust_target" \
        "'src' / '${stdenv.hostPlatform.rust.cargoShortTarget}' / rust_target"
    '';
    nativeBuildInputs = orig.nativeBuildInputs ++ [
      pkgs.glib
    ];
    env = (orig.env or {}) // {
      CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;
    };
  });

  # XXX(2026-02-15): i tried to get x86_64 -> aarch64 cross compilation of electron working, failed:
  # yarn-berry_3-fetcher = prev.yarn-berry_3-fetcher.overrideScope (f: p: {
  #   yarnBerryConfigHook = p.yarnBerryConfigHook.override {
  #     diffutils = final.buildPackages.diffutils;
  #     nodejs = final.buildPackages.nodejs;
  #     yarn-berry-offline = buildPackages.yarn-berry_3-fetcher.yarn-berry-offline;
  #   };
  # });

  # yarn-berry_4-fetcher = prev.yarn-berry_4-fetcher.overrideScope (f: p: {
  #   yarnBerryConfigHook = p.yarnBerryConfigHook.override {
  #     diffutils = final.buildPackages.diffutils;
  #     nodejs = final.buildPackages.nodejs;
  #     yarn-berry-offline = buildPackages.yarn-berry_4-fetcher.yarn-berry-offline;
  #   };
  # });

  # # `yarn-berry.passthru.yarnBerryConfigHook` &c aren't spliced,
  # # however `yarn-berry_{3,4}-fetcher` is that same `yarn-berry_{3,4}.passthru` scope but properly spliced.
  # # i should port nixpkgs `yarn-berry.yarnBerryConfigHook` users over to `yarn-berry_{3,4}-fetcher.yarnBerryConfigHook`
  # # but in the meantime, force `yarn-berry.yarnBerryConfigHook` to be equivalent
  # yarn-berry = prev.yarn-berry.overrideAttrs (upstream: {
  #   passthru = upstream.passthru // {
  #     inherit (final.yarn-berry_4-fetcher)
  #       berryCacheVersion
  #       berryOfflinePatches
  #       berryVersion
  #       # callPackage
  #       fetchYarnBerryDeps
  #       libzip
  #       # newScope
  #       # override
  #       # overrideDerivation
  #       # overrideScope
  #       # packages
  #       yarn-berry
  #       yarn-berry-fetcher
  #       yarn-berry-offline
  #       yarnBerryConfigHook
  #       ;
  #   };
  # });
  # yarn-berry_3 = prev.yarn-berry_3.overrideAttrs (upstream: {
  #   passthru = upstream.passthru // {
  #     inherit (final.yarn-berry_3-fetcher)
  #       berryCacheVersion
  #       berryOfflinePatches
  #       berryVersion
  #       # callPackage
  #       fetchYarnBerryDeps
  #       libzip
  #       # newScope
  #       # override
  #       # overrideDerivation
  #       # overrideScope
  #       # packages
  #       yarn-berry
  #       yarn-berry-fetcher
  #       yarn-berry-offline
  #       yarnBerryConfigHook
  #       ;
  #   };
  # });
  # yarn-berry_4 = prev.yarn-berry_4.overrideAttrs (upstream: {
  #   passthru = upstream.passthru // {
  #     inherit (final.yarn-berry_4-fetcher)
  #       berryCacheVersion
  #       berryOfflinePatches
  #       berryVersion
  #       # callPackage
  #       fetchYarnBerryDeps
  #       libzip
  #       # newScope
  #       # override
  #       # overrideDerivation
  #       # overrideScope
  #       # packages
  #       yarn-berry
  #       yarn-berry-fetcher
  #       yarn-berry-offline
  #       yarnBerryConfigHook
  #       ;
  #   };
  # });

  # yt-dlp = let
  #   # XXX(2026-02-04): yt-dlp accepts one of 4 JS runtimes, in order:
  #   # - deno
  #   # - nodejs
  #   # - quickjs (a.k.a. quickjs-ng)
  #   # - bun
  #   # nixpkgs allows providing any of these simply by overriding the `deno` callpackage argument,
  #   # but yt-dlp only actually checks for `deno` unless configured otherwise (i guess there's some runtime config?)
  #   # jsRuntime = final.deno;  #< 2026-02-04: doesn't cross compile
  #   jsRuntime = final.nodejs;  #< 2026-02-04: runtime error: "WARNING: [youtube] [jsc] Error solving n challenge request using "node" provider: Error running node process (returncode: 1): found 0 sig function possibilities."
  #   # jsRuntime = final.quickjs-ng; #< 2026-02-04: runtime error: "WARNING: [youtube] [jsc] Error solving n challenge request using "quickjs" provider: Error running QuickJS process (returncode: 1): found 0 sig function possibilities"
  #   # jsRuntime = final.bun;  #< 2026-02-04: doesn't cross compile
  #   #
  #   # TODO: just fix deno cross compilation and drop this overlay: it's unclear if it actually works.
  #   jsRuntimeYtdlpName = {
  #     deno = "deno";
  #     node = "node";
  #     qjs = "quickjs";
  #     bun = "bun";
  #   }.${jsRuntime.meta.mainProgram};
  # in
  #   (prev.yt-dlp.override {
  #     deno = jsRuntime;
  #   }).overrideAttrs (upstream: {
  #     postPatch = (upstream.postPatch or "") + ''
  #       substituteInPlace yt_dlp/YoutubeDL.py \
  #         --replace-fail \
  #           "self.params.get('js_runtimes', {'deno': {}})" \
  #           "self.params.get('js_runtimes', {'${jsRuntimeYtdlpName}': {}})"
  #       substituteInPlace yt_dlp/options.py \
  #         --replace-fail \
  #           "default=['deno']" \
  #           "default=['${jsRuntimeYtdlpName}']"
  #     '';
  #   });
  # yt-dlp = prev.yt-dlp.override {
  #   # TODO(2025-11-17): yt-dlp needs deno (JavaScript) for full capability:
  #   # <https://github.com/NixOS/nixpkgs/pull/460892>
  #   javascriptSupport = false;  # a.k.a.: `deno = null;`
  # };

  # 2023/12/10: zbar barcode scanner: used by megapixels, frog.
  # the video component does not cross compile (qt deps), but i don't need that.
  # N.B.: if desired, the "video" portion (zbarcam-gtk, zbarcam-qt) can be built for only gtk, by configuring with `--without-qt`.
  # N.B.: pyzbar uses `zbar.override { enableVideo = false; }` in nixpkgs;
  #       i could submit a PR to do the same for nixpkgs.
  #       prior art is that <repo:megapixels:develop.sh> uses `apt add ... zbar-devel`,
  #       and the aports for zbar-devel builds with `--disable-video`.
  # 2026/01/27: still broken upstream
  # zbar = prev.zbar.override { enableVideo = false; };
}
