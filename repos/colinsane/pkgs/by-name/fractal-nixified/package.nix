# Cargo.nix and crate-hashes.json were created with:
# - `nix run '.#crate2nix' -- generate -f ~/ref/repos/gnome/fractal/Cargo.toml`
# or, for devel crate2nix:
# - `nix shell -f https://github.com/kolloch/crate2nix/tarball/master`
#   - `crate2nix generate -f ~/ref/repos/gnome/fractal/Cargo.toml`
#
# to update:
# - `git fetch` in `~/ref/repos/gnome/fractal/`
# - re-run that crate2nix step
# - update `src` rev to match the local checkout!

{
  appstream-glib,
  buildPackages,
  defaultCrateOverrides,
  desktop-file-utils,
  gdk-pixbuf,
  glib,
  gst_all_1,
  gtk4,
  gtksourceview5,
  lib,
  libadwaita,
  libshumate,
  meson,
  ninja,
  openssl,
  pipewire,
  pkg-config,
  pkgs,
  rustPlatform,
  sqlite,
  stdenv,
  wrapGAppsHook4,
  writeText,
  xdg-desktop-portal,
  optimize ? true,
  crateOverrideFn ? x: x,
}:
let mkConfigured = { optimize }:
let
  # `optimize` option applies only to the top-level build; not fractal's dependencies.
  # as of 2023/10/29:
  # - opt-level=0: builds in 1min, 105M binary
  # - opt-level=1: builds in 2.25hr, 75M binary
  # - opt-level=2: builds in 2.25hr
  # - opt-level=3: builds in 2.25hr, 68-70M binary
  # as of 2023/10/30:
  # - opt-level=3: builds in 5min, 71M binary
  optFlags = if optimize then "-C opt-level=3" else "-C opt-level=0";

  extraCrateOverrides = {
    fractal = attrs: attrs // {
      src = pkgs.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "GNOME";
        repo = "fractal";
        rev = "8";
        hash = "sha256-a77+lPH2eqWTLFrYfcBXSvbyyYC52zSo+Rh/diqKYx4=";
      };
      codegenUnits = 256;  #< this does get plumbed, but doesn't seem to affect build speed
      outputs = [ "out" ];  # default is "out" and "lib", but that somehow causes cycles
      outputDev = [ "out" ];
      nativeBuildInputs = [
        appstream-glib  # optional, for validation
        desktop-file-utils  # for update-desktop-database
        glib  # for glib-compile-resources, gettext
        gtk4  # for gtk4-update-icon-cache
        meson
        ninja
        pkg-config
        wrapGAppsHook4
      ];
      buildInputs = [
        glib
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gstreamer
        gtk4
        gtksourceview5
        libadwaita
        libshumate
        openssl
        pipewire
        sqlite
        xdg-desktop-portal
      ];

      mesonFlags = let
        # this gets meson to shutup about rustc not producing executables.
        # kinda silly though, since we patch out the actual cargo (rustc) invocations.
        crossFile = writeText "cross-file.conf" ''
        [binaries]
        rust = [ 'rustc', '--target', '${stdenv.hostPlatform.rust.rustcTargetSpec}' ]
      '';
      in
        lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
          "--cross-file=${crossFile}"
        ];

      # patch so meson will invoke our `crate2nix_cmd.sh` instead of cargo
      postPatch = ''
        substituteInPlace src/meson.build \
          --replace-fail 'cargo_options,'  "" \
          --replace-fail "cargo, 'build',"  "'bash', 'crate2nix_cmd.sh'," \
          --replace-fail "'src' / rust_target" "'target/bin'"
      '';
      postConfigure = ''
        # copied from <pkgs/development/tools/build-managers/meson/setup-hook.sh>
        mesonFlags="--prefix=$prefix $mesonFlags"
        mesonFlags="\
            --libdir=''${!outputLib}/lib --libexecdir=''${!outputLib}/libexec \
            --bindir=''${!outputBin}/bin --sbindir=''${!outputBin}/sbin \
            --includedir=''${!outputInclude}/include \
            --mandir=''${!outputMan}/share/man --infodir=''${!outputInfo}/share/info \
            --localedir=''${!outputLib}/share/locale \
            -Dauto_features=''${mesonAutoFeatures:-enabled} \
            -Dwrap_mode=''${mesonWrapMode:-nodownload} \
            $mesonFlags"

        mesonFlags="''${crossMesonFlags+$crossMesonFlags }--buildtype=''${mesonBuildType:-plain} $mesonFlags"

        echo "meson flags: $mesonFlags ''${mesonFlagsArray[@]}"

        meson setup build $mesonFlags "''${mesonFlagsArray[@]}"
        cd build
      '';
      preBuild = ''
        build_bin() {
          # build_bin is what buildRustCrate would use to invoke rustc, but we want to drive the build
          # with meson instead. however, meson doesn't know how to plumb our rust dependencies into cargo,
          # so we still need to use build_bin for just one portion of the build.
          #
          # so, this mocks out the original build_bin:
          # - we patch upstream fractal to call our `crate2nix_cmd.sh` when it wants to compile the rust.
          # - we don't actually invoke meson (ninja) at all here, but rather in the `installPhase`.
          #   if we invoked it here, the whole build would just get re-done in installPhase anyway.
          #
          # rustc invocation copied from <pkgs/build-support/rust/build-rust-crate/lib.sh>
          crate_name_=fractal
          main_file=../src/main.rs
          fix_link="-C linker=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
          EXTRA_RUSTC_FLAGS="$EXTRA_RUSTC_FLAGS ${optFlags}"
          cat >> crate2nix_cmd.sh <<EOF
            set -x
            rmdir target/bin
            rmdir target
            ln -s ../target .
            rustc \
            $fix_link \
            --crate-name $crate_name_ \
            $main_file \
            --crate-type bin \
            $BIN_RUSTC_OPTS \
            --out-dir target/bin \
            -L dependency=target/deps \
            $LINK \
            $EXTRA_LINK_ARGS \
            $EXTRA_LINK_ARGS_BINS \
            $EXTRA_LIB \
            --cap-lints allow \
            $BUILD_OUT_DIR \
            $EXTRA_BUILD \
            $EXTRA_FEATURES \
            $EXTRA_RUSTC_FLAGS \
            --color ''${colors}
      EOF
        }
      '';

      installPhase = "ninjaInstallPhase";
    };

    # TODO: upstream these into `pkgs/build-support/rust/default-crate-overrides.nix`
    # figuring this out is largely guesswork based on seeing build failures and then cloning the
    # crate and checking its build script. however, grepping the failed crate in nixpkgs can reveal
    # users, and then see which other buildInputs consumers typically provide near these libraries.
    # see also: <repo:nixos/nixpkgs:pkgs/build-support/rust/default-crate-overrides.nix>

    clang-sys = attrs: attrs // {
      LIBCLANG_PATH = "${buildPackages.llvmPackages.libclang.lib}/lib";
    };
    gdk-pixbuf-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gdk-pixbuf ];
    };
    gdk4-wayland-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtk4 ];  # depends on "gtk4_wayland"
    };
    gdk4-x11-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtk4 ];  # depends on "gtk4_x11"
    };
    gio-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ glib ];
    };
    gobject-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ glib ];
    };
    gstreamer-audio-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gst_all_1.gst-plugins-base ];
    };
    gstreamer-base-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gst_all_1.gst-plugins-base ];
    };
    gstreamer-pbutils-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gst_all_1.gst-plugins-base ];
    };
    gstreamer-play-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-base
      ];
    };
    gstreamer-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gst_all_1.gst-plugins-base ];
    };
    gstreamer-video-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gst_all_1.gst-plugins-base ];
    };
    gst-plugin-gtk4 = attrs: attrs // {
      # [package.metadata.capi.pkg_config]
      # requires_private = "gstreamer-1.0, gstreamer-base-1.0, gstreamer-video-1.0, gtk4, gobject-2.0, glib-2.0, gmodule-2.0"
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [
        gst_all_1.gst-plugins-base
        gst_all_1.gst-libav
        gtk4
        glib
      ];
      CARGO_PKG_REPOSITORY = "nixpkgs";
      # it wants `type = [ "cdylib" "rlib" ]` but that causes a link format failure on cross compilation
      #   (tries to link aarch64 gstgtk4.o file with the x86_64 linker).
      # default if unspecified it `type = [ "lib" ]`
      type = [ "rlib" ];
    };
    libadwaita-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ libadwaita ];
    };
    libshumate-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ libshumate gtk4 ];
    };
    libspa-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config rustPlatform.bindgenHook ];
      buildInputs = [ pipewire ];

      # bindgenHook does the equivalent of this:
      # preConfigure = (attrs.preConfigure or "") + ''
      #   # export BINDGEN_EXTRA_CLANG_ARGS="$NIX_CFLAGS_COMPILE"
      #   export BINDGEN_EXTRA_CLANG_ARGS="$(< ${clang}/nix-support/cc-cflags) $(< ${clang}/nix-support/libc-cflags) $(< ${clang}/nix-support/libcxx-cxxflags) $NIX_CFLAGS_COMPILE"
      # '';
      # LIBCLANG_PATH = "${buildPackages.llvmPackages.libclang.lib}/lib";
    };
    libspa = attrs: attrs // {
      # not sure why the non-sys version of this crate needs pkg-config??
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ pipewire ];
    };
    pipewire-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config rustPlatform.bindgenHook ];
      buildInputs = [ pipewire ];

      # bindgenHook does the equivalent of this:
      # preConfigure = (attrs.preConfigure or "") + ''
      #   # export BINDGEN_EXTRA_CLANG_ARGS="$NIX_CFLAGS_COMPILE"
      #   export BINDGEN_EXTRA_CLANG_ARGS="$(< ${clang}/nix-support/cc-cflags) $(< ${clang}/nix-support/libc-cflags) $(< ${clang}/nix-support/libcxx-cxxflags) $NIX_CFLAGS_COMPILE"
      # '';
      # LIBCLANG_PATH = "${buildPackages.llvmPackages.libclang.lib}/lib";
    };
    rav1e = attrs: attrs // {
      # TODO: `rav1e` is actually packaged in nixpkgs as a library:
      #   is there any way i can reuse that?
      CARGO_ENCODED_RUSTFLAGS = "";
    };
    ring = attrs: attrs // {
      # if after an update you see:
      # ```
      # > assertion `left == right` failed
      # >   left: "ring_core_0_17_5"
      # >  right: "ring_core_0_17_7"
      # ```
      # just update this patch to reflect the right-hand side
      # CARGO_MANIFEST_LINKS = "ring_core_0_17_7";
      postPatch = (attrs.postPatch or "") + ''
        substituteInPlace build.rs --replace-fail \
          'links = std::env::var("CARGO_MANIFEST_LINKS").unwrap();' 'links = "ring_core_0_17_7".to_string();'
      '';
    };
    sourceview5-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtksourceview5 ];
    };
    zune-jpeg = attrs: attrs // {
      # it wants `type = [ "cdylib" "rlib" ]` but that causes a link format failure on cross compilation
      type = [ "rlib" ];
    };
  };

  defaultCrateOverrides' = defaultCrateOverrides // (lib.mapAttrs (crate: fn:
    # map each `extraCrateOverrides` to first pass their attrs through `defaultCrateOverrides`
    attrs: fn ((defaultCrateOverrides."${crate}" or (a: a)) attrs)
  ) extraCrateOverrides);

  crate2NixOverrides = crates: crates // {
    # crate2nix sometimes "misses" dependencies, or gets them wrong in a way that crateOverrides can't patch.
    # this function lets me patch over Cargo.nix without actually modifying it by hand.
    ashpd = crates.ashpd // {
      # specifically, it needs zvariant; providing that through zbus is a convenient way to also
      # coerce the feature flags so as to reduce rebuilds
      dependencies = crates.ashpd.dependencies ++ crates.zbus.dependencies;
    };
    matrix-sdk = crates.matrix-sdk // {
      dependencies = crates.matrix-sdk.dependencies ++ [
        {
          name = "ruma-events";
          packageId = "ruma-events";
        }
      ];
    };
    matrix-sdk-base = crates.matrix-sdk-base // {
      dependencies = crates.matrix-sdk-base.dependencies ++ [
        {
          name = "ruma-events";
          packageId = "ruma-events";
        }
      ];
    };
    matrix-sdk-crypto = crates.matrix-sdk-crypto // {
      dependencies = crates.matrix-sdk-crypto.dependencies ++ [
        {
          name = "ruma-common";
          packageId = "ruma-common";
        }
      ];
    };
    matrix-sdk-ui = crates.matrix-sdk-ui // {
      dependencies = lib.forEach crates.matrix-sdk-ui.dependencies (d:
        if d.name == "matrix-sdk" then d // {
          # XXX(2024/06/04): experimental-oidc feature drags in p384, which fails armv7l cross
          features = lib.remove "experimental-oidc" d.features;
        } else
          d
      );
    };
  };

  cargoNix = import ./Cargo.nix {
    inherit pkgs;
    release = false;  #< XXX(2023/12/06): `release=true` is incompatible with cross compilation
    rootFeatures = [ ];  #< avoids --cfg feature="default", simplifying the rustc CLI so that i can pass it around easier
    defaultCrateOverrides = defaultCrateOverrides';
  };

  builtCrates = cargoNix.internal.builtRustCratesWithFeatures {
    packageId = "fractal";
    features = [];
    buildRustCrateForPkgsFunc = pkgs: crateArgs: let
      crateDeriv = (pkgs.buildRustCrate.override {
        defaultCrateOverrides = defaultCrateOverrides';
      }) crateArgs;
    in
      crateOverrideFn crateDeriv;
    crateConfigs = crate2NixOverrides cargoNix.internal.crates;
    runTests = false;
  };
  fractalDefault = builtCrates.crates.fractal;
in
  fractalDefault.overrideAttrs (super: {
    passthru = (super.passthru or {}) // {
      optimized = mkConfigured { optimize = true; };
      unoptimized = mkConfigured { optimize = false; };
      inherit (builtCrates) crates;
    };
  });
in
  mkConfigured { inherit optimize; }
