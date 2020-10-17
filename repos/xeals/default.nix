# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Alacritty with the unmerged ligature patches applied.
  alacritty-ligatures = (pkgs.alacritty.override {
    # 0.6.0 requires a minimum of 1.43, and this is the only version on both
    # stable and unstable channels right now.
    inherit (pkgs.rustPackages_1_44) rustPlatform;
  }).overrideAttrs (oldAttrs: rec {
    pname = "${oldAttrs.pname}-ligatures";
    version = "0.6.0.20201015";

    src = pkgs.fetchFromGitHub {
      owner = "zenixls2";
      repo = "alacritty";
      fetchSubmodules = true;
      rev = "30ebb4303229acbfdbbf00a84a9c46973c4e0334";
      sha256 = "1c0951zs1h2d6fjnxixfms3913m1c6yvgmcizgd9gfgx59ghpafi";
    };

    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (pkgs.lib.const {
      name = "${pname}-${version}-vendor.tar.gz";
      inherit src;
      outputHash = "1gi3bvcra56maxcz1a6i1nmzdrfa4mhx6pn1xjbrifv7c6jlxard";
    });

    ligatureInputs = [
      pkgs.fontconfig
      pkgs.freetype
      pkgs.libglvnd
      pkgs.stdenv.cc.cc.lib
      pkgs.xlibs.libxcb
    ];

    buildInputs = (oldAttrs.buildInputs or []) ++ ligatureInputs;

    # HACK: One of the ligature libraries required the C++ stdlib at runtime,
    # and I can't work out a better way to push it to the RPATH.
    postInstall = pkgs.lib.optional (!pkgs.stdenv.isDarwin) ''
      patchelf \
        --set-rpath ${pkgs.lib.makeLibraryPath ligatureInputs}:"$(patchelf --show-rpath $out/bin/alacritty)" \
        $out/bin/alacritty
    '';
  });

  amdgpu-fan = pkgs.callPackage ./pkgs/tools/misc/amdgpu-fan { };

  goModules = pkgs.recurseIntoAttrs rec {
    qt = pkgs.libsForQt512.callPackage ./pkgs/development/go-modules/qt { };
  };

  # A functional Jetbrains IDE-with-plugins package set.
  jetbrains =
    let
      mkJetbrainsPlugins = import ./pkgs/applications/editors/jetbrains/common-plugins.nix {
        inherit (pkgs) callPackage;
      };
      mkIdeaPlugins = import ./pkgs/applications/editors/jetbrains/idea-plugins.nix {
        inherit (pkgs) callPackage;
      };

      builder = import ./pkgs/applications/editors/jetbrains/builder.nix {
        inherit (pkgs) lib;
      };

      jbScope = pkgs.lib.makeScope pkgs.newScope (self: pkgs.lib.makeOverridable
        ({ jetbrainsPlugins ? mkJetbrainsPlugins
         , ideaPlugins ? mkIdeaPlugins
         }: ({ }
          // jetbrainsPlugins // { inherit jetbrainsPlugins; }
          // ideaPlugins // { inherit ideaPlugins; }
          // {
          jetbrainsWithPlugins = builder self;
        }))
        { });
    in
    rec {
      inherit (jbScope) jetbrainsWithPlugins;
      clionWithPlugins = jetbrainsWithPlugins pkgs.jetbrains.clion;
      ideaCommunityWithPlugins = jetbrainsWithPlugins pkgs.jetbrains.idea-community;
      ideaUltimateWithPlugins = jetbrainsWithPlugins pkgs.jetbrains.idea-ultimate;
      plugins = jbScope;
    };

  libhl = pkgs.callPackage ./pkgs/development/libraries/libhl { };

  mopidy-subidy = pkgs.callPackage ./pkgs/applications/audio/mopidy/subidy.nix {
    python3Packages = pkgs.python3Packages // python3Packages;
  };

  pam_gnupg = pkgs.callPackage ./pkgs/os-specific/linux/pam_gnupg { };

  picom-animations = pkgs.picom.overrideAttrs (oldAttrs: {
    pname = "picom-animations";
    src = pkgs.fetchFromGitHub {
      owner = "jonaburg";
      repo = "picom";
      rev = "d718c94";
      sha256 = "165mc53ryyxn2ybkhikmk51ay3k18mvlsym3am3mgr8cpivmf2rm";
    };
  });

  polybar = pkgs.polybar.overrideAttrs (oldAttrs: {
    # Enables an extra button in formatting, indirectly allowing the use of
    # the mouse forward and backward buttons.
    patches = (oldAttrs.patches or [ ]) ++ [ ./pkgs/applications/misc/polybar/9button.patch ];
  });

  python2Packages =
    let
      fixVersion =
        { package
        , version
        , sha256
        , extra ? (oldAttrs: { })
        }: package.overrideAttrs (oldAttrs: rec {
          inherit version;
          src = pkgs.python2Packages.fetchPypi {
            inherit (oldAttrs) pname;
            inherit version sha256;
          };
        } // extra oldAttrs);
    in
    pkgs.recurseIntoAttrs rec {
      colorama_0_3_3 = fixVersion {
        package = pkgs.python2Packages.colorama;
        version = "0.3.3";
        sha256 = "1716z9pq1r5ys3nkg7wdrb3h2f9rmd0zdxpxzmx3bgwgf6xg48gb";
      };

      mutagen_1_30 = fixVersion {
        package = pkgs.python2Packages.mutagen;
        version = "1.30";
        sha256 = "0kv2gjnzbj1w0bswmxm7wi05x6ypi7jk52s0lb8gw8s459j41gyd";
        extra = oldAttrs: {
          patches = [ ];
        };
      };

      pyspotify_2_0_5 = fixVersion {
        package = pkgs.python2Packages.pyspotify;
        version = "2.0.5";
        sha256 = "0y16c024rrvbvfdqj1n0k4b25b1nbza3i7kspg5b0ci2src1rm7v";
      };

      overlay = {
        colorama = colorama_0_3_3;
        mutagen = mutagen_1_30;
        pyspotify = pyspotify_2_0_5;
      };
    };

  python3Packages = pkgs.recurseIntoAttrs {
    py-sonic = pkgs.python3.pkgs.callPackage ./pkgs/development/python-modules/py-sonic { };
  };

  # The one in Nixpkgs still extracts the pre-built Debian package instead
  # of building from source.
  protonmailBridgePackages = pkgs.libsForQt512.callPackage ./pkgs/applications/networking/protonmail-bridge {
    inherit goModules;
  };
  protonmail-bridge = protonmailBridgePackages.protonmail-bridge;
  protonmail-bridge-headless = protonmailBridgePackages.protonmail-bridge-headless;

  radeon-profile-daemon = pkgs.libsForQt5.callPackage ./pkgs/tools/misc/radeon-profile-daemon { };

  samrewritten = pkgs.callPackage ./pkgs/tools/misc/samrewritten { };

  spotify-ripper = pkgs.callPackage ./pkgs/tools/misc/spotify-ripper {
    # NOTE: Not available in 20.03. Specifying it this way lets me cheat the
    # build auto-failing on 20.03 because of the attribute not existing.
    inherit (pkgs) fdk-aac-encoder;
    python2Packages = pkgs.python2Packages // python2Packages.overlay;
  };

  zsh-z = pkgs.callPackage ./pkgs/shells/zsh/zsh-z { };
}
