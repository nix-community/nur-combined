let
  packages = {
    pass-arc = { pass, hostPlatform }: (pass.withExtensions (ext: [ext.pass-otp])).overrideAttrs (old: {
      doInstallCheck = !hostPlatform.isDarwin;
    });

    nix-readline = { nix, readline, fetchurl, lib }: nix.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ readline ];
      patches = old.patches or [] ++ lib.optional (lib.versionAtLeast lib.version "19.09") (fetchurl {
        name = "readline-completion.patch";
        url = "https://github.com/arcnmx/nix/commit/f4d1453c2b86aa576f1a707d47eb2174fd7e4a90.patch";
        sha256 = "18b3bv0wjkx5hmrmhbzf6rl6swcx8ibk29c5pk4fysjd71rfd5d0";
      });
      EDITLINE_LIBS = "${readline}/lib/libreadline${nix.stdenv.hostPlatform.extensions.sharedLibrary}";
      EDITLINE_CFLAGS = "-DREADLINE";
      doInstallCheck = old.doInstallCheck or false && !nix.stdenv.isDarwin;
    });

    vim_configurable-pynvim = { vim_configurable, python3 }: vim_configurable.override {
      # vim with python3
      python = python3.withPackages(ps: with ps; [ pynvim ]);
      wrapPythonDrv = true;
      guiSupport = "no";
      luaSupport = false;
      multibyteSupport = true;
      ftNixSupport = false; # provided by "vim-nix" plugin
      # TODO: fully disable X11?
    };

    rxvt_unicode-cvs = { rxvt_unicode, fetchcvs }: rxvt_unicode.overrideAttrs (old: {
      enableParallelBuilding = true;
      src = fetchcvs {
        cvsRoot = ":pserver:anonymous@cvs.schmorp.de:/schmorpforge";
        module = "rxvt-unicode";
        date = "2019-07-01";
        sha256 = "04vgrri1zm5kgjdd4swfi4khjbbp8a3s5c46by7lqg417xqh2a5m";
      };
    });
    rxvt_unicode-arc = { rxvt_unicode-with-plugins, rxvt_unicode-cvs, pkgs }: rxvt_unicode-with-plugins.override {
      rxvt_unicode = rxvt_unicode-cvs; # current release is years old, doesn't include 24bit colour changes
      plugins = with pkgs; [
        urxvt_perl
        urxvt_perls
        #urxvt_font_size ?
        urxvt_theme_switch
        urxvt_vtwheel
        urxvt_osc_52
        urxvt_xresources_256
      ];
    };

    bitlbee-libpurple = { bitlbee }: bitlbee.override { enableLibPurple = true; };

    pidgin-arc = { pidgin, purple-plugins-arc }: let
      wrapped = pidgin.override {
        plugins = purple-plugins-arc;
      };
    in wrapped.overrideAttrs (old: {
      meta.broken = pidgin.stdenv.isDarwin;
    });

    weechat-arc = { lib, wrapWeechat, weechat-unwrapped, weechatScripts, pythonPackages, python3Packages }: let
      wrapWeechat' = wrapWeechat.override { inherit python3Packages; };
      weechat-unwrapped' = weechat-unwrapped.override { inherit python3Packages; };
      weechat-wrapped = wrapWeechat' weechat-unwrapped' {
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

    luakit-develop = { fetchFromGitHub, luakit, gst_all_1-noqt }: let
      drv = luakit.override {
        gst_all_1 = gst_all_1-noqt;
      };
    in drv.overrideAttrs (old: rec {
      name = "luakit-${version}";
      rev = "4276fcad76d507cf82877a8dbab0709cbf48083b";
      version = "2019-08-13";
      src = fetchFromGitHub {
        owner = "luakit";
        repo = "luakit";
        inherit rev;
        sha256 = "1vdvnqnwd0sya0zyz1zn7vwm36jrqij7zsv59axyfmjj9dsj63kv";
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

    vit2 = { python3Packages }: with python3Packages; toPythonApplication vit;
    yamllint = { python3Packages }: with python3Packages; toPythonApplication yamllint;

    libjaylink = { stdenv, fetchgit, autoreconfHook, pkgconfig, libusb1 }: stdenv.mkDerivation {
      pname = "libjaylink";
      version = "2019-06-07";
      nativeBuildInputs = [ pkgconfig autoreconfHook ];
      buildInputs = [ libusb1 ];

      src = fetchgit {
        url = "git://git.zapb.de/libjaylink.git";
        rev = "c2c4bb025f3f02336ea88f57f59e204a1303da9b";
        sha256 = "1qsw1wlkjiqnhqxgddh7l8vawy8170ll6lqrxq7viq91wi9fggsl";
      };
    };

    jimtcl-minimal = { lib, tcl, jimtcl, readline }: (jimtcl.override { SDL = null; SDL_gfx = null; sqlite = null; }).overrideAttrs (old: {
      NIX_CFLAGS_COMPILE = "";
      configureFlags = with lib; filter (f: !hasSuffix "sqlite3" f && !hasSuffix "sdl" f) old.configureFlags;
      propagatedBuildInputs = old.propagatedBuildInputs or [] ++ [ readline ];
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [ tcl ];
    });

    openocd-eclipse = {
      openocd
    , fetchFromGitHub, autoreconfHook, lib
    , git, jimtcl-minimal ? null, libjaylink ? null, enableJaylink ? libjaylink != null
    }: with lib; openocd.overrideAttrs (old: rec {
      pname = "openocd-eclipse";
      name = "openocd-eclipse-${version}";
      version = "0.10.0-12-20190422";

      nativeBuildInputs = old.nativeBuildInputs ++ [ autoreconfHook git jimtcl-minimal ];
      buildInputs = old.buildInputs
        ++ optional enableJaylink libjaylink
        ++ optional (jimtcl-minimal != null) jimtcl-minimal;
      configureFlags = filter (f: !hasSuffix "oocd_trace" f) old.configureFlags
        ++ optional (jimtcl-minimal != null) "--disable-internal-jimtcl"
        ++ optional (!enableJaylink || libjaylink != null) "--disable-internal-libjaylink";

      NIX_LDFLAGS = optional (jimtcl-minimal != null) "-lreadline";

      src = fetchFromGitHub ({
        owner = "gnu-mcu-eclipse";
        repo = "openocd";
        rev = "v${version}";
        sha256 = "08hqb2r58i8v7smw0x0jhlsiaf5hmnaq5igfbcy1p6zbip1prwnp";
      } // optionalAttrs (jimtcl-minimal == null || (enableJaylink && libjaylink == null)) {
        fetchSubmodules = true;
        sha256 = "13g8h2j1vg2dj97mxfiiwch1pw6xsg0r1wc2li3v6j85xvkcf4h9";
      });
    });

    kakoune = { kakoune, kakoune-unwrapped ? null }: if kakoune-unwrapped != null
      then kakoune-unwrapped
      else kakoune;

    mustache = { nodeEnv, fetchurl }: nodeEnv.buildNodePackage rec {
      name = "mustache";
      packageName = "mustache";
      version = "3.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/${packageName}/-/${packageName}-${version}.tgz";
        sha512 = "2lfq2nlqd738xcb3j7h83ds7wcfz2rwshqx572sy3xk58b39h5sjp2iy82kgc39carra3v2n6kwwdrbzfj4r0xva4fidcai8phkyllc";
      };
      production = true;
    };

    mpd-youtube-dl = { lib, mpd, fetchpatch }: mpd.overrideAttrs (old: {
      pname = "${mpd.pname}-youtube-dl";
      patches = old.patches or [] ++ [ (fetchpatch {
        name = "mpd-youtube-dl.diff";
        url = "https://github.com/MusicPlayerDaemon/MPD/compare/v${old.version}...arcnmx:ytdl.diff";
        sha256 = mpd.stdenv.lib.fakeSha256;
      }) ];
      meta = old.meta or {} // {
        broken = old.meta.broken or false || lib.versionOlder old.version "0.21";
      };
    });

    olm = { olm, fetchurl }: olm.overrideAttrs (old: rec {
      pname = "olm";
      version = "3.1.3";
      name = "${pname}-${version}";
      src = fetchurl {
        url = "https://gitlab.matrix.org/matrix-org/olm/-/archive/${version}/${name}.tar.gz";
        sha256 = "1zr6bi9kk1410mbawyvsbl1bnzw86wzwmgc7i5ap6i9l96mb1zqh";
      };

      meta.broken = olm.stdenv.isDarwin;
    });

    pythonInterpreters = { lib, pythonInterpreters, pkgs }: builtins.mapAttrs (_: py: let
        pythonOverrides = import ./python;
        packageOverrides = pself: psuper:
          builtins.mapAttrs (_: drv: pkgs.callPackage drv { pythonPackages = pself; }) (pythonOverrides psuper);
      in if py.pkgs or null != null
        then py.override (old: {
          packageOverrides =
            pself: psuper: let
              psuper' = ((old.packageOverrides or (_: _: {})) pself psuper);
            in psuper' // packageOverrides pself (psuper // psuper');
        })
        else py
    ) pythonInterpreters;

    mkShell = { lib, mkShell, mkShellEnv }: {
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
    fetchurl = { fetchurl, nixFetchurl }: {
      inherit fetchurl;
      nixFetchurl = nixFetchurl.override { inherit fetchurl; };
      __functor = self: self.nixFetchurl;
    };
  };
in packages // {
  instantiate = { self, super, ... }: let
    called = builtins.mapAttrs (name: p: let
        args = if super ? ${name} && (! super ? arc) # awkward if this gets overlaid twice..?
        then {
          ${name} = super.${name};
        } else { };
        # TODO: this messes with the original .override so use lib.callWith instead?
      in self.callPackage p args
    ) packages;
  in called;
}
