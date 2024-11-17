# Cargo.nix and crate-hashes.json were created with:
# - `nix run '.#crate2nix' -- generate -f ~/ref/repos/schmiddi-on-mobile/flare/Cargo.toml`
#
# the generated Cargo.nix points to an impure source (~/ref/...), but that's resolved by overriding `src` below
#
# compatibility matrix:
# - 0.10.1-beta.6 (2023/12/12):
#   - link to signald JMP.chat: NO (http 405)
#   - primary device via JMP.chat: NO (http 422)
#   - link to iOS tel: NO (http 405)
# - 0.10.1-beta.4 (2023/12/12):
#   - link to signald JMP.chat: NO (http 405)
#   - primary device via JMP.chat: NO (http 422)
#   - link to iOS tel: NO (http 405)
{
  appstream-glib,
  blueprint-compiler,
  defaultCrateOverrides,
  desktop-file-utils,
  fetchFromGitLab,
  gst_all_1,
  gtk4,
  gtksourceview5,
  lib,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  pkgs,
  protobuf,
  stdenv,
  wrapGAppsHook4,
  writeText,
  crateOverrideFn ? x: x,
}:
let
  extraCrateOverrides = {
    flare = attrs: attrs // {
      # inherit (flare-signal) src;
      src = fetchFromGitLab {
        domain = "gitlab.com";
        owner = "schmiddi-on-mobile";
        repo = "flare";
        rev = "0.15.0";
        hash = "sha256-sIT4oEmIV8TJ5MMxg3vxkvK+7PaIy/01kN9I2FTsfo0=";
      };

      codegenUnits = 16;  # speeds up the build a bit
      outputs = [ "out" ];  # default is "out" and "lib", but that somehow causes cycles
      outputDev = [ "out" ];

      nativeBuildInputs = [
        appstream-glib # for appstream-util
        blueprint-compiler
        desktop-file-utils # for update-desktop-database
        meson
        ninja
        pkg-config
        wrapGAppsHook4
      ];

      buildInputs = [
        gtksourceview5
        libadwaita
        # libsecret
        # libspelling  # optional feature. to enable, add it to `rootFeatures` above too.

        # To reproduce audio messages (c/o nixpkgs flare-signal)
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
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

      postPatch = ''
        # patch so meson will invoke our `crate2nix_cmd.sh` instead of cargo
        substituteInPlace src/meson.build \
          --replace 'cargo_options,'  "" \
          --replace "cargo, 'build',"  "'bash', 'crate2nix_cmd.sh'," \
          --replace "'target' / rust_target" "'target/bin'"
        # enable the "Primary Device" button (beta)
        substituteInPlace data/resources/ui/setup_window.blp \
          --replace 'sensitive: false;' ""
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
          # - we patch upstream flare to call our `crate2nix_cmd.sh` when it wants to compile the rust.
          # - we don't actually invoke meson (ninja) at all here, but rather in the `installPhase`.
          #   if we invoked it here, the whole build would just get re-done in installPhase anyway.
          #
          # rustc invocation copied from <pkgs/build-support/rust/build-rust-crate/lib.sh>
          crate_name_=flare
          main_file=../src/main.rs
          fix_link="-C linker=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
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

    gdk4-wayland-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtk4 ];  # depends on "gtk4_wayland"
    };
    gdk4-x11-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtk4 ];  # depends on "gtk4_x11"
    };
    libadwaita-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ libadwaita ];
    };
    libsignal-protocol = attrs: attrs // {
      nativeBuildInputs = [ protobuf ];  #< for `protoc`
    };
    libsignal-service = attrs: attrs // {
      nativeBuildInputs = [ protobuf ];  #< for `protoc`
    };
    presage-store-sled = attrs: attrs // {
      nativeBuildInputs = [ protobuf ];  #< for `protoc`
    };
    rav1e = attrs: attrs // {
      # TODO: `rav1e` is actually packaged in nixpkgs as a library:
      #   is there any way i can reuse that?
      CARGO_ENCODED_RUSTFLAGS = "";
    };
    # ring = attrs: attrs // {
    #   # CARGO_MANIFEST_LINKS = "ring_core_0_17_5";
    #   postPatch = (attrs.postPatch or "") + ''
    #     substituteInPlace build.rs --replace \
    #       'links = std::env::var("CARGO_MANIFEST_LINKS").unwrap();' 'links = "ring_core_0_17_5".to_string();'
    #   '';
    # };
    sourceview5-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtksourceview5 ];
    };

    pqcrypto-kyber = attrs: attrs // {
      # avoid "undefined reference to PQCLEAN_randombytes" when linking flare.
      # rustpq/pqcrypt tries to do this but somehow it fails.
      # see pqcrypto-internals/include/randombytes.h:
      #   `#define randombytes PQCRYPTO_RUST_randombytes`
      postPatch = ''
        substituteInPlace pqclean/common/randombytes.h \
          --replace 'PQCLEAN_randombytes' 'PQCRYPTO_RUST_randombytes'
      '';
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
  };

  cargoNix = import ./Cargo.nix {
    inherit pkgs;
    release = false;  #< XXX(2023/12/06): `release=true` is incompatible with cross compilation
    rootFeatures = [ ];  #< avoids --cfg feature="default", simplifying the rustc CLI so that i can pass it around easier
    defaultCrateOverrides = defaultCrateOverrides';
  };
  builtCrates = cargoNix.internal.builtRustCratesWithFeatures {
    packageId = "flare";
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
in builtCrates.crates.flare.overrideAttrs (super: {
  passthru = (super.passthru or {}) // {
    inherit (builtCrates) crates;
  };
})
