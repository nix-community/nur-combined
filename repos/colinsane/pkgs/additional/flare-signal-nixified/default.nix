# Cargo.nix and crate-hashes.json were created with:
# - `nix run '.#crate2nix' -- generate -f ~/ref/repos/schmiddi-on-mobile/flare/Cargo.toml`
# - `sed -i 's/target."curve25519_dalek_backend"/target."curve25519_dalek_backend" or ""/g' Cargo.nix`
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
{ lib
, appstream-glib
, blueprint-compiler
, buildPackages
, defaultCrateOverrides
, desktop-file-utils
, fetchFromGitLab
, flare-signal
, gdk-pixbuf
, glib
, gobject-introspection
, gst_all_1
, gtk4
, gtksourceview5
, libadwaita
, libsecret
, libspelling
, meson
, ninja
, pkg-config
, pkgs
, protobuf
, rust
, stdenv
, wrapGAppsHook4
, writeText
, crateOverrideFn ? x: x
}:
let
  extraCrateOverrides = {
    flare = attrs: attrs // {
      # inherit (flare-signal) src;
      src = fetchFromGitLab {
        domain = "gitlab.com";
        owner = "schmiddi-on-mobile";
        repo = "flare";
        rev = "0.10.1-beta.6";
        hash = "sha256-NhQu9gpnweI+kIWh3Mbb9bCQnfgthxocAqDRwG0m2Hg=";

        # flare/Cargo.nix version compatibility:
        # - flare 0.10.1-beta.6: compiles
        # - flare 0.10.1-beta.5: can't crate2nix because Cargo.lock is out of date with Cargo.toml
        # - flare 0.10.1-beta.4: compiles
        # - flare 0.10.1-beta.2: requires gtk 4.11, not yet in nixpkgs
        #   - <https://github.com/NixOS/nixpkgs/pull/247766>
        #   - specifically, that's because of gdk4-sys 0.7.2.
        #   - after 0.10.1-beta.1, there's a translations update, then immediately "ui(): Port to GTK 4.12 and Libadwaita 1.4"
        #     so 0.10.1-beta.1 is effectively the last gtk 4.10 compatible version
        # - flare 0.10.1-beta.1: uses a variant of serde_derive which doesn't cross compile in nixpkgs
        #   - after serde_derive downgraded => 1.0.171:
        #     ```
        #     > 424 |             .send(manager.sync_contacts().await)
        #     >     |                           ^^^^^^^^^^^^^ private method
        #     >    --> /presage-d6d8fff/presage/src/manager.rs:650:5
        #     >     = note: private method defined here

        #     ```
        # - flare 0.10.0: uses a version of serde_derive which doesn't cross compile in nixpkgs
        #   - same error as 0.9.0 once serde_derive is downgraded to 1.0.171
        # - flare 0.9.3: uses a version of serde_derive which doesn't cross compile in nixpkgs
        #   - same error as 0.9.0 once serde_derive is downgraded to 1.0.171
        # - flare 0.9.2: uses a version of serde_derive which doesn't cross compile in nixpkgs
        #   - same error as 0.9.0 once serde_derive is downgraded to 1.0.171
        # - flare 0.9.1: uses a version of serde_derive (1.0.175) which doesn't cross compile in nixpkgs
        # - flare 16acc70ceb6e80eb2d87a92e72e2727e8b98b4db  (last rev before serde_derive 1.0.175): same error as 0.9.0
        # - flare 0.9.0: deps build but crate itself fails because `mod config` is unknown (i.e. we didn't invoke meson and let it generate config.rs)
        # rev = "0.10.1-beta.6";
        # hash = "sha256-NhQu9gpnweI+kIWh3Mbb9bCQnfgthxocAqDRwG0m2Hg=";
        # rev = "0.10.1-beta.5";
        # hash = "sha256-AAxasck8rm8N73jcJU6qW+zR3qSAH5nsi4hTunSnW8Y=";
        # rev = "0.10.1-beta.4";
        # hash = "sha256-SkHARJ4V8t4dXITH+V36RIfPrWL5Bdju1gahCS2aiWo=";
        # rev = "0.10.1-beta.2";
        # hash = "sha256-xkTM8Jeyb89ZUo2lFKNm8HlTe8BTlO/flZmENRfDEm4=";
        # rev = "0.10.1-beta.1";
        # hash = "sha256-nUR3jnbjMJvI3XbguFLz5yQL3SAXzLkdVwXyhcMeZoc=";
        # rev = "0.10.0";
        # hash = "sha256-+9zpYW9xjLe78c2GRL6raFDR5g+R/JWxQzU/ZS+5JtY=";
        # rev = "0.9.3";
        # hash = "sha256-bTR3Jzzy8dVdBJ4Mo2PYstEnNzBVwiWE8hRBnJ7pJSs=";
        # rev = "0.9.2";
        # hash = "sha256-70OqHCe+NZ0dn1sjpkke5MtXU3bFgpwkm0TYlbXOUl8=";
        # rev = "16acc70ceb6e80eb2d87a92e72e2727e8b98b4db";
        # hash = "sha256-Lz7h5JUrqBUsvRICW3QacuO8rkeGBY9yroq/Gtb7nMw=";
        # rev = "0.9.0";
        # hash = "sha256-6p9uuK71fJvJs0U14jJEVb2mfpZWrCZZFE3eoZe9eVo=";
      };

      codegenUnits = 16;  # speeds up the build a bit
      outputs = [ "out" ];  # default is "out" and "lib", but that somehow causes cycles
      outputDev = [ "out" ];

      nativeBuildInputs = [
        appstream-glib # for appstream-util
        blueprint-compiler
        desktop-file-utils # for update-desktop-database
        gobject-introspection
        meson
        ninja
        pkg-config
        wrapGAppsHook4
      ];

      buildInputs = [
        gtksourceview5
        libadwaita
        libsecret
        # libspelling  # optional feature. to enable, add it to `rootFeatures` above too.
        protobuf

        # To reproduce audio messages
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
        rust = [ 'rustc', '--target', '${rust.toRustTargetSpec stdenv.hostPlatform}' ]
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
    libadwaita-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ libadwaita ];
    };
    ring = attrs: attrs // {
      # CARGO_MANIFEST_LINKS = "ring_core_0_17_5";
      postPatch = (attrs.postPatch or "") + ''
        substituteInPlace build.rs --replace \
          'links = std::env::var("CARGO_MANIFEST_LINKS").unwrap();' 'links = "ring_core_0_17_5".to_string();'
      '';
    };
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
    crateConfigs = cargoNix.internal.crates;
    runTests = false;
  };
in builtCrates.crates.flare.overrideAttrs (super: {
  passthru = (super.passthru or {}) // {
    inherit (builtCrates) crates;
  };
})
