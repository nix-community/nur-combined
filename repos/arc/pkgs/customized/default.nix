let
  packages = {
    pass-arc = { pass, pass-extension-meta, pass-extension-arc-b2, hostPlatform }: let
      pass-wrapped = pass.withExtensions (ext: [
        ext.pass-otp
        pass-extension-meta
        pass-extension-arc-b2
      ]);
    in pass-wrapped.overrideAttrs (old: {
      doInstallCheck = !hostPlatform.isDarwin;
    });

    nix-readline = { nix, readline, fetchurl, lib }: nix.overrideAttrs (old: {
      pname = "nix-readline";
      buildInputs = old.buildInputs ++ [ readline ];
      patches = old.patches or [] ++ lib.optional (lib.versionOlder nix.version "2.9") [
        (fetchurl {
          name = "readline-completion.patch";
          url = "https://github.com/arcnmx/nix/commit/f4d1453c2b86aa576f1a707d47eb2174fd7e4a90.patch";
          sha256 = "18b3bv0wjkx5hmrmhbzf6rl6swcx8ibk29c5pk4fysjd71rfd5d0";
        }) (fetchurl {
          name = "readline-sigint.patch";
          url = "https://github.com/arcnmx/nix/commit/ac61a78a5471fd781ff7c165e8697c6b24a38d56.patch";
          sha256 = "066dfalcjw38px9qr12p83s0zdacrw3a7n581apgq0rx8yxdp1vn";
        }) (fetchurl {
          name = "readline-history.patch";
          url = "https://github.com/arcnmx/nix/commit/67789e9ff237d0e61de3fb8b05c8424c84493f12.patch";
          sha256 = "11w4bm5ica2czdiank10mrmli78n9lh694zi3zpb4nrkzjlc02kd";
        })
      ] ++ lib.optional (lib.versionAtLeast nix.version "2.9") (fetchurl {
        name = "readline-completion.patch";
        url = "https://github.com/nixos/nix/compare/694b12052a2f3c830daa3acc7696b31a04afe329...arcnmx:ccf9184e142ce26465a0d59476ed35d47f1425d1.patch";
        sha256 = "sha256-Np0SnSX13utWt33w7VsZAkw4ZiXUgy6GDvcwj+iOvCM";
      }) ++ lib.optional (lib.versionOlder nix.version "2.3.10") (fetchurl {
        name = "json-uescape.patch";
        url = "https://github.com/nixos/nix/commit/52a8f9295b828872586c5b9e5587064a25dae9b2.patch";
        sha256 = "1dby05qwzxgiih6h2ka424qd7ia4krwxl4b8h96frv2v304lnrxl";
      });
      EDITLINE_LIBS = "${readline}/lib/libreadline${nix.stdenv.hostPlatform.extensions.sharedLibrary}";
      EDITLINE_CFLAGS = "-DREADLINE";
      doInstallCheck = false; # old.doInstallCheck or false && !nix.stdenv.isDarwin;
    });

    nix-readline-2_3 = { nix-readline, nix_2_3 ? nix, nix }: nix-readline.override {
      nix = nix_2_3;
    };

    rink-readline = { lib, rink, rustPlatform, fetchpatch }: rustPlatform.buildRustPackage {
      pname = "${rink.pname}-readline";
      inherit (rink) src version nativeBuildInputs buildInputs doCheck;

      patches = rink.patches or [ ] ++ [ (fetchpatch {
        url = "https://github.com/kittywitch/rink-rs/commit/d69635621575af36dc1a4802843e085b4e66c903.patch";
        sha256 = "19ifgzp9fhga210rljs0kbxm8fr6hh5k377l1mkfrm9x1ypyd1ik";
      }) ];

      cargoPatches = rink.cargoPatches or [ ] ++ [ (fetchpatch {
        url = "https://github.com/kittywitch/rink-rs/commit/c33df70c8c115d8b34062d6835b69a7c5e00a33c.patch";
        sha256 = "1rd0r7j6dvi6m7h7qhhw7870kbnj7x64ba9w8hzaklw4yh8l82v3";
      }) ];

      cargoSha256 = "1chxf0rgdps21rm3p2c0yn9z0gvzx095n74ryiv89y0d1gka5jy6";
      meta = rink.meta or { } // {
        broken = rink.meta.broken or false || true;
      };
    };

    gir-rs-0_14 = { gir-rs, fetchFromGitHub, rustPlatform }: rustPlatform.buildRustPackage rec {
      inherit (gir-rs) pname meta;
      version = "0.14-2021-10-08";
      src = fetchFromGitHub {
        owner = "gtk-rs";
        repo = pname;
        rev = "8891a2f2c34ba87828eddcc292f7bcbaab72b5de";
        sha256 = "038af19w95a0bdn7dsgqxvb0lfxf1bxlqdcypasknj7cpimkjwg8";
      };
      cargoSha256 = "0vx5zv8p0dnayvrz75d332c7xf1mn5xhcknc4qvbhjyvr9gjla8v";

      postPatch = ''
        rm build.rs
        sed -i '/build = "build\.rs"/d' Cargo.toml
        echo "pub const VERSION: &str = \"$version\";" > src/gir_version.rs
      '';
    };

    rnnoise-plugin-extern = { stdenv, rnnoise-plugin, rnnoise, ladspaH, pkg-config }: rnnoise-plugin.overrideAttrs (old: rec {
      nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkg-config ];
      buildInputs = old.buildInputs or [ ] ++ [ rnnoise ladspaH ];

      patches = old.patches or [ ] ++ [ ./rnnoise-plugin.diff ];

      postPatch = old.postPatch or "" + ''
        rm src/ladspa_plugin/ladspa.h
        substituteInPlace src/ladspa_plugin/CMakeLists.txt \
          --replace "ladspa.h" ""
      '';

      meta = old.meta or { } // {
        broken = old.meta.broken or false || stdenv.isDarwin;
      };
    });

    rnnoise-plugin-develop = { rnnoise-plugin-extern, fetchFromGitHub }: rnnoise-plugin-extern.overrideAttrs (old: rec {
      version = "2021-05-21";
      src = fetchFromGitHub {
        owner = "werman";
        repo = "noise-suppression-for-voice";
        rev = "89496c24cbc7d8660609f9add5560bf33d78b737";
        sha256 = "09xqxph6gs81sgcy5zyik8yq51flqq9j0jf5k945sdl4mlva2325";
      };
    });

    imv-develop = { imv, fetchFromGitHub, fetchpatch }: imv.overrideAttrs (old: {
      version = "2021-07-29";
      src = fetchFromGitHub {
        owner = "eXeC64";
        repo = "imv";
        rev = "b194997c20fb1ade3aa2828676ca85a2738a8f3e";
        sha256 = "1jp5glqigq6mq6awamja9av83imsrp2c7731rprflvrj6i7sff7z";
      };
    });

    i3gopher-sway = { i3gopher }: i3gopher.override {
      enableI3 = false;
      enableSway = true;
    };

    i3gopher-i3 = { i3gopher }: i3gopher.override {
      enableI3 = true;
      enableSway = false;
    };

    notmuch-arc = { lib, notmuch, coreutils, hostPlatform }: let
      drv = notmuch.override {
        withEmacs = false;
      };
    in drv.overrideAttrs (old: {
      pname = "notmuch-arc";

      doCheck = false;

      meta = old.meta or {} // {
        broken = old.meta.broken or false || hostPlatform.isDarwin;
      };
    });

    vim_configurable-pynvim = { lib, vim_configurable, python3 }: (vim_configurable.override {
      # vim with python3
      python3 = python3.withPackages(ps: with ps; [ pynvim ]);
      wrapPythonDrv = true;
      guiSupport = "no";
      luaSupport = false;
      multibyteSupport = true;
      ftNixSupport = false; # provided by "vim-nix" plugin
      # TODO: fully disable X11?
    });

    rxvt-unicode-arc = { rxvt-unicode ? null, rxvt-unicode-unwrapped, rxvt-unicode-plugins ? { } }: let
      drv = (rxvt-unicode.override {
        rxvt-unicode-unwrapped = rxvt-unicode-unwrapped;
        configure = { availablePlugins, ... }: {
          plugins = with rxvt-unicode-plugins; with availablePlugins; [
            perl
            perls
            #font-size ?
            theme-switch
            vtwheel
            osc-52
            xresources-256
          ];
        };
      }).overrideAttrs (old: {
        pname = "rxvt-unicode-arc";
        meta = old.meta or {} // {
          broken = old.meta.broken or false || rxvt-unicode-unwrapped.meta.broken or false;
        };
      });
    in if rxvt-unicode-unwrapped.meta.broken or false then rxvt-unicode-unwrapped
    else drv;

    bitlbee-libpurple = { bitlbee }: bitlbee.override { enableLibPurple = true; };

    rust-analyzer-unwrapped-mimalloc = { rust-analyzer-unwrapped }: let
      drv = rust-analyzer-unwrapped.override {
        useMimalloc = true;
        doCheck = false;
      };
    in drv;

    ddclient-develop = { ddclient, autoreconfHook, makeWrapper, fetchFromGitHub, fetchpatch }: let
      drv = ddclient.overrideAttrs (old: {
        version = "2022-01-13";
        src = fetchFromGitHub {
          owner = "ddclient";
          repo = "ddclient";
          rev = "17160fb016448106d21742e53404f9e7a16348fc";
          sha256 = "1izl028pbihii9zirj80l31gnbsk5bvg6j81p675sz9kxvmjj9nb";
        };
        patches = old.patches or [ ] ++ [
          ./ddclient-nodaemon.patch
        ];
        preConfigure = ''
          touch Makefile.PL
        '';
        installPhase = "";
        postInstall = old.postInstall or "" + ''
          mv $out/bin/ddclient $out/bin/.ddclient
          makeWrapper $out/bin/.ddclient $out/bin/ddclient \
            --prefix PERL5LIB : $PERL5LIB \
            --argv0 ddclient
        '';
        nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [
          autoreconfHook makeWrapper
        ];
      });
    in drv;

    mumble-develop = { fetchFromGitHub, lib, mumble, libpulseaudio, alsa-lib, pipewire, libopus, libjack2, celt_0_7, nlohmann_json, microsoft_gsl, ninja, qt5, qtspeechSupport ? false, celtSupport ? true }: let
      drv = mumble.override {
        grpcSupport = true;
        speechdSupport = true;
        jackSupport = true;
      };
      version = "2022-04-01";
      runtimeDependencies = [ libpulseaudio libopus libjack2 pipewire alsa-lib ];
    in with lib; drv.overrideAttrs (old: {
      pname = "mumble-develop";
      inherit version;

      src = fetchFromGitHub {
        owner = "mumble-voip";
        repo = "mumble";
        rev = "7a6cbc8046009b773aafb1ea1501f7a320e8d871";
        sha256 = "1870bbr0x2djyhgm8km37kn262w8jh8p0b49975ajscnjr8hw4i0";
        fetchSubmodules = false;
      };

      meta = old.meta or { } // {
        broken = old.meta.broken or false || isNixpkgsStable;
      };

      patches = [ ];
      nativeBuildInputs = old.nativeBuildInputs ++ [ ninja ];
      buildInputs = old.buildInputs ++ runtimeDependencies ++ [ nlohmann_json microsoft_gsl ]
        ++ optional celtSupport celt_0_7
        ++ optional qtspeechSupport qt5.qtspeech;
      qtWrapperArgs = old.qtWrapperArgs or [ ] ++ [
        "--prefix" "LD_LIBRARY_PATH" ":" (makeLibraryPath runtimeDependencies)
      ];
      postFixup = null;
      cmakeFlags = [
        "-Dserver=OFF"
        "-DRELEASE_ID=${version}"
        "-Dbundled-opus=OFF"
        "-Dbundled-celt=${if celtSupport then "OFF" else "ON"}"
        "-Dbundled-speex=OFF"
        "-Dbundled-rnnoise=OFF"
        "-Dbundled-json=OFF"
        "-Dbundled-gsl=OFF"
        "-Dportaudio=OFF"
        "-Dqtspeech=${if qtspeechSupport then "ON" else "OFF"}"
        "-Dembed-qt-translations=OFF"
        "-Dbundle-qt-translations=OFF"
        "-Dupdate=OFF"
        "-Dtracy=OFF" "-DTRACY_ON_DEMAND=OFF"
        "-Dwarnings-as-errors=OFF"
        "-Doverlay-xcompile=OFF"
      ];

      postPatch = old.postPatch or "" + ''
        echo '
          pkg_search_module(PIPEWIRE IMPORTED_TARGET libpipewire-0.3)
          target_link_libraries(mumble_client_object_lib PRIVATE PkgConfig::PIPEWIRE)
        ' >> src/mumble/CMakeLists.txt

        sed -i src/CMakeLists.txt \
          -e '/add_subdirectory.*tracy/d' \
          -e '/disable_warnings_for.*tracy/d' \
          -e '/target_link_libraries.*Tracy/d'
        sed -i src/mumble/CMakeLists.txt \
          -e /set_target_properties.rnnoise/d \
          -e /install_library.rnnoise/d
        sed -i cmake/qt-utils.cmake \
          -e /include.FindPythonInterpreter/d
        sed -i src/mumble/{CELTCodec.h,AudioOutputSpeech.h,AudioOutput.cpp,AudioInput.cpp} \
          -e s-celt\\.h-celt/celt.h-

        rm -r 3rdparty/{jack,opus,pipewire,portaudio,pulseaudio,*-src}
      '';

      installPhase = ''
        runHook preInstall

        cmake --install .

        runHook postInstall
      '';
    });

    weechat-arc = { lib, wrapWeechat, weechat-unwrapped, weechatScripts, python3Packages }: let
      filterBroken = lib.filter (s: ! s.meta.broken or false && s.meta.available or true); # matrix-nio is often broken
      weechat-wrapped = (wrapWeechat.override { inherit python3Packages; }) weechat-unwrapped {
        configure = { availablePlugins, ... }: {
          plugins = with availablePlugins; [
            (python.withPackages (ps: with ps; filterBroken [
              weechat-matrix
            ]))
          ];
          scripts = with weechatScripts; filterBroken [
            weechat-go auto_away autoconf weechat-autosort colorize_nicks unread_buffer urlgrab vimode-develop weechat-matrix
          ];
        };
      };
    in weechat-wrapped.overrideAttrs (old: {
      pname = "weechat-arc";
      meta = old.meta // {
        broken = old.meta.broken or false || weechat-unwrapped.stdenv.isDarwin;
      };
    });

    picom-next = { picom, fetchFromGitHub, lib }: picom.overrideAttrs (old: {
      version = "2021-04-13";
      src = fetchFromGitHub {
        owner = "yshui";
        repo = "picom";
        rev = "7ba87598c177092a775d5e8e4393cb68518edaac";
        sha256 = "0za3ywdn27dzp7140cpg1imbqpbflpzgarr76xaqmijz97rv1909";
      };
    });

    luakit-develop = { fetchFromGitHub, luakit, lib }: luakit.overrideAttrs (old: rec {
      pname = "luakit-develop";
      version = "2021-03-23";
      src = fetchFromGitHub {
        owner = "luakit";
        repo = "luakit";
        rev = "cb591ba9a466140559a5d9fcd5652b8aea13d80c";
        sha256 = "0yh8a1pr5x9k04kji9232p13fnp7gslyz74g4s2a29wxkrpbqwry";
        fetchSubmodules = true; # not actually used but otherwise hash is unstable due to a nixpkgs bug?
      };
      enableParallelBuilding = true;
      patches = old.patches or [] ++ [ ./luakit-nodoc.patch ];
      meta = old.meta // {
        broken = old.meta.broken or false || luakit.stdenv.isDarwin;
      };
    });

    swaylock-effects-develop = { fetchFromGitHub, swaylock-effects, fetchpatch }: swaylock-effects.overrideAttrs (old: rec {
      version = "2021-05-23";

      src = fetchFromGitHub {
        owner = "mortie";
        repo = "swaylock-effects";
        rev = "a8fc557b86e70f2f7a30ca9ff9b3124f89e7f204";
        sha256 = "0f9571blnn7lg317js1j1spc5smz69i5aw6zkhskkm5m633rrpqq";
      };

      patches = [
        (fetchpatch {
          name = "use-font-size-for-date-if-present";
          url = "https://patch-diff.githubusercontent.com/raw/gavinbeatty/swaylock-effects/pull/1.patch";
          sha256 = "1m42mb2gawkjf9svbhbdh7r1mfnyy8rxaaw19qns6i428aa4ykzx";
        })
      ];
    });

    electrum-cli = { lib, electrum }: let
      electrum-cli = electrum.override { enableQt = false; };
    in electrum-cli.overrideAttrs (old: {
      pname = "electrum-cli";
      meta = old.meta // {
        broken = old.meta.broken or false || electrum.stdenv.isDarwin;
      };
      passthru = old.passthru or { } // {
        ci.warn = true;
      };
    });

    duc-cli = { lib, duc }: let
      duc-cli = duc.override { enableCairo = false; };
    in duc-cli.overrideAttrs (old: {
      pname = "duc-cli";
      meta = old.meta // {
        broken = old.meta.broken or false;
      };
    });

    syncplay-cli = { syncplay }: let
      syncplay-cli = syncplay.override {
        qt5 = {
          wrapQtAppsHook = null;
        };
        pyside2 = null;
      };
    in syncplay-cli.overrideAttrs (old: {
      postFixup = "wrapPythonPrograms";
    });

    jimtcl-minimal = { lib, hostPlatform, tcl, jimtcl, readline }: (jimtcl.override { SDL = null; SDL_gfx = null; sqlite = null; }).overrideAttrs (old: {
      pname = "jimtcl-minimal";
      NIX_CFLAGS_COMPILE = "";
      configureFlags = with lib; filter (f: !hasSuffix "sqlite3" f && !hasSuffix "sdl" f) old.configureFlags;
      propagatedBuildInputs = old.propagatedBuildInputs or [] ++ [ readline ];
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [ tcl ];

      doCheck = !hostPlatform.isDarwin;
    });

    mpd-youtube-dl = { lib, mpd, fetchpatch, makeWrapper, youtube-dl }: mpd.overrideAttrs (old: let
      patchVersion =
        if lib.versionOlder old.version "0.22" then "0.21.25"
        else if lib.versionOlder old.version "0.22.1" then "0.22"
        else if lib.versionOlder old.version "0.22.6" then "0.22.2"
        else if lib.versionOlder old.version "0.22.7" then "0.22.6"
        else if lib.versionOlder old.version "0.22.10" then "0.22.7"
        else if lib.versionOlder old.version "0.23" then "0.22.10"
        else if lib.versionOlder old.version "0.23.8" then "0.23.2"
        else "0.23.8";
    in {
      pname = "${mpd.pname}-youtube-dl";

      patches = old.patches or [] ++ [ (fetchpatch {
        name = "mpd-youtube-dl.diff";
        url = "https://github.com/MusicPlayerDaemon/MPD/compare/v${patchVersion}...arcnmx:ytdl-${patchVersion}.diff";
        sha256 =
          if patchVersion == "0.21.25" then "16n1fx505k6pprf753j6xzwh25ka4azwx49sz02wy68qdx8wa586"
          else if patchVersion == "0.22" then "07vladkk80mnc23ybi80wn17cfxwl8pvv5cg0rl17avyymljspax"
          else if patchVersion == "0.22.2" then "19ia0my2id84arxzzdgccp8r50jyi6z8355qpi3sn8i77phdbihh"
          else if patchVersion == "0.22.6" then "16fzj27m9xyh3aqnmfgwrbfr4rcljw7z7vdszlfgq8zj1z8zrdir"
          else if patchVersion == "0.22.7" then "1way27q3m9zzps2wkmjsqk22grp727fzky7ds30gdnzn4dygbcrp"
          else if patchVersion == "0.22.10" then "14sndl4b8zaf7l8ia4n6qq6l4iq5d9h7f495p0dzchw6ck536nhq"
          else if patchVersion == "0.23.2" then "sha256-rFN/w/V/Mz+IQbkfZf1CD4Gpm4kd9bVwHOZXFOpXBAM"
          else if patchVersion == "0.23.8" then "sha256-vfjtjAaFG4JgxpnrSytWb/BytgXOrdRz3oE9/ZusEh0="
          else lib.fakeSha256;
      }) ];

      mesonFlags = old.mesonFlags ++ [ "-Dyoutube-dl=enabled" ];
      nativeBuildInputs = old.nativeBuildInputs ++ [ makeWrapper ];
      depsPath = lib.makeBinPath [ youtube-dl ];
      postInstall = ''
        wrapProgram $out/bin/mpd --prefix PATH : $depsPath
      '';

      meta = old.meta or {} // {
        broken = old.meta.broken or false || lib.versionOlder old.version "0.21" || mpd.stdenv.isDarwin;
      };
    });

    libmpdclient-buffer = { mpd_clientlib, libmpdclient ? mpd_clientlib }: libmpdclient.overrideAttrs (old: {
      pname = "${old.pname}-buffer";

      # raise mpd line length limit from 4KB to 32KB
      patches = old.patches or [ ] ++ [ ./mpd_clientlib-buffer.patch ];
    });

    qemu-vfio = { qemu, fetchpatch, lib }: (qemu.override {
      gtkSupport = false;
      smartcardSupport = false;
      smbdSupport = true;
      hostCpuTargets = [
        "${qemu.stdenv.hostPlatform.qemuArch}-softmmu"
        "aarch64-linux-user" "aarch64-softmmu"
        "arm-linux-user" "arm-softmmu"
      ] ++ lib.optional qemu.stdenv.isx86_64 "i386-softmmu";
    }).overrideAttrs (old: {
      pname = "qemu-vfio";
      patches = old.patches or [] ++ lib.optional (lib.versionAtLeast qemu.version "4.2" && lib.versionOlder qemu.version "5.0") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/64kramsystem/qemu-pinning/commit/4e4fe6402e9e4943cc247a4ccfea21fa5f608b30.patch";
        sha256 = "12na0z8n48aiwiv96xn37b0i7i8kj5ph0rk8xbpm9jrzmi5rd4l1";
      }) ++ lib.optional (lib.versionAtLeast qemu.version "5.0" && lib.versionOlder qemu.version "5.1") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/64kramsystem/qemu-pinning/commit/76241abfe8c5c71bc02a7e268ff3d3ca0734308c.patch";
        sha256 = "1h4rm68vr4b2lpj7vi3wr5692kx4w4iccjasl86ldjsl40yfmc47";
      }) ++ lib.optional (lib.versionAtLeast qemu.version "5.1" && lib.versionOlder qemu.version "5.2") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/64kramsystem/qemu-pinning/commit/d166e4040f016fb6aa6ffa67abd12d9b33ac23c5.patch";
        sha256 = "0mylj1h81s160hzmk0bmfwmdgdlca0wvxl36734s4z966b6ni8jn";
        excludes = [ "roms/seabios" ];
      }) ++ lib.optional (lib.versionAtLeast qemu.version "5.2" && lib.versionOlder qemu.version "6.0") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/64kramsystem/qemu-pinning/commit/fc8e850f53be9766056d90274cef04c8bc878131.patch";
        sha256 = "13g5rxrrr60vpprkcfgslkxgcyb83qh0wwqr1kycaqbfwjz958h8";
      }) ++ lib.optional (lib.versionAtLeast qemu.version "6.0" && lib.versionOlder qemu.version "6.1") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/64kramsystem/qemu-pinning/commit/61050b3f3400cd8d984b4db63d104e2480682227.patch";
        sha256 = "0cpg18pq2a344l3x589ab7sg386smp6fb6iyj768qzflsdwn2fmq";
      }) ++ lib.optional (lib.versionAtLeast qemu.version "6.1" && lib.versionOlder qemu.version "6.2") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/64kramsystem/qemu-pinning/commit/e3d3d8a836d5dd4d385def2959abae0eb23a1d69.patch";
        sha256 = "04lbhhp2dcy38zzy4qx2w55af2j1s144ibka6d0k9pqya0d040d5";
      }) ++ lib.optional (lib.versionAtLeast qemu.version "6.2" && lib.versionOlder qemu.version "7.0") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/arcnmx/qemu/commit/3f466242dc8f7cbefdc2d56a71e4f8a9682eee2a.patch";
        sha256 = "04g7m73d8jynfi1lric0vmkhbgdh24vclx08nal439y8qnfjzya9";
      }) ++ lib.optional (lib.versionAtLeast qemu.version "7.0") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/64kramsystem/qemu-pinning/commit/851970fe429b9ff8c24e935864bb8e7c235b1187.patch";
        sha256 = "1732rxx1wsrx9nycpja4ixxhqn9sxv9sgdgylgqqybbzcl716hkg";
      }) ++ lib.optional (qemu.version == "7.0.0") (fetchpatch {
        # https://gitlab.com/qemu-project/qemu/-/issues/997
        name = "iothread-spin.patch";
        url = "https://github.com/arcnmx/qemu/commit/fd3a94d18d8a8133ccdeb7048e8da7e84ce232db.patch";
        sha256 = "0rqprr1p9b7r07q9gr14y6z4i11nx7lr9x9ggci1lrwm89kj14nw";
      }) ++ lib.singleton (fetchpatch {
        name = "qemu-smb-symlinks.patch";
        url = "https://github.com/arcnmx/qemu/commit/cc4ea56e68242cb4b8e107f07a9601f64916958e.patch";
        sha256 = "sha256-xayO0creV7+g1yrgFP35cCPWkDFOB2Qve3HsCjJKbfg=";
      });

      meta = old.meta or {} // {
        platforms = lib.platforms.linux;
      };
    });

    scream-arc = { scream, fetchpatch, fetchFromGitHub, lib }: scream.overrideAttrs (old: {
      pname = "scream-arc";
      version = "2022-06-19";
      src = fetchFromGitHub {
        owner = "duncanthrax";
        repo = "scream";
        rev = "375efee3f3b9e2af1d03dc8531ee767f803b72e0";
        sha256 = "sha256-5r6ciGLGRdUg6702CxEms1LO2YnqxY4+cKpTe7chMe0=";
      };
      patches = old.patches or [] ++ [
        (fetchpatch {
          # https://github.com/arcnmx/scream/commits/shmem-catch-up
          url = "https://github.com/arcnmx/scream/commit/756ded53e590d969fdd23871400f7b8c75317ce4.patch";
          sha256 = "1z96fcvhgnwkbinv3ix3dkm9fhy8fvxvmhx45zpg4nig2snqyqmb";
        })
        (fetchpatch {
          url = "https://github.com/arcnmx/scream/commit/fd8ae24a5261bbdb901ec1aed9fa8960741b6c46.patch";
          sha256 = "18pavs8kdqsj43iapfs5x639w613xhahd168c2j86sizy04390ga";
        })
      ];
      meta = old.meta or { } // {
        mainProgram = "scream";
      };
    });

    lieer-develop = { lieer, fetchFromGitHub }: lieer.overrideAttrs (old: {
      version = "2021-10-17";
      src = fetchFromGitHub {
        owner = "gauteh";
        repo = "lieer";
        rev = "87e85ef546223d6a745e3fe95972fd1025c4c009";
        sha256 = "05nhjg5bckxwx2zsshznlllb22im6lqhb6jlf9s6mrnz4ag62ig3";
      };
    });

    xkeyboard-config-arc = { xkeyboard_config, fetchpatch, utilmacros, autoreconfHook }: xkeyboard_config.overrideAttrs (old: rec {
      pname = "xkeyboard-config-arc";
      #name = "${pname}-${old.version}";
      patches = old.patches or [ ] ++ [
        (fetchpatch {
          url = "https://github.com/arcnmx/xkeyboard-config/commit/e6178ff48d0687d730b069fe908b526cbb6bcee8.patch";
          sha256 = "0v8akjczsbk2mv20c5hbq1g2ppy8gsklrypyfacc5rjxqbqpx0d9";
        })
      ];

      nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ autoreconfHook utilmacros ];
    });

    mosh-client = { mosh, stdenvNoCC }: stdenvNoCC.mkDerivation {
      pname = "mosh-client";
      version = mosh.version or (builtins.parseDrvName mosh.name).version;

      inherit mosh;
      buildCommand = ''
        mkdir -p $out/bin
        ln -s $mosh/share $out/
        ln -s $mosh/bin/mosh $mosh/bin/mosh-client $out/bin/
      '';
    };
  };
in packages
