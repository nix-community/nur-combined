# Cargo.nix and crate-hashes.json were created with:
# - `nix run '.#crate2nix' -- generate -f ~/ref/repos/news-flash/news_flash_gtk/Cargo.toml`
# - Cargo.nix is manually patched to fix build errors: apply the effects of `crate2NixOverrides` below inline
#
# the generated Cargo.nix points to an impure source (~/ref/...), but that's resolved by overriding `src` below.
{
  appstream-glib,
  blueprint-compiler,
  clapper,
  defaultCrateOverrides,
  desktop-file-utils,
  fetchFromGitLab,
  gst_all_1,
  lib,
  libadwaita,
  libxml2,
  meson,
  ninja,
  pkg-config,
  pkgs,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:
let
  extraCrateOverrides = {
    news_flash_gtk = attrs: attrs // {
      src = fetchFromGitLab {
        domain = "gitlab.com";
        owner = "news-flash";
        repo = "news_flash_gtk";
        rev = "refs/tags/v.3.3.4";
        hash = "sha256-N9UOvcQvunp9Ws5qQIqmGA/12YRuyj0M3MU1l44t8wU=";
        #VVV fails "use of undeclared crate or module `gtk`"
        # rev = "1c92539a20bc760cf3aed2c658f78c4e6b23c202";  #< 3.2.0-unstable: last commit before clapper
        # hash = "sha256-iF7LwDrgyZB/OJHkdKqV7isQu8anVjrEYpHfOAkljgs=";
        # rev = "refs/tags/v.3.2.0";  #< last release before clapper (i think)
        # hash = "sha256-buXFQ/QAFOcdcywlacySuq8arqPEJIti1nK+yl3yWck=";
      };

      # codegenUnits = 16;  # speeds up the build a bit
      # outputs = [ "out" ];  # default is "out" and "lib", but that somehow causes cycles
      # outputDev = [ "out" ];

      nativeBuildInputs = [
        appstream-glib
        blueprint-compiler
        desktop-file-utils
        meson
        ninja
        pkg-config
        wrapGAppsHook4
      ];

      buildInputs = [
        # clapper
        # glib
        # glib-networking  #< TLS support for loading external content in webkitgtk_6_0 WebView
        # gst_all_1.gst-plugins-bad
        # gst_all_1.gst-plugins-base
        # gst_all_1.gst-plugins-good
        # gst_all_1.gstreamer
        # gtk4
        # libadwaita
        # librsvg  #< SVG support for gdk-pixbuf
        # libxml2
        # openssl
        # sqlite
        # webkitgtk_6_0
        # xdg-utils
      ];
      postPatch = ''
        rm build.rs
      '';

      # mesonFlags = let
      #   # this gets meson to shutup about rustc not producing executables.
      #   # kinda silly though, since we patch out the actual cargo (rustc) invocations.
      #   crossFile = writeText "cross-file.conf" ''
      #   [binaries]
      #   rust = [ 'rustc', '--target', '${stdenv.hostPlatform.rust.rustcTargetSpec}' ]
      # '';
      # in
      #   lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
      #     "--cross-file=${crossFile}"
      #   ];

      # postPatch = ''
      #   rm build.rs
      #   # patch so meson will invoke our `crate2nix_cmd.sh` instead of cargo
      #   substituteInPlace src/meson.build \
      #     --replace-fail 'cargo_options,'  "" \
      #     --replace-fail "cargo, 'build',"  "'bash', 'crate2nix_cmd.sh'," \
      #     --replace-fail "'src' / rust_target" "'src/bin'"
      # '';
      # postConfigure = ''
      #   # copied from <pkgs/development/tools/build-managers/meson/setup-hook.sh>
      #   mesonFlags="--prefix=$prefix $mesonFlags"
      #   mesonFlags="\
      #       --libdir=''${!outputLib}/lib --libexecdir=''${!outputLib}/libexec \
      #       --bindir=''${!outputBin}/bin --sbindir=''${!outputBin}/sbin \
      #       --includedir=''${!outputInclude}/include \
      #       --mandir=''${!outputMan}/share/man --infodir=''${!outputInfo}/share/info \
      #       --localedir=''${!outputLib}/share/locale \
      #       -Dauto_features=''${mesonAutoFeatures:-enabled} \
      #       -Dwrap_mode=''${mesonWrapMode:-nodownload} \
      #       $mesonFlags"

      #   mesonFlags="''${crossMesonFlags+$crossMesonFlags }--buildtype=''${mesonBuildType:-plain} $mesonFlags"

      #   echo "meson flags: $mesonFlags ''${mesonFlagsArray[@]}"

      #   meson setup build $mesonFlags "''${mesonFlagsArray[@]}"
      #   cd build
      # '';
      # preBuild = ''
      #   build_bin() {
      #     # build_bin is what buildRustCrate would use to invoke rustc, but we want to drive the build
      #     # with meson instead. however, meson doesn't know how to plumb our rust dependencies into cargo,
      #     # so we still need to use build_bin for just one portion of the build.
      #     #
      #     # so, this mocks out the original build_bin:
      #     # - we patch upstream flare to call our `crate2nix_cmd.sh` when it wants to compile the rust.
      #     # - we don't actually invoke meson (ninja) at all here, but rather in the `installPhase`.
      #     #   if we invoked it here, the whole build would just get re-done in installPhase anyway.
      #     #
      #     # rustc invocation copied from <pkgs/build-support/rust/build-rust-crate/lib.sh>
      #     crate_name_=flare
      #     main_file=../src/main.rs
      #     fix_link="-C linker=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
      #     cat >> crate2nix_cmd.sh <<EOF
      #       set -x
      #       rmdir target/bin
      #       rmdir target
      #       ln -s ../target .
      #       rustc \
      #       $fix_link \
      #       --crate-name $crate_name_ \
      #       $main_file \
      #       --crate-type bin \
      #       $BIN_RUSTC_OPTS \
      #       --out-dir target/bin \
      #       -L dependency=target/deps \
      #       $LINK \
      #       $EXTRA_LINK_ARGS \
      #       $EXTRA_LINK_ARGS_BINS \
      #       $EXTRA_LIB \
      #       --cap-lints allow \
      #       $BUILD_OUT_DIR \
      #       $EXTRA_BUILD \
      #       $EXTRA_FEATURES \
      #       $EXTRA_RUSTC_FLAGS \
      #       --color ''${colors}
      # EOF
      #   }
      # '';
      # installPhase = "ninjaInstallPhase";
    };

    # clapper = attrs: attrs // {
    #   # XXX: newsflash uses clapper-sys (clapper-rs) from here: <https://gitlab.gnome.org/JanGernert/clapper-rs>
    #   nativeBuildInputs = [ pkg-config ] ++ clapper.nativeBuildInputs;
    #   buildInputs = [ clapper gtk4 ] ++ clapper.buildInputs;
    #   # inherit (clapper) nativeBuildInputs buildInputs;
    # };
    clapper-gtk-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ clapper ] ++ clapper.buildInputs;
    };
    clapper-sys = attrs: attrs // {
      # XXX: newsflash uses clapper-sys (clapper-rs) from here: <https://gitlab.gnome.org/JanGernert/clapper-rs>
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ clapper ] ++ clapper.buildInputs;
      # inherit (clapper) nativeBuildInputs buildInputs;
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
    libadwaita-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ libadwaita ];
    };
    libxml = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ libxml2 ];
    };
    javascriptcore6-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ webkitgtk_6_0 ];
    };
    rav1e = attrs: attrs // {
      # TODO: `rav1e` is actually packaged in nixpkgs as a library:
      #   is there any way i can reuse that?
      CARGO_ENCODED_RUSTFLAGS = "";
    };
    webkit6-sys = attrs: attrs // {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ webkitgtk_6_0 ];
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
    clapper = crates.clapper // {
      workspace_member = "libclapper-rs";
    };
    clapper-gtk = crates.clapper // {
      workspace_member = "libclapper-gtk-rs";
    };
    clapper-gtk-sys = crates.clapper-gtk-sys // {
      workspace_member = "libclapper-gtk-rs/sys";
    };
  };

  cargoNix = import ./Cargo.nix {
    inherit pkgs;
    release = false;  #< XXX(2023/12/06): `release=true` is incompatible with cross compilation
    # rootFeatures = [ "default" ];
    rootFeatures = [ ];  #< avoids --cfg feature="default", simplifying the rustc CLI so that i can pass it around easier
    defaultCrateOverrides = defaultCrateOverrides';
  };
in cargoNix.rootCrate
#   builtCrates = cargoNix.internal.builtRustCratesWithFeatures {
#     packageId = "news_flash_gtk";
#     features = [ "default" ];
#     buildRustCrateForPkgsFunc = pkgs: pkgs.buildRustCrate.override {
#       defaultCrateOverrides = defaultCrateOverrides';
#     };
#     crateConfigs = crate2NixOverrides cargoNix.internal.crates;
#     runTests = false;
#   };
# in builtCrates.crates.news_flash_gtk.overrideAttrs (super: {
#   passthru = (super.passthru or {}) // {
#     inherit (builtCrates) crates;
#   };
# })
