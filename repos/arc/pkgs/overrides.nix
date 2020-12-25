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
      buildInputs = old.buildInputs ++ [ readline ];
      patches = old.patches or [] ++ [
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
      ] ++ lib.optional (lib.versionOlder nix.version "2.3.10") (fetchurl {
        name = "json-uescape.patch";
        url = "https://github.com/nixos/nix/commit/52a8f9295b828872586c5b9e5587064a25dae9b2.patch";
        sha256 = "1dby05qwzxgiih6h2ka424qd7ia4krwxl4b8h96frv2v304lnrxl";
      });
      EDITLINE_LIBS = "${readline}/lib/libreadline${nix.stdenv.hostPlatform.extensions.sharedLibrary}";
      EDITLINE_CFLAGS = "-DREADLINE";
      doInstallCheck = false; # old.doInstallCheck or false && !nix.stdenv.isDarwin;
    });

    notmuch = { lib, notmuch, coreutils }@args: let
      notmuch = args.notmuch.super or args.notmuch;
      drv = notmuch.override {
        withEmacs = false;
      };
    in drv.overrideAttrs (old: {
      doCheck = false;

      postInstall = ''
        ${old.postInstall or ""}
        make -C bindings/ruby exec_prefix=$out \
          SHELL=$SHELL \
          $makeFlags ''${makeFlagsArray+"''${makeFlagsArray[@]}"} \
          $installFlags ''${installFlagsArray+"''${installFlagsArray[@]}"} \
          install
        mv $out/lib/ruby/vendor_ruby/* $out/lib/ruby/
        rmdir $out/lib/ruby/vendor_ruby
      '';

      meta = old.meta or {} // {
        broken = old.meta.broken or false || notmuch.stdenv.isDarwin;
      };
      passthru = old.passthru or {} // {
        super = notmuch;
      };
    });
    vim_configurable-pynvim = { vim_configurable, python3 }: (vim_configurable.override {
      # vim with python3
      python = python3.withPackages(ps: with ps; [ pynvim ]);
      wrapPythonDrv = true;
      guiSupport = "no";
      luaSupport = false;
      multibyteSupport = true;
      ftNixSupport = false; # provided by "vim-nix" plugin
      # TODO: fully disable X11?
    });

    rxvt-unicode-cvs-unwrapped = { rxvt-unicode-unwrapped ? null, fetchcvs, stdenv }: let
      drv = rxvt-unicode-unwrapped.overrideAttrs (old: rec {
        pname = "rxvt-unicode-cvs";
        version = "2020-02-15";
        enableParallelBuilding = true;
        src = fetchcvs {
          cvsRoot = ":pserver:anonymous@cvs.schmorp.de:/schmorpforge";
          module = "rxvt-unicode";
          date = version;
          sha256 = "0n8z3c8fb1pqph09fnl9msswdw2wqm84xm5kaax6nf514gg05dpx";
        };
        meta = old.meta or {} // {
          broken = old.meta.broken or false || !rxvt-unicode-unwrapped.stdenv.isLinux;
        };
      });
    in if rxvt-unicode-unwrapped == null then stdenv.mkDerivation {
      name = "rxvt-unicode-cvs";
      meta.broken = true;
    } else drv;
    rxvt-unicode-arc = { rxvt-unicode ? null, rxvt-unicode-cvs-unwrapped }: let
      drv = (rxvt-unicode.override {
        rxvt-unicode-unwrapped = rxvt-unicode-cvs-unwrapped;
        configure = { availablePlugins, ... }: {
          plugins = with availablePlugins; [
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
        meta = old.meta or {} // {
          broken = rxvt-unicode-cvs-unwrapped.meta.broken or false;
        };
      });
    in if rxvt-unicode-cvs-unwrapped.meta.broken or false then rxvt-unicode-cvs-unwrapped
    else drv;

    bitlbee-libpurple = { bitlbee }: bitlbee.override { enableLibPurple = true; };

    pidgin-arc = { pidgin, purple-plugins-arc }: let
      wrapped = pidgin.override {
        plugins = purple-plugins-arc;
      };
    in wrapped.overrideAttrs (old: {
      meta = old.meta or {} // {
        broken = pidgin.stdenv.isDarwin;
      };
    });

    buku = { buku }: buku.overrideAttrs (old: {
      doInstallCheck = false;

      passthru = old.passthru or {} // {
        ci = old.passthru.ci or {} // {
          warn = true;
        };
      };
    });

    weechat-arc = { lib, wrapWeechat, weechat-unwrapped, weechatScripts, python3Packages }: let
      weechat-wrapped = wrapWeechat weechat-unwrapped {
        configure = { availablePlugins, ... }: {
          plugins = with availablePlugins; [
            (python.withPackages (ps: with ps; [
              weechat-matrix
            ]))
          ];
          scripts = with weechatScripts; [
            go auto_away autoconf autosort colorize_nicks unread_buffer urlgrab vimode-git weechat-matrix
          ];
        };
      };
    in weechat-wrapped.overrideAttrs (old: {
        meta = old.meta // {
          broken = old.meta.broken or false || weechat-unwrapped.stdenv.isDarwin;
        };
    });

    xdg_utils-mimi = { xdg_utils }: xdg_utils.override { mimiSupport = true; };

    luakit-develop = { fetchFromGitHub, luakit, lib }: luakit.overrideAttrs (old: rec {
      name = "luakit-${version}";
      rev = "818d8f4777657d3bba0447c3baee86c2fe67fabf";
      version = "2020-04-28";
      src = fetchFromGitHub {
        owner = "luakit";
        repo = "luakit";
        inherit rev;
        sha256 = "0jqyv5s07inkdpq5nryk1xfgkamnsnlxg1d5r6mx237y8gy8nax3";
      };
      enableParallelBuilding = true;
      patches = old.patches or [] ++ [ ./public/luakit/nodoc.patch ];
      meta = old.meta // {
        broken = old.meta.broken or false || luakit.stdenv.isDarwin;
      };
    });

    electrum-cli = { lib, electrum }: let
      electrum-cli = electrum.override { enableQt = false; };
    in electrum-cli.overrideAttrs (old: {
      meta = old.meta // {
        broken = old.meta.broken or false || electrum.stdenv.isDarwin;
      };
    });

    duc-cli = { lib, duc }: let
      duc-cli = duc.override { enableCairo = false; };
    in duc-cli.overrideAttrs (old: {
      meta = old.meta // {
        broken = old.meta.broken or false;
      };
    });

    ncpamixer = { ncpamixer, fetchpatch, lib }: let
      segfaultLoopback = fetchpatch {
        url = "https://github.com/fulhax/ncpamixer/pull/49.diff";
        sha256 = "0bnh9xii3j7kvj46hwl87y6fa4x6mi7q7p2fd0rg814i0s9b682s";
      };
    in if ncpamixer.version == "1.3.3.1" then ncpamixer.overrideAttrs (old: {
      patches = old.patches or [] ++ lib.singleton segfaultLoopback;
      enableParallelBuilding = true;
      buildPhase = null;
    }) else ncpamixer;

    yggdrasilctl = { stdenvNoCC, yggdrasil ? null, hostPlatform }: let
      drv = stdenvNoCC.mkDerivation {
        pname = "yggdrasilctl";
        inherit (yggdrasil) version;
        inherit yggdrasil;

        buildCommand = ''
          mkdir -p $out/bin
          ln -s $yggdrasil/bin/yggdrasilctl $out/bin/yggdrasil
        '';

        meta = yggdrasil.meta or {} // {
          broken = yggdrasil.meta.broken or false || hostPlatform.isDarwin;
        };
      };
    in if yggdrasil == null then stdenvNoCC.mkDerivation {
      name = "yggdrasilctl";
      meta.broken = true;
    } else drv;

    yamllint = { python3Packages }: with python3Packages; toPythonApplication yamllint;
    svdtools = { python3Packages }: with python3Packages; toPythonApplication svdtools;
    cargo-download = { lib, hostPlatform, cargo-download, cargo-download-arc }: let
      isBroken = hostPlatform.isDarwin || cargo-download.meta.broken or false == true || !lib.isNixpkgsStable;
    in if isBroken then cargo-download-arc else cargo-download;

    libjaylink = { stdenv, fetchgit, autoreconfHook, pkgconfig, libusb1 }: stdenv.mkDerivation {
      pname = "libjaylink";
      version = "2019-10-03";
      nativeBuildInputs = [ pkgconfig autoreconfHook ];
      buildInputs = [ libusb1 ];

      src = fetchgit {
        #url = "git://git.zapb.de/libjaylink.git"; # appears to be down?
        url = "git://repo.or.cz/libjaylink.git";
        rev = "cfccbc9d6763733f1d14dff3c2dc5b75aaef136b";
        sha256 = "0z3hv2wadbmx8mf7kjfrcgp5ivi5lix0vapg24gykhadgg2a6gcm";
      };
    };

    jimtcl-minimal = { lib, tcl, jimtcl, readline }: (jimtcl.override { SDL = null; SDL_gfx = null; sqlite = null; }).overrideAttrs (old: {
      NIX_CFLAGS_COMPILE = "";
      configureFlags = with lib; filter (f: !hasSuffix "sqlite3" f && !hasSuffix "sdl" f) old.configureFlags;
      propagatedBuildInputs = old.propagatedBuildInputs or [] ++ [ readline ];
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [ tcl ];
    });

    openocd-git = {
      openocd
    , fetchgit, autoreconfHook, lib
    , git, jimtcl-minimal ? null, libjaylink ? null, enableJaylink ? libjaylink != null
    }: with lib; openocd.overrideAttrs (old: rec {
      pname = "openocd-git";
      name = "openocd-git-${version}";
      version = "2020-02-09";

      patches = [ ];

      nativeBuildInputs = old.nativeBuildInputs ++ [ autoreconfHook git jimtcl-minimal ];
      buildInputs = old.buildInputs
        ++ optional enableJaylink libjaylink
        ++ optional (jimtcl-minimal != null) jimtcl-minimal;
      configureFlags = filter (f: !hasSuffix "oocd_trace" f) old.configureFlags
        ++ optional (jimtcl-minimal != null) "--disable-internal-jimtcl"
        ++ optional (!enableJaylink || libjaylink != null) "--disable-internal-libjaylink";

      enableParallelBuilding = true;
      NIX_LDFLAGS = optional (jimtcl-minimal != null) "-lreadline";

      src = fetchgit ({
        url = "https://repo.or.cz/r/openocd.git";
        rev = "853a05287c987d419440b21e2b22f5ab75297739";
        sha256 = "1czpj7c63q2bli2c5mnaiqz3ngw2na5yqwzvxqrrrzjczqjn8fli";
      } // optionalAttrs (jimtcl-minimal == null || (enableJaylink && libjaylink == null)) {
        fetchSubmodules = true;
        sha256 = "1czpj7c63q2bli2c5mnaiqz3ngw2na5yqwzvxqrrrzjczqjn8fli";
      });

      meta = old.meta or {} // {
        broken = old.meta.broken or false || openocd.stdenv.isDarwin;
      };
    });

    kakoune = { kakoune, kakoune-unwrapped ? null }: if kakoune-unwrapped != null
      then kakoune-unwrapped
      else kakoune;

    mustache = { nodeEnv, fetchurl }: nodeEnv.buildNodePackage rec {
      name = "mustache";
      packageName = "mustache";
      version = "4.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/${packageName}/-/${packageName}-${version}.tgz";
        sha512 = "34bjsgdkm5f3z2yx33z9jgk9jqmx31f1bz3svrhl571dnnm1jgyw84dhx6fz7a4aj5vcg25dalhl133irzw053n0pblcmn8gz4j760l";
      };
      production = true;
    };

    bitlbee-discord = { bitlbee-discord, fetchFromGitHub }: bitlbee-discord.overrideAttrs (old: {
      version = "2020-02-07";
      src = fetchFromGitHub {
        owner = "sm00th";
        repo = "bitlbee-discord";
        rev = "69e16be9d1d427e9bb085eabb9e4caecaa97dfc6";
        sha256 = "1wd7qfzriccdbwmf8d20r479rrz92xg64q38c77nzqpw8dwz93gv";
      };
    });

    mpd-youtube-dl = { lib, mpd, fetchpatch, makeWrapper, youtube-dl }: mpd.overrideAttrs (old: let
      patchVersion =
        if lib.versionOlder old.version "0.22" then "0.21.25"
        else if lib.versionOlder old.version "0.22.1" then "0.22"
        else "0.22.2";
    in {
      pname = "${mpd.pname}-youtube-dl";

      patches = old.patches or [] ++ [ (fetchpatch {
        name = "mpd-youtube-dl.diff";
        url = "https://github.com/MusicPlayerDaemon/MPD/compare/v${patchVersion}...arcnmx:ytdl-${patchVersion}.diff";
        sha256 =
          if patchVersion == "0.21.25" then "16n1fx505k6pprf753j6xzwh25ka4azwx49sz02wy68qdx8wa586"
          else if patchVersion == "0.22" then "07vladkk80mnc23ybi80wn17cfxwl8pvv5cg0rl17avyymljspax"
          else if patchVersion == "0.22.2" then "19ia0my2id84arxzzdgccp8r50jyi6z8355qpi3sn8i77phdbihh"
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

    mpd_clientlib = { mpd_clientlib }: mpd_clientlib.overrideAttrs (old: {
      # raise mpd line length limit from 4KB to 32KB
      patches = old.patches or [ ] ++ [ ./mpd_clientlib-buffer.patch ];
    });

    ncmpcpp = { ncmpcpp, fetchpatch }: ncmpcpp.overrideAttrs (old: {
      patches = old.patches or [] ++ [ (fetchpatch {
        name = "ncmpcpp-load-playlist.diff";
        url = "https://github.com/arcnmx/ncmpcpp/commit/8a5738c333407c7aa4dd775e30ab50591728ce17.patch";
        sha256 = "0bahn6ng8h30g36q2ji1cx4shyr4qimnc8vz246xschw6mr3271b";
      }) ];
      enableParallelBuilding = true;
    });

    qemu-vfio = { qemu, fetchpatch, lib }: (qemu.override {
      gtkSupport = false;
      smartcardSupport = false;
      hostCpuOnly = true;
      smbdSupport = true;
    }).overrideAttrs (old: {
      patches = old.patches or [] ++ lib.optional (lib.versionAtLeast qemu.version "4.2" && lib.versionOlder qemu.version "5.0") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/saveriomiroddi/qemu-pinning/commit/4e4fe6402e9e4943cc247a4ccfea21fa5f608b30.patch";
        sha256 = "12na0z8n48aiwiv96xn37b0i7i8kj5ph0rk8xbpm9jrzmi5rd4l1";
      }) ++ lib.optional (lib.versionAtLeast qemu.version "5.0" && lib.versionOlder qemu.version "5.1") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/saveriomiroddi/qemu-pinning/commit/76241abfe8c5c71bc02a7e268ff3d3ca0734308c.patch";
        sha256 = "1h4rm68vr4b2lpj7vi3wr5692kx4w4iccjasl86ldjsl40yfmc47";
      }) ++ lib.optional (lib.versionAtLeast qemu.version "5.1" && lib.versionOlder qemu.version "5.2") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/saveriomiroddi/qemu-pinning/commit/d166e4040f016fb6aa6ffa67abd12d9b33ac23c5.patch";
        sha256 = "0mylj1h81s160hzmk0bmfwmdgdlca0wvxl36734s4z966b6ni8jn";
        excludes = [ "roms/seabios" ];
      }) ++ lib.optional (lib.versionAtLeast qemu.version "5.2") (fetchpatch {
        name = "qemu-cpu-pinning.patch";
        url = "https://github.com/saveriomiroddi/qemu-pinning/commit/fc8e850f53be9766056d90274cef04c8bc878131.patch";
        sha256 = "13g5rxrrr60vpprkcfgslkxgcyb83qh0wwqr1kycaqbfwjz958h8";
      }) ++ lib.singleton (fetchpatch {
        name = "qemu-smb-symlinks.patch";
        url = "https://github.com/saveriomiroddi/qemu-pinning/commit/646a58799e0791c4074148a21d57786f100b7076.patch";
        sha256 = "18sqw3sbsa5w7w5580g1b6l98grm0w3bhj7mrgnjgnir8m0as678";
      });

      meta = old.meta or {} // {
        platforms = lib.platforms.linux;
      };
    });

    scream-arc = { scream, fetchpatch, fetchFromGitHub }: let
      drv = scream.override {
        pulseSupport = true;
      };
    in drv.overrideAttrs (old: {
      patches = old.patches or [] ++ [
        (fetchpatch {
          url = "https://github.com/duncanthrax/scream/pull/90.diff";
          sha256 = "0xzwx86yswn59szicq4jbaa0p2dpnj94bbgwqa8776vn786phyan";
        })
        (fetchpatch {
          url = "https://github.com/duncanthrax/scream/pull/91.patch";
          sha256 = "0lk9b5abcz1fzg7b26awcfjb6gbv8d7mx6a989sa4k94p080x4dz";
        })
      ];
    });

    git-revise = { git-revise }: git-revise.overrideAttrs (old: {
      doInstallCheck = false;
    });

    pythonInterpreters = { lib, pythonInterpreters, pkgs }: builtins.mapAttrs (pyname: py: let
      pythonOverrides = import ./python;
      packageOverrides = pself: psuper:
        builtins.mapAttrs (_: drv: pkgs.callPackage drv { pythonPackages = pself; }) (pythonOverrides psuper);
    in if py.pkgs or null != null
      then py.override (old: {
        self = pkgs.pythonInterpreters.${pyname};
        packageOverrides =
          pself: psuper: let
            psuper' = ((old.packageOverrides or (_: _: {})) pself psuper);
          in psuper' // packageOverrides pself (psuper // psuper');
      })
      else py
    ) pythonInterpreters;

    mosh-client = { mosh, stdenvNoCC }: stdenvNoCC.mkDerivation {
      inherit (mosh) name;

      inherit mosh;
      buildCommand = ''
        mkdir -p $out/bin
        ln -s $mosh/share $out/
        ln -s $mosh/bin/mosh $mosh/bin/mosh-client $out/bin/
      '';
    };

    mkShell = { lib, mkShell, mkShellEnv }@args: let
      mkShell = args.mkShell.mkShell or args.mkShell;
    in {
      inherit mkShell;
      mkShellEnv = mkShellEnv.override { inherit mkShell; };
      __functor = self: attrs: lib.drvPassthru (drv: let
        shellEnv = self.mkShellEnv attrs;
      in {
        inherit shellEnv;
        ci = attrs.ci or {} // {
          inputs = attrs.ci.inputs or [] ++ [ shellEnv ];
        };
      }) (self.mkShell attrs);
    };

    # nix progress displays better with the builtin :(
    fetchurl = { fetchurl, nixFetchurl }@args: let
      fetchurl = args.fetchurl.fetchurl or args.fetchurl;
    in {
      inherit fetchurl;
      nixFetchurl = nixFetchurl.override { inherit fetchurl; };
      __functor = self: self.nixFetchurl;
    };
  };
in packages // {
  instantiate = { self, super, ... }: let
    called = builtins.mapAttrs (name: p: let
      fargs = super.lib.functionArgs p;
      args = if fargs ? ${name}
      then {
        ${name} = super.${name} or (if fargs.${name} then null else throw "pkgs.${name} not found");
      } else { };
      # TODO: this messes with the original .override so use lib.callWith instead?
    in self.callPackage p args) packages;
  in called;
}
