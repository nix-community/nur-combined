final: prev:
let
  inherit (prev) lib;
  mkEmulated = final': pkgs:
    import pkgs.path {
      # system = pkgs.stdenv.hostPlatform.system;
      localSystem = pkgs.stdenv.hostPlatform.system;
      # inherit (config.nixpkgs) config;
      inherit (final'.config.nixpkgs or { config = {}; }) config;
      # config = builtins.removeAttrs config.nixpkgs.config [ "replaceStdenv" ];
      # overlays = [(import ./all.nix)];
      inherit (final') overlays;
    };
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
  rmInputs = { buildInputs ? [], nativeBuildInputs ? [] }: pkg: pkg.overrideAttrs (upstream: {
    buildInputs = lib.subtractLists buildInputs (upstream.buildInputs or []);
    nativeBuildInputs = lib.subtractLists nativeBuildInputs (upstream.nativeBuildInputs or []);
  });
  rmNativeBuildInputs = nativeBuildInputs: rmInputs { inherit nativeBuildInputs; };
  # move items from buildInputs into nativeBuildInputs, or vice-versa.
  # arguments represent the final location of specific inputs.
  mvInputs = { buildInputs ? [], nativeBuildInputs ? [] }: pkg:
    addInputs { buildInputs = buildInputs; nativeBuildInputs = nativeBuildInputs; }
    (
      rmInputs { buildInputs = nativeBuildInputs; nativeBuildInputs = buildInputs; }
      pkg
    );

  useEmulatedStdenv = p: p.override {
    inherit (emulated) stdenv;
  };
  emulated = mkEmulated final prev;
in {
  inherit emulated;

  pkgsi686Linux = prev.pkgsi686Linux.extend (i686Self: i686Super: {
    # fixes eval-time error: "Unsupported cross architecture"
    #   it happens even on a x86_64 -> x86_64 build:
    #   - defining `config.nixpkgs.buildPlatform` to the non-default causes that setting to be inherited by pkgsi686.
    #   - hence, `pkgsi686` on a non-cross build is ordinarily *emulated*:
    #     defining a cross build causes it to also be cross (but to the right hostPlatform)
    # this has no inputs other than stdenv, and fetchurl, so emulating it is fine.
    tbb = prev.emulated.pkgsi686Linux.tbb;
    # tbb = i686Super.tbb.overrideAttrs (orig: (with i686Self; {
    #   makeFlags = lib.optionals stdenv.cc.isClang [
    #     "compiler=clang"
    #   ] ++ (lib.optional (stdenv.buildPlatform != stdenv.hostPlatform)
    #     (if stdenv.hostPlatform.isAarch64 then "arch=arm64"
    #     else if stdenv.hostPlatform.isx86_64 then "arch=intel64"
    #     else throw "Unsupported cross architecture: ${stdenv.buildPlatform.system} -> ${stdenv.hostPlatform.system}"));
    # }));
  });

  # packages which don't cross compile
  inherit (emulated)
    # adwaita-qt6  # although qtbase cross-compiles with minor change, qtModule's qtbase can't
    # bonsai
    # conky  # needs to be able to build lua
    # duplicity  # python3.10-s3transfer
    # gdk-pixbuf  # cross-compiled version doesn't output bin/gdk-pixbuf-thumbnailer  (used by webp-pixbuf-loader
    # gnome-tour
    # XXX: gnustep members aren't individually overridable, because the "scope" uses `rec` such that members don't see overrides
    # gnustep is going to need a *lot* of work/domain-specific knowledge to truly cross-compile,
    # though if we make the members overridable maybe we can get away with emulating only stdenv.
    gnustep  # gnustep.base: "configure: error: Your compiler does not appear to implement the -fconstant-string-class option needed for support of strings."
    # grpc
    hare
    harec
    # nixpkgs hdf5 is at commit 3e847e003632bdd5fdc189ccbffe25ad2661e16f
    # hdf5  # configure: error: cannot run test program while cross compiling
    # http2
    ibus  # "error: cannot run test program while cross compiling"
    jellyfin-web  # in node-dependencies-jellyfin-web: "node: command not found"  (nodePackages don't cross compile)
    # libgccjit  # "../../gcc-9.5.0/gcc/jit/jit-result.c:52:3: error: 'dlclose' was not declared in this scope"  (needed by emacs!)
    # libsForQt5  # if we emulate qt5, we're better off emulating libsForQt5 else qt complains about multiple versions of qtbase
    mepo  # /build/source/src/sdlshim.zig:1:20: error: C import failed
    perlInterpreters  # perl5.36.0-Module-Build perl5.36.0-Test-utf8 (see tracking issues ^)
    # qgnomeplatform
    # qtbase
    # qt5  # qt5.qtbase, qt5.qtx11extras fails, but we can't selectively emulate them.
    # qt6  # "You need to set QT_HOST_PATH to cross compile Qt."
    # sequoia  # "/nix/store/q8hg17w47f9xr014g36rdc2gi8fv02qc-clang-aarch64-unknown-linux-gnu-12.0.1-lib/lib/libclang.so.12: cannot open shared object file: No such file or directory"', /build/sequoia-0.27.0-vendor.tar.gz/bindgen/src/lib.rs:1975:31"
    # splatmoji
    # twitter-color-emoji  # /nix/store/0wk6nr1mryvylf5g5frckjam7g7p9gpi-bash-5.2-p15/bin/bash: line 1: pkg-config: command not found
    # visidata  # python3.10-psycopg2 python3.10-pandas python3.10-h5py
    # webkitgtk_4_1  # requires nativeBuildInputs = perl.pkgs.FileCopyRecursive => perl5.36.0-Test-utf8
    # xdg-utils  # perl5.36.0-File-BaseDir / perl5.36.0-Module-Build
  ;

  # adwaita-qt6 = prev.adwaita-qt6.override {
  #   # adwaita-qt6 still uses the qt5 version of these libs by default?
  #   inherit (final.qt6) qtbase qtwayland;
  # };
  # qt6 doesn't cross compile. the only thing that wants it is phosh/gnome, in order to
  # configure qt6 apps to look stylistically like gtk apps.
  # adwaita-qt6 isn't an input into any other packages we build -- it's just placed on the systemPackages.
  # so... just set it to null and that's Good Enough (TM).
  # adwaita-qt6 = derivation { name = "null-derivation"; builder = "/dev/null"; }; # null;
  # adwaita-qt6 = final.stdenv.mkDerivation { name = "null-derivation"; };
  # adwaita-qt6 = final.emptyDirectory;
  # same story as qdwaita-qt6
  # qgnomeplatform-qt6 = final.emptyDirectory;

  apacheHttpd_2_4 = prev.apacheHttpd_2_4.overrideAttrs (upstream: {
    configureFlags = upstream.configureFlags or [] ++ [
      "ap_cv_void_ptr_lt_long=no"  # configure can't AC_TRY_RUN, and can't validate that sizeof (void*) == sizeof long
    ];
    # let nix figure out the perl shebangs.
    # some of these perl scripts are shipped on the host, others in the .dev output for the build machine.
    # postPatch methods create cycles
    # postPatch = ''
    #   substituteInPlace configure --replace \
    #     '/replace/with/path/to/perl/interpreter' \
    #     '/usr/bin/perl'
    # '';
    # postPatch = ''
    #   substituteInPlace support/apxs.in --replace \
    #     '@perlbin@' \
    #     '/usr/bin/perl'
    # '';
    postFixup = upstream.postFixup or "" + ''
      sed -i 's:/replace/with/path/to/perl/interpreter:${final.buildPackages.perl}/bin/perl:' $dev/bin/apxs
    '';
  });

  # apacheHttpd_2_4 = (prev.apacheHttpd_2_4.override {
  #   # fixes `configure: error: Size of "void *" is less than size of "long"`
  #   inherit (emulated) stdenv;
  # }).overrideAttrs (upstream: {
  #   # nativeBuildInputs = upstream.nativeBuildInputs ++ [ final.bintools ];
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     final.buildPackages.stdenv.cc  # fixes: "/nix/store/czvaa9y9ch56z53c0b0f5bsjlgh14ra6-apr-aarch64-unknown-linux-gnu-1.7.0-dev/share/build/libtool: line 1890: aarch64-unknown-linux-gnu-ar: command not found"
  #   ];
  #   # now can't find -lz for zlib.
  #   # this is because nixpkgs zlib.dev has only include/ + a .pc file linking to zlib, which has the lib/ folder
  #   #   but httpd expects --with-zlib=prefix/ to hold both include/ and lib/
  #   # TODO: we could link farm, or we could skip straight to cross compilation and not emulate stdenv
  # });

  # mod_dnssd = prev.mod_dnssd.override {
  #   inherit (emulated) stdenv;
  # };

  apacheHttpdPackagesFor = apacheHttpd: self:
    let
      prevHttpdPkgs = prev.apacheHttpdPackagesFor apacheHttpd self;
    in prevHttpdPkgs // {
      # fixes "configure: error: *** Sorry, could not find apxs ***"
      # mod_dnssd = prevHttpdPkgs.mod_dnssd.override {
      #   inherit (emulated) stdenv;
      # };
      # TODO: the below apxs doesn't have a valid shebang (#!/replace/with/...).
      #   we can't replace it at the origin?
      mod_dnssd = prevHttpdPkgs.mod_dnssd.overrideAttrs (upstream: {
        configureFlags = upstream.configureFlags ++ [
          "--with-apxs=${self.apacheHttpd.dev}/bin"
        ];
      });
    };

  # apacheHttpdPackagesFor = apacheHttpd: self:
  #   let
  #     prevHttpdPkgs = lib.fix (emulated.apacheHttpdPackagesFor apacheHttpd);
  #   in
  #     (prev.apacheHttpdPackagesFor apacheHttpd self) // {
  #       # inherit (prevHttpdPkgs) mod_dnssd;
  #       mod_dnssd = prevHttpdPkgs.mod_dnssd.override {
  #         inherit (self) apacheHttpd;
  #       };
  #     };

  blueman = prev.blueman.overrideAttrs (orig: {
    # configure: error: ifconfig or ip not found, install net-tools or iproute2
    nativeBuildInputs = orig.nativeBuildInputs ++ [ final.iproute2 ];
  });
  bonsai = prev.bonsai.override {
    inherit (emulated) hare stdenv;
  };
  brltty = prev.brltty.override {
    # configure: error: no acceptable C compiler found in $PATH
    inherit (emulated) stdenv;
  };
  browserpass-extension = prev.browserpass-extension.override {
    # bash: line 1: node_modules/.bin/prettier: cannot execute: required file not found
    inherit (emulated) mkYarnModules;
  };
  cantarell-fonts = prev.cantarell-fonts.override {
    # fixes error where python3.10-skia-pathops dependency isn't available for the build platform
    inherit (emulated) stdenv;
  };
  # fixes "FileNotFoundError: [Errno 2] No such file or directory: 'gtk4-update-icon-cache'"
  # - only required because of my wrapGAppsHook4 change
  celluloid = addNativeInputs [ final.gtk4 ] prev.celluloid;
  cdrtools = prev.cdrtools.override {
    # "configure: error: installation or configuration problem: C compiler cc not found."
    inherit (emulated) stdenv;
  };
  # cdrtools = prev.cdrtools.overrideAttrs (upstream: {
  #   # can't get it to actually use our CC, even when specifying these explicitly
  #   # CC = "${final.stdenv.cc}/bin/${final.stdenv.cc.targetPrefix}cc";
  #   makeFlags = upstream.makeFlags ++ [
  #     "CC=${final.stdenv.cc}/bin/${final.stdenv.cc.targetPrefix}cc"
  #   ];
  # });

  # colord = prev.colord.override {
  #   # doesn't fix: "ld: error adding symbols: file in wrong format"
  #   inherit (emulated) stdenv;
  # };
  colord = prev.colord.overrideAttrs (upstream: {
    # fixes: (meson) ERROR: An exe_wrapper is needed but was not found. Please define one in cross file and check the command and/or add it to PATH.
    nativeBuildInputs = upstream.nativeBuildInputs ++ lib.optionals (!prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform) [
      final.mesonEmulatorHook
    ];
  });

  # conky = (prev.conky.override {
  #     curlSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  #     # docbook2x dependency doesn't cross compile
  #     docsSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  #     journalSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  #     # tries to invoke `toluapp`, which would likely compile to wrong platform?
  #     luaSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  #     ncursesSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  #     wirelessSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  #     x11Support = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  #     # lua = emulated.lua5_3_compat;
  #   }
  # ).overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [ final.git ];
  #   buildInputs = [ final.lua5_4_compat ];
  #   cmakeFlags = upstream.cmakeFlags ++ ["-DLUA_INCLUDE_DIR=/tmp/"];
  # });
  conky = ((useEmulatedStdenv prev.conky).override {
    # docbook2x dependency doesn't cross compile
    docsSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  }).overrideAttrs (upstream: {
    nativeBuildInputs = upstream.nativeBuildInputs ++ [ final.git ];
  });

  cozy = prev.cozy.override {
    cozy = prev.cozy.upstream.cozy.override {
      # fixes runtime error: "Settings schema 'org.gtk.Settings.FileChooser' is not installed"
      # otherwise gtk3+ schemas aren't added to XDG_DATA_DIRS
      inherit (emulated) wrapGAppsHook;
    };
  };

  dante = prev.dante.override {
    # fixes: "configure: error: error: getaddrinfo() error value count too low"
    inherit (emulated) stdenv;
  };

  # dconf = (prev.dconf.override {
  #   # we need dconf to build with vala, because dconf-editor requires that.
  #   # this only happens if dconf *isn't* cross-compiled
  #   inherit (emulated) stdenv;
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = lib.remove final.glib upstream.nativeBuildInputs;
  # });
  dconf = prev.dconf.overrideAttrs (upstream: {
    # we need dconf to build with vala, because dconf-editor requires that.
    # upstream nixpkgs explicitly disables that on cross compilation, but in fact, it works.
    # so just undo upstream's mods.
    buildInputs = upstream.buildInputs ++ [ final.vala ];
    mesonFlags = lib.remove "-Dvapi=false" upstream.mesonFlags;
  });

  # emacs = prev.emacs.override {
  #   # fixes "configure: error: cannot run test program while cross compiling"
  #   inherit (emulated) stdenv;
  # };
  emacs = prev.emacs.override {
    nativeComp = false;
    # TODO: we can specify 'action-if-cross-compiling' to actually invoke the test programs:
    # <https://www.gnu.org/software/autoconf/manual/autoconf-2.63/html_node/Runtime.html>
  };

  epiphany = prev.epiphany.override {
    # fixes -msse2, -mfpmath=sse flags
    wrapGAppsHook4 = final.wrapGAppsHook;
  };

  flatpak = prev.flatpak.overrideAttrs (upstream: {
    # fixes "No package 'libxml-2.0' found"
    buildInputs = upstream.buildInputs ++ [ final.libxml2 ];
    configureFlags = upstream.configureFlags ++ [
      "--enable-selinux-module=no"  # fixes "checking for /usr/share/selinux/devel/Makefile... configure: error: cannot check for file existence when cross compiling"
      "--disable-gtk-doc"  # fixes "You must have gtk-doc >= 1.20 installed to build documentation for Flatpak"
    ];
  });

  fwupd-efi = prev.fwupd-efi.override {
    # fwupd-efi queries meson host_machine to decide what arch to build for.
    #   for some reason, this gives x86_64 unless meson itself is emulated.
    #   maybe meson's use of "host_machine" actually mirrors nix's "build machine"?
    inherit (emulated)
      stdenv  # fixes: "efi/meson.build:162:0: ERROR: Program or command 'gcc' not found or not executable"
      meson  # fixes: "efi/meson.build:33:2: ERROR: Problem encountered: gnu-efi support requested, but headers were not found"
    ;
  };
  # fwupd-efi = prev.fwupd-efi.overrideAttrs (upstream: {
  #   # does not fix: "efi/meson.build:162:0: ERROR: Program or command 'gcc' not found or not executable"
  #   makeFlags = upstream.makeFlags or [] ++ [ "CC=${prev.stdenv.cc.targetPrefix}cc" ];
  #   # does not fix: "efi/meson.build:162:0: ERROR: Program or command 'gcc' not found or not executable"

  #   # nativeBuildInputs = upstream.nativeBuildInputs ++ lib.optionals (!prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform) [
  #   #   final.mesonEmulatorHook
  #   # ];
  # });
  # solves (meson) "Run-time dependency libgcab-1.0 found: NO (tried pkgconfig and cmake)", and others.
  fwupd = (addBuildInputs
    [ final.gcab ]
    (mvToBuildInputs [ final.gnutls ] prev.fwupd)
  ).overrideAttrs (upstream: {
    # XXX: gcab is apparently needed as both build and native input
    # can't build docs w/o adding `gi-docgen` to ldpath, but that adds a new glibc to the ldpath
    # which causes host binaries to be linked against the build libc & fail
    mesonFlags = (lib.remove "-Ddocs=enabled" upstream.mesonFlags) ++ [ "-Ddocs=disabled" ];
    outputs = lib.remove "devdoc" upstream.outputs;
  });
  # fwupd = prev.fwupd.override {
  #   # solves missing libgcab-1.0;
  #   # new error: "meson.build:449:4: ERROR: Command "/nix/store/n7xrj3pnrgcr8igx7lfhz8197y67bk7k-python3-aarch64-unknown-linux-gnu-3.10.9-env/bin/python3 po/test-deps" failed with status 1."
  #   inherit (emulated) stdenv;
  # };

  gcr_4 = (
    # fixes (meson): "ERROR: Program 'gpg2 gpg' not found or not executable"
    mvToNativeInputs [ final.gnupg final.openssh ] prev.gcr_4
  ).override {
    # fixes -msse2, -mfpmath=sse flags
    wrapGAppsHook4 = final.wrapGAppsHook;
  };
  gthumb = mvInputs { nativeBuildInputs = [ final.glib ]; } prev.gthumb;

  gnome = prev.gnome.overrideScope' (self: super: {
    inherit (emulated.gnome)
    ;
    # dconf-editor = super.dconf-editor.override {
    #   # fails to fix original error
    #   inherit (emulated) stdenv;
    # };
    # fixes "error: Package `dconf' not found in specified Vala API directories or GObject-Introspection GIR directories"
    # - but ONLY if `dconf` was built with the vala feature.
    # - dconf is NOT built with vala when cross-compiled
    #   - that's an explicit choice/limitation in nixpkgs upstream
    # - TODO: vapi stuff is contained in <dconf.dev:/share/vala/vapi/dconf.vapi>
    #   it's cross-platform; should be possible to ship dconf only in buildInputs & point dconf-editor to the right place
    dconf-editor = addNativeInputs [ final.dconf ] super.dconf-editor;
    evince = super.evince.overrideAttrs (orig: {
      # fixes (meson) "Run-time dependency gi-docgen found: NO (tried pkgconfig and cmake)"
      # inspired by gupnp
      outputs = [ "out" "dev" ]
        ++ lib.optionals (prev.stdenv.buildPlatform == prev.stdenv.hostPlatform) [ "devdoc" ];
      mesonFlags = orig.mesonFlags ++ [
        "-Dgtk_doc=${lib.boolToString (prev.stdenv.buildPlatform == prev.stdenv.hostPlatform)}"
      ];
    });
    evolution-data-server = super.evolution-data-server.overrideAttrs (upstream: {
      # fixes aborts in "Performing Test _correct_iconv"
      cmakeFlags = upstream.cmakeFlags ++ [
        "-DCMAKE_CROSSCOMPILING_EMULATOR=${final.stdenv.hostPlatform.emulator final.buildPackages}"
      ];
      # N.B.: the deps are funky even without cross compiling.
      # upstream probably wants to replace pcre with pcre2, and maybe provide perl
      # nativeBuildInputs = upstream.nativeBuildInputs ++ [
      #   final.perl  # fixes "The 'perl' not found, not installing csv2vcard"
      #   # final.glib
      #   # final.libiconv
      #   # final.iconv
      # ];
      # buildInputs = upstream.buildInputs ++ [
      #   final.pcre2  # fixes: "Package 'libpcre2-8', required by 'glib-2.0', not found"
      #   final.mount  # fails to fix: "Package 'mount', required by 'gio-2.0', not found"
      # ];
    });

    # file-roller = super.file-roller.override {
    #   # fixes "src/meson.build:106:0: ERROR: Program 'glib-compile-resources' not found or not executable"
    #   inherit (emulated) stdenv;
    # };
    # fixes: "src/meson.build:106:0: ERROR: Program 'glib-compile-resources' not found or not executable"
    file-roller = mvToNativeInputs [ final.glib ] super.file-roller;
    gnome-bluetooth = super.gnome-bluetooth.override {
      # fixes -msse2, -mfpmath=sse flags
      wrapGAppsHook4 = final.wrapGAppsHook;
    };
    # fixes: "meson.build:75:6: ERROR: Program 'gtk-update-icon-cache' not found or not executable"
    gnome-clocks = (
      addNativeInputs [ final.gtk4 ] super.gnome-clocks
    ).override {
      # fixes -msse2, -mfpmath=sse flags
      wrapGAppsHook4 = final.wrapGAppsHook;
    };
    # fixes: "src/meson.build:3:0: ERROR: Program 'glib-compile-resources' not found or not executable"
    gnome-color-manager = mvToNativeInputs [ final.glib ] super.gnome-color-manager;
    # fixes "subprojects/gvc/meson.build:30:0: ERROR: Program 'glib-mkenums mkenums' not found or not executable"
    gnome-control-center = mvToNativeInputs [ final.glib ] super.gnome-control-center;
    # gnome-control-center = super.gnome-control-center.override {
    #   inherit (final) stdenv;
    # };
    # gnome-keyring = super.gnome-keyring.override {
    #   # does not fix original error
    #   inherit (final) stdenv;
    # };
    gnome-keyring = super.gnome-keyring.overrideAttrs (orig: {
      # fixes "configure.ac:374: error: possibly undefined macro: AM_PATH_LIBGCRYPT"
      nativeBuildInputs = orig.nativeBuildInputs ++ [ final.libgcrypt final.openssh final.glib ];
    });
    # fixes: "Program gdbus-codegen found: NO"
    gnome-remote-desktop = mvToNativeInputs [ final.glib ] super.gnome-remote-desktop;
    # gnome-shell = super.gnome-shell.overrideAttrs (orig: {
    #   # fixes "meson.build:128:0: ERROR: Program 'gjs' not found or not executable"
    #   # does not fix "_giscanner.cpython-310-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory"  (python import failure)
    #   nativeBuildInputs = orig.nativeBuildInputs ++ [ final.gjs final.gobject-introspection ];
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
    gnome-shell = super.gnome-shell.overrideAttrs (upstream: {
      nativeBuildInputs = upstream.nativeBuildInputs ++ [
        final.gjs  # fixes "meson.build:128:0: ERROR: Program 'gjs' not found or not executable"
        final.buildPackages.gobject-introspection  # fixes "shew| Build-time dependency gobject-introspection-1.0 found: NO"
      ];
      buildInputs = lib.remove final.gobject-introspection upstream.buildInputs;
      # try to reduce gobject-introspection/shew dependencies
      # TODO: these likely aren't all necessary
      mesonFlags = [
        "-Dextensions_app=false"
        "-Dextensions_tool=false"
        "-Dman=false"
        "-Dgtk_doc=false"
        # fixes "src/st/meson.build:198:2: ERROR: Dependency "libmutter-test-12" not found, tried pkgconfig"
        "-Dtests=false"
      ];
      outputs = [ "out" "dev" ];
      postPatch = upstream.postPatch or "" + ''
        # disable introspection for the gvc (libgnome-volume-control) subproject
        # to remove its dependency on gobject-introspection
        sed -i s/introspection=true/introspection=false/ meson.build
        sed -i 's/libgvc_gir/# libgvc_gir/' meson.build src/meson.build
      '';
    });
    # gnome-settings-daemon = super.gnome-settings-daemon.overrideAttrs (orig: {
    #   # does not fix original error
    #   nativeBuildInputs = orig.nativeBuildInputs ++ [ final.mesonEmulatorHook ];
    # });
    gnome-settings-daemon = super.gnome-settings-daemon.overrideAttrs (orig: {
      # glib solves: "Program 'glib-mkenums mkenums' not found or not executable"
      nativeBuildInputs = orig.nativeBuildInputs ++ [ final.glib ];
      # pkg-config solves: "plugins/power/meson.build:22:0: ERROR: Dependency lookup for glib-2.0 with method 'pkgconfig' failed: Pkg-config binary for machine 0 not found."
      # stdenv.cc fixes: "plugins/power/meson.build:60:0: ERROR: No build machine compiler for 'plugins/power/gsd-power-enums-update.c'"
      # but then it fails with a link-time error.
      # depsBuildBuild = orig.depsBuildBuild or [] ++ [ final.glib final.pkg-config final.buildPackages.stdenv.cc ];
      # hack to just not build the power plugin (panel?), to avoid cross compilation errors
      postPatch = orig.postPatch + ''
        sed -i "s/disabled_plugins = \[\]/disabled_plugins = ['power']/" plugins/meson.build
      '';
    });
    # fixes: "gdbus-codegen not found or executable"
    gnome-session = mvToNativeInputs [ final.glib ] super.gnome-session;
    # gnome-terminal = super.gnome-terminal.override {
    #   # fixes: "meson.build:343:0: ERROR: Dependency "libpcre2-8" not found, tried pkgconfig"
    #   # new failure mode: "/nix/store/grqh2wygy9f9wp5bgvqn4im76v82zmcx-binutils-2.39/bin/ld: /nix/store/f7yr5z123d162p5457jh3wzkqm7x8yah-glib-2.74.3/lib/libglib-2.0.so: error adding symbols: file in wrong format"
    #   inherit (emulated) stdenv;
    # };
    gnome-terminal = super.gnome-terminal.overrideAttrs (orig: {
      # fixes "meson.build:343:0: ERROR: Dependency "libpcre2-8" not found, tried pkgconfig"
      buildInputs = orig.buildInputs ++ [ final.pcre2 ];
    });
    # fixes: meson.build:111:6: ERROR: Program 'glib-compile-schemas' not found or not executable
    gnome-user-share = addNativeInputs [ final.glib ] super.gnome-user-share;
    # fixes: "FileNotFoundError: [Errno 2] No such file or directory: 'gtk4-update-icon-cache'"
    gnome-weather = addNativeInputs [ final.gtk4 ] super.gnome-weather;
    mutter = (super.mutter.overrideAttrs (orig: {
      nativeBuildInputs = orig.nativeBuildInputs ++ [
        final.glib  # fixes "clutter/clutter/meson.build:281:0: ERROR: Program 'glib-mkenums mkenums' not found or not executable"
        final.buildPackages.gobject-introspection  # allows to build without forcing `introspection=false` (which would break gnome-shell)
        final.wayland-scanner
      ];
      buildInputs = orig.buildInputs ++ [
        final.mesa  # fixes "meson.build:237:2: ERROR: Dependency "gbm" not found, tried pkgconfig"
      ];
      mesonFlags = lib.remove "-Ddocs=true" orig.mesonFlags;
      outputs = lib.remove "devdoc" orig.outputs;
    })).override {
      # fixes -msse2, -mfpmath=sse flags
      wrapGAppsHook4 = final.wrapGAppsHook;
    };
    # nautilus = super.nautilus.override {
    #   # fixes: "meson.build:123:0: ERROR: Dependency "libxml-2.0" not found, tried pkgconfig"
    #   # new failure mode: "/nix/store/grqh2wygy9f9wp5bgvqn4im76v82zmcx-binutils-2.39/bin/ld: /nix/store/f7yr5z123d162p5457jh3wzkqm7x8yah-glib-2.74.3/lib/libglib-2.0.so: error adding symbols: file in wrong format"
    #   inherit (emulated) stdenv;
    # };
    nautilus = (
      addInputs {
        # fixes: "meson.build:123:0: ERROR: Dependency "libxml-2.0" not found, tried pkgconfig"
        buildInputs = [ final.libxml2 ];
        # fixes: "meson.build:226:6: ERROR: Program 'gtk-update-icon-cache' not found or not executable"
        nativeBuildInputs = [ final.gtk4 ];
      }
      super.nautilus
    ).override {
      # fixes -msse2, -mfpmath=sse flags
      # wrapGAppsHook4 = final.wrapGAppsHook;
      # fixes -msse2, -mfpmath=ssh flags AND "Settings schema 'org.gtk.gtk4.Settings.FileChooser' is not installed"
      wrapGAppsHook4 = emulated.wrapGAppsHook4;
    };

    zenity = super.zenity.override {
      # fixes -msse2, -mfpmath=sse flags
      wrapGAppsHook4 = final.wrapGAppsHook;
    };
  });

  gnome2 = prev.gnome2.overrideScope' (self: super: {
    # inherit (emulated.gnome2)
    #   GConf
    # ;
    # GConf = (
    #   # python3 -> nativeBuildInputs fixes "2to3: command not found"
    #   # glib.dev in nativeBuildInputs fixes "gconfmarshal.list: command not found"
    #   # new error: "** (orbit-idl-2): WARNING **: ./GConfX.idl compilation failed"
    #   addNativeInputs
    #     [ final.glib.dev ]
    #     (mvToNativeInputs [ final.python3 ] super.GConf);
    # );
    GConf = super.GConf.override {
      inherit (emulated) stdenv;
    };

    # gnome_vfs = (
    #   # fixes: "configure: error: gconftool-2 executable not found in your path - should be installed with GConf"
    #   # new error: "configure: error: cannot run test program while cross compiling"
    #   mvToNativeInputs [ self.GConf ] super.gnome_vfs
    # );
    gnome_vfs = useEmulatedStdenv super.gnome_vfs;
    libIDL  = super.libIDL.override {
      # "configure: error: cannot run test program while cross compiling"
      inherit (emulated) stdenv;
    };
    ORBit2 = super.ORBit2.override {
      # "configure: error: Failed to find alignment. Check config.log for details."
      inherit (emulated) stdenv;
    };
  });

  gpodder = prev.gpodder.overridePythonAttrs (upstream: {
    # fix gobject-introspection overrides import that otherwise fails on launch
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      final.buildPackages.gobject-introspection
    ];
    buildInputs = lib.remove final.gobject-introspection upstream.buildInputs;
    strictDeps = true;
  });

  gst_all_1 = prev.gst_all_1 // {
    # inherit (emulated.gst_all_1) gst-plugins-good;
    # gst-plugins-good = prev.gst_all_1.gst-plugins-good.override {
    #   # when invoked with `qt5Support = true`, qtbase shows up in both buildInputs and nativeBuildInputs
    #   # if these aren't identical, then qt complains: "Error: detected mismatched Qt dependencies"
    #   # doesn't fix the original error.
    #   inherit (emulated) stdenv;
    #   # TODO: try removing qtbase from nativeBuildInputs? emulate meson, pkg-config &c?
    #   # qt5Support = true;
    # };
    gst-plugins-good = prev.gst_all_1.gst-plugins-good.overrideAttrs (upstream: {
      nativeBuildInputs = lib.remove final.qt5.qtbase upstream.nativeBuildInputs;
      # TODO: swap in this line instead?
      # buildInputs = lib.remove final.qt5.qtbase upstream.buildInputs;
    });
  };
  gvfs = prev.gvfs.overrideAttrs (upstream: {
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      final.openssh
      final.glib  # fixes "gdbus-codegen: command not found"
    ];
    # fixes "meson.build:312:2: ERROR: Assert failed: http required but libxml-2.0 not found"
    buildInputs = upstream.buildInputs ++ [ final.libxml2 ];
  });

  haskell = prev.haskell // {
    packageOverrides = self: super:
    let
      super' = super // (prev.haskell.packageOverrides self super);
    in
      {
        xml-conduit = super'.xml-conduit.overrideAttrs (upstream: {
          # fails even when compiles on build platform:
          # - `nix build '.#host-pkgs.moby.buildPackages.haskellPackages.xml-conduit'`
          doCheck = false;
        });
      };
  };

  # hdf5 = prev.hdf5.override {
  #   inherit (emulated) stdenv;
  # };

  # "setup: line 1595: ant: command not found"
  i2p = mvToNativeInputs [ final.ant final.gettext ] prev.i2p;

  # ibus = (prev.ibus.override {
  #   inherit (emulated)
  #     stdenv # fixes: "configure: error: cannot run test program while cross compiling"
  #     gobject-introspection # "cannot open shared object ..."
  #   ;
  # });
  # .overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs or [] ++ [
  #     final.glib  # fixes: ImportError: /nix/store/fi1rsalr11xg00dqwgzbf91jpl3zwygi-gobject-introspection-aarch64-unknown-linux-gnu-1.74.0/lib/gobject-introspection/giscanner/_giscanner.cpython-310-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory
  #     final.buildPackages.gobject-introspection  # fixes "_giscanner.cpython-310-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory"
  #   ];
  #   buildInputs = lib.remove final.gobject-introspection upstream.buildInputs ++ [
  #     final.vala  # fixes: "Package `ibus-1.0' not found in specified Vala API directories or GObject-Introspection GIR directories"
  #   ];
  # });

  # fixes "./autogen.sh: line 26: gtkdocize: not found"
  iio-sensor-proxy = mvToNativeInputs [ final.glib final.gtk-doc ] prev.iio-sensor-proxy;

  # fixes: "make: gcc: No such file or directory"
  java-service-wrapper = useEmulatedStdenv prev.java-service-wrapper;

  javaPackages = prev.javaPackages // {
    compiler = prev.javaPackages.compiler // {
      adoptopenjdk-8 = prev.javaPackages.compiler.adoptopenjdk-8 // {
        # fixes "error: auto-patchelf could not satisfy dependency libgcc_s.so.1 wanted by /nix/store/fvln9pahd3c4ys8xv5c0w91xm2347cvq-adoptopenjdk-hotspot-bin-aarch64-unknown-linux-gnu-8.0.322/jre/lib/aarch64/libsunec.so"
        jdk-hotspot  = useEmulatedStdenv prev.javaPackages.compiler.adoptopenjdk-8.jdk-hotspot;
      };
      openjdk8-bootstrap = useEmulatedStdenv prev.javaPackages.compiler.openjdk8-bootstrap;
      # fixes "configure: error: Could not find required tool for WHICH"
      openjdk8 = useEmulatedStdenv prev.javaPackages.compiler.openjdk8;
      # openjdk19 = (
      #   # fixes "configure: error: Could not find required tool for ZIPEXE"
      #   # new failure: "checking for cc... [not found]"
      #   (mvToNativeInputs
      #     [ final.zip ]
      #     (useEmulatedStdenv prev.javaPackages.compiler.openjdk19)
      #   ).overrideAttrs (_upstream: {
      #     # avoid building `support/demos`, which segfaults
      #     buildFlags = [ "product-images" ];
      #     doCheck = false;  # pre-emptive
      #   })
      # );
      openjdk19 = emulated.javaPackages.compiler.openjdk19;
    };
  };

  jellyfin-media-player = mvToBuildInputs
    [ final.libsForQt5.wrapQtAppsHook ]  # this shouldn't be: but otherwise we get mixed qtbase deps
    (prev.jellyfin-media-player.overrideAttrs (upstream: {
      meta = upstream.meta // {
        platforms = upstream.meta.platforms ++ [
          "aarch64-linux"
        ];
      };
    }));
  jellyfin-media-player-qt6 = prev.jellyfin-media-player-qt6.overrideAttrs (upstream: {
    # nativeBuildInputs => result targets x86.
    # buildInputs => result targets correct platform, but doesn't wrap the runtime deps
    # TODO: fix the hook in qt6 itself?
    depsHostHost = upstream.depsHostHost or [] ++ [ final.qt6.wrapQtAppsHook ];
    nativeBuildInputs = lib.remove [ final.qt6.wrapQtAppsHook ] upstream.nativeBuildInputs;
  });
  # jellyfin-web = prev.jellyfin-web.override {
  #   # in node-dependencies-jellyfin-web: "node: command not found"
  #   inherit (emulated) stdenv;
  # };

  kitty = prev.kitty.overrideAttrs (upstream: {
    # fixes: "FileNotFoundError: [Errno 2] No such file or directory: 'pkg-config'"
    PKGCONFIG_EXE = "${final.buildPackages.pkg-config}/bin/${final.buildPackages.pkg-config.targetPrefix}pkg-config";

    # when building docs, kitty's setup.py invokes `sphinx`, which tries to load a .so for the host.
    # on cross compilation, that fails
    KITTY_NO_DOCS = true;
    patches = upstream.patches ++ [
      ./kitty-no-docs.patch
    ];
  });
  komikku = prev.komikku.override {
    # GI_TYPELIB_PATH points to x86_64 types in the default build, only when using wrapGAppsHook4
    wrapGAppsHook4 = final.wrapGAppsHook;
  };
  koreader = (prev.koreader.override {
    # fixes runtime error: luajit: ./ffi/util.lua:757: attempt to call field 'pack' (a nil value)
    inherit (emulated) luajit;
  }).overrideAttrs (upstream: {
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      final.autoPatchelfHook
    ];
  });
  libgweather = rmNativeBuildInputs [ final.glib ] (prev.libgweather.override {
    # alternative to emulating python3 is to specify it in `buildInputs` instead of `nativeBuildInputs` (upstream),
    #   but presumably that's just a different way to emulate it.
    # the python gobject-introspection stuff is a tangled mess that's impossible to debug:
    # don't dig further, leave this for some other dedicated soul.
    inherit (emulated)
      stdenv  # fixes "Run-time dependency vapigen found: NO (tried pkgconfig)"
      gobject-introspection  # fixes gir x86-64 python -> aarch64 shared object import
      python3  # fixes build-aux/meson/gen_locations_variant.py x86-64 python -> aarch64 import of glib
    ;
  });
  # libgweather = prev.libgweather.overrideAttrs (upstream: {
  #   nativeBuildInputs = (lib.remove final.gobject-introspection upstream.nativeBuildInputs) ++ [
  #     final.buildPackages.gobject-introspection  # fails to fix "gi._error.GError: g-invoke-error-quark: Could not locate g_option_error_quark: /nix/store/dsx6kqmyg7f3dz9hwhz7m3jrac4vn3pc-glib-aarch64-unknown-linux-gnu-2.74.3/lib/libglib-2.0.so.0"
  #   ];
  #   # fixes "Run-time dependency vapigen found: NO (tried pkgconfig)"
  #   buildInputs = upstream.buildInputs ++ [ final.vala ];
  # });

  # libsForQt5 = prev.libsForQt5.overrideScope' (self: super: {
  #   qgpgme = super.qgpgme.overrideAttrs (orig: {
  #     # fix so it can find the MOC compiler
  #     # it looks like it might not *need* to propagate qtbase, but so far unclear
  #     nativeBuildInputs = orig.nativeBuildInputs ++ [ self.qtbase ];
  #     propagatedBuildInputs = lib.remove self.qtbase orig.propagatedBuildInputs;
  #   });
  #   phonon = super.phonon.overrideAttrs (orig: {
  #     # fixes "ECM (required version >= 5.60), Extra CMake Modules"
  #     buildInputs = orig.buildInputs ++ [ final.extra-cmake-modules ];
  #   });
  # });
  # libsForQt5 = prev.libsForQt5.overrideScope' (self: super: {
  #   # emulate all the qt5 packages, but rework `libsForQt5.callPackage` and `mkDerivation`
  #   # to use non-emulated stdenv by default.
  #   mkDerivation = self.mkDerivationWith final.stdenv.mkDerivation;
  #   callPackage = self.newScope { inherit (self) qtCompatVersion qtModule srcs; inherit (final) stdenv; };
  # });

  # mepo = (prev.mepo.override {
  #   inherit (emulated)
  #     stdenv
  #     SDL2
  #     SDL2_gfx
  #     SDL2_image
  #     SDL2_ttf
  #     zig
  #   ;
  # }).overrideAttrs (_upstream: {
  #   doCheck = false;
  #   # dontConfigure = true;
  #   # dontBuild = true;
  #   # preInstall = ''
  #   #   export HOME=$TMPDIR
  #   # '';
  #   # installPhase = ''
  #   #   runHook preInstall

  #   #   zig build -Drelease-safe=true -Dtarget=aarch64-linux-gnu -Dcpu=baseline --prefix $out
  #   #   install -d $out/share/man/man1
  #   #   $out/bin/mepo -docman > $out/share/man/man1/mepo.1

  #   #   runHook postInstall
  #   # '';
  # });

  # fixes: "ar: command not found"
  # `ar` is provided by bintools
  ncftp = addNativeInputs [ final.bintools ] prev.ncftp;
  # fixes "gdbus-codegen: command not found"
  networkmanager-fortisslvpn = mvToNativeInputs [ final.glib ] prev.networkmanager-fortisslvpn;
  # networkmanager-iodine = prev.networkmanager-iodine.overrideAttrs (orig: {
  #   # fails to fix "configure.ac:58: error: possibly undefined macro: AM_GLIB_GNU_GETTEXT"
  #   nativeBuildInputs = orig.nativeBuildInputs ++ [ final.gettext ];
  # });
  networkmanager-iodine = prev.networkmanager-iodine.override {
    # fixes "configure.ac:58: error: possibly undefined macro: AM_GLIB_GNU_GETTEXT"
    inherit (emulated) stdenv;
  };
  # networkmanager-iodine = prev.networkmanager-iodine.overrideAttrs (upstream: {
  #   # buildInputs = upstream.buildInputs ++ [ final.intltool final.gettext ];
  #   # nativeBuildInputs = lib.remove final.intltool upstream.nativeBuildInputs;
  #   # nativeBuildInputs = upstream.nativeBuildInputs ++ [ final.gettext ];
  #   postPatch = upstream.postPatch or "" + ''
  #     sed -i s/AM_GLIB_GNU_GETTEXT/AM_GNU_GETTEXT/ configure.ac
  #   '';
  # });

  # fixes "gdbus-codegen: command not found"
  # fixes "gtk4-builder-tool: command not found"
  networkmanager-l2tp = addNativeInputs [ final.gtk4 ]
    (mvToNativeInputs [ final.glib ] prev.networkmanager-l2tp);
  # fixes "properties/gresource.xml: Permission denied"
  #   - by providing glib-compile-resources
  networkmanager-openconnect = mvToNativeInputs [ final.glib ] prev.networkmanager-openconnect;
  # fixes "properties/gresource.xml: Permission denied"
  #   - by providing glib-compile-resources
  networkmanager-openvpn = mvToNativeInputs [ final.glib ] prev.networkmanager-openvpn;
  networkmanager-sstp = (
    # fixes "gdbus-codegen: command not found"
    mvToNativeInputs [ final.glib ] (
      # fixes gtk4-builder-tool wrong format
      addNativeInputs [ final.gtk4.dev ] prev.networkmanager-sstp
    )
  );
  networkmanager-vpnc = mvToNativeInputs [ final.glib ] prev.networkmanager-vpnc;
  # fixes "properties/gresource.xml: Permission denied"
  #   - by providing glib-compile-resources
  nheko = prev.nheko.overrideAttrs (orig: {
    # fixes "fatal error: lmdb++.h: No such file or directory
    buildInputs = orig.buildInputs ++ [ final.lmdbxx ];
  });
  notmuch = prev.notmuch.overrideAttrs (upstream: {
    # fixes "Error: The dependencies of notmuch could not be satisfied"  (xapian, gmime, glib, talloc)
    # when cross-compiling, we only have a triple-prefixed pkg-config which notmuch's configure script doesn't know how to find.
    # so just replace these with the nix-supplied env-var which resolves to the relevant pkg-config.
    postPatch = upstream.postPatch or "" + ''
      sed -i 's/pkg-config/\$PKG_CONFIG/g' configure
    '';
    XAPIAN_CONFIG = final.buildPackages.writeShellScript "xapian-config" ''
      exec ${lib.getBin final.xapian}/bin/xapian-config $@
    '';
    # depsBuildBuild = [ final.gnupg ];
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      final.gnupg  # nixpkgs specifies gpg as a buildInput instead of a nativeBuildInput
      final.perl  # used to build manpages
      # final.pythonPackages.python
      # final.shared-mime-info
    ];
    buildInputs = with final; [
      xapian gmime3 talloc zlib  # dependencies described in INSTALL
      # perl
      # pythonPackages.python
      ruby  # notmuch links against ruby.so
    ];
    # buildInputs =
    #   (lib.remove
    #     final.perl
    #     (lib.remove
    #       final.gmime
    #       (lib.remove final.gnupg upstream.buildInputs)
    #     )
    #   ) ++ [ final.gmime ];
  });
  # notmuch = (prev.notmuch.override {
  #   inherit (emulated)
  #     stdenv
  #     # gmime
  #   ;
  #   gmime = emulated.gmime3;
  # }).overrideAttrs (upstream: {
  #   postPatch = upstream.postPatch or "" + ''
  #     sed -i 's/pkg-config/\$PKG_CONFIG/g' configure
  #   '';
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     final.gnupg
  #     final.perl
  #   ];
  #   buildInputs = lib.remove final.gnupg upstream.buildInputs;
  # });
  # notmuch = prev.notmuch.overrideAttrs (upstream: {
  #   # fixes "Error: The dependencies of notmuch could not be satisfied"  (xapian, gmime, glib, talloc)
  #   # when cross-compiling, we only have a triple-prefixed pkg-config which notmuch's configure script doesn't know how to find.
  #   # so just replace these with the nix-supplied env-var which resolves to the relevant pkg-config.
  #   postPatch = upstream.postPatch or "" + ''
  #     sed -i 's/pkg-config/\$PKG_CONFIG/g' configure
  #     sed -i 's: gpg : ${final.buildPackages.gnupg}/bin/gpg :' configure
  #   '';
  #   XAPIAN_CONFIG = final.buildPackages.writeShellScript "xapian-config" ''
  #     exec ${lib.getBin final.xapian}/bin/xapian-config $@
  #   '';
  #   # depsBuildBuild = upstream.depsBuildBuild or [] ++ [
  #   #   final.buildPackages.stdenv.cc
  #   # ];
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     # final.gnupg
  #     final.perl
  #   ];
  #   # buildInputs = lib.remove final.gnupg upstream.buildInputs;
  # });

  # fixes "/nix/store/0wk6nr1mryvylf5g5frckjam7g7p9gpi-bash-5.2-p15/bin/bash: line 2: --prefix=ods_manager: command not found"
  # - dbus-glib should maybe be removed from buildInputs, too? but doing so breaks upstream configure
  obex_data_server = addNativeInputs [ final.dbus-glib ] prev.obex_data_server;
  openfortivpn = prev.openfortivpn.override {
    # fixes "checking for /proc/net/route... configure: error: cannot check for file existence when cross compiling"
    inherit (emulated) stdenv;
  };
  ostree = prev.ostree.override {
    # fixes "configure: error: Need GPGME_PTHREAD version 1.1.8 or later"
    inherit (emulated) stdenv;
  };
  # ostree = prev.ostree.overrideAttrs (upstream: {
  #   # fixes: "configure: error: Need GPGME_PTHREAD version 1.1.8 or later"
  #   # new failure mode: "./src/libotutil/ot-gpg-utils.h:22:10: fatal error: gpgme.h: No such file or directory"
  #   # buildInputs = lib.remove final.gpgme upstream.buildInputs;
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [ final.gpgme ];
  # });

  # phoc = prev.phoc.override {
  #   # fixes "Program wayland-scanner found: NO"
  #   inherit (emulated) stdenv;
  # };
  # fixes (meson) "Program 'glib-mkenums mkenums' not found or not executable"
  phoc = mvToNativeInputs [ final.wayland-scanner final.glib ] prev.phoc;
  phosh = prev.phosh.overrideAttrs (upstream: {
    buildInputs = upstream.buildInputs ++ [
      final.libadwaita  # "plugins/meson.build:41:2: ERROR: Dependency "libadwaita-1" not found, tried pkgconfig"
    ];
    mesonFlags = upstream.mesonFlags ++ [
      "-Dphoc_tests=disabled"  # "tests/meson.build:20:0: ERROR: Program 'phoc' not found or not executable"
    ];
    # postPatch = upstream.postPatch or "" + ''
    #   sed -i 's:gio_querymodules = :gio_querymodules = "${final.buildPackages.glib.dev}/bin/gio-querymodules" if True else :' build-aux/post_install.py
    # '';
  });
  # phosh-mobile-settings = prev.phosh-mobile-settings.override {
  #   # fixes "meson.build:26:0: ERROR: Dependency "phosh-plugins" not found, tried pkgconfig"
  #   inherit (emulated) stdenv;
  # };
  phosh-mobile-settings = mvInputs {
    # fixes "meson.build:26:0: ERROR: Dependency "phosh-plugins" not found, tried pkgconfig"
    # phosh is used only for its plugins; these are specified as a runtime dep in src.
    # it's correct for them to be runtime dep: src/ms-lockscreen-panel.c loads stuff from
    buildInputs = [ final.phosh ];
    nativeBuildInputs = [
      final.gettext  # fixes "data/meson.build:1:0: ERROR: Program 'msgfmt' not found or not executable"
      final.wayland-scanner  # fixes "protocols/meson.build:7:0: ERROR: Program 'wayland-scanner' not found or not executable"
      final.glib  # fixes "src/meson.build:1:0: ERROR: Program 'glib-mkenums mkenums' not found or not executable"
      final.desktop-file-utils  # fixes "meson.build:116:8: ERROR: Program 'update-desktop-database' not found or not executable"
    ];
  } prev.phosh-mobile-settings;
  # psqlodbc = prev.psqlodbc.override {
  #   # fixes "configure: error: odbc_config not found (required for unixODBC build)"
  #   inherit (emulated) stdenv;
  # };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (py-final: py-prev: {

      aiohttp = py-prev.aiohttp.overridePythonAttrs (orig: {
        # fixes "ModuleNotFoundError: No module named 'setuptools'"
        propagatedBuildInputs = orig.propagatedBuildInputs ++ [
          py-final.setuptools
        ];
      });

      cryptography = py-prev.cryptography.override {
        inherit (emulated) cargo rustc rustPlatform;  # "cargo:warning=aarch64-unknown-linux-gnu-gcc: error: unrecognized command-line option ‘-m64’"
      };

      defcon = py-prev.defcon.overridePythonAttrs (orig: {
        nativeBuildInputs = orig.nativeBuildInputs ++ orig.nativeCheckInputs;
      });
      executing = py-prev.executing.overridePythonAttrs (orig: {
        # test has an assertion that < 1s of CPU time elapsed => flakey
        disabledTestPaths = orig.disabledTestPaths or [] ++ [
          # "tests/test_main.py::TestStuff::test_many_source_for_filename_calls"
          "tests/test_main.py"
        ];
      });
      gssapi = py-prev.gssapi.overridePythonAttrs (_orig: {
        # "krb5-aarch64-unknown-linux-gnu-1.20.1/lib/libgssapi_krb5.so: cannot open shared object file"
        # setup.py only needs this to detect if kerberos was configured with gssapi support (not sure why it doesn't call krb5-config for that?)
        # it doesn't actually link or use anything from the build krb5 except a "canary" symobl.
        GSSAPI_MAIN_LIB = "${final.buildPackages.krb5}/lib/libgssapi_krb5.so";
      });
      # h5py = py-prev.h5py.overridePythonAttrs (orig: {
      #   # XXX: can't upstream until its dependency, hdf5, is fixed. that looks TRICKY.
      #   # - the `setup_configure.py` in h5py tries to dlopen (and call into) the hdf5 lib to query the version and detect features like MPI
      #   # - it could be patched with ~10 LoC in the HDF5LibWrapper class.
      #   #
      #   # expose numpy and hdf5 as available at build time
      #   nativeBuildInputs = orig.nativeBuildInputs ++ orig.propagatedBuildInputs ++ orig.buildInputs;
      #   buildInputs = [];
      #   # HDF5_DIR = "${hdf5}";
      # });
      ipython = py-prev.ipython.overridePythonAttrs (orig: {
        # fixes "FAILED IPython/terminal/tests/test_debug_magic.py::test_debug_magic_passes_through_generators - pexpect.exceptions.TIMEOUT: Timeout exceeded."
        disabledTests = orig.disabledTests ++ [ "test_debug_magic_passes_through_generator" ];
      });
      mutatormath = py-prev.mutatormath.overridePythonAttrs (orig: {
        nativeBuildInputs = orig.nativeBuildInputs or [] ++ orig.nativeCheckInputs;
      });
      pandas = py-prev.pandas.overridePythonAttrs (orig: {
        # XXX: we only actually need numpy when building in ~/nixpkgs repo: not sure why we need all the propagatedBuildInputs here.
        # nativeBuildInputs = orig.nativeBuildInputs ++ [ py-final.numpy ];
        nativeBuildInputs = orig.nativeBuildInputs ++ orig.propagatedBuildInputs;
      });
      psycopg2 = py-prev.psycopg2.overridePythonAttrs (orig: {
        # TODO: upstream  (see tracking issue)
        #
        # psycopg2 *links* against libpg, so we need the host postgres available at build time!
        # present-day nixpkgs only includes it in nativeBuildInputs
        buildInputs = orig.buildInputs ++ [ final.postgresql ];
      });
      s3transfer = py-prev.s3transfer.overridePythonAttrs (orig: {
        # tests explicitly expect host CPU == build CPU
        # Bail out! ERROR:../plugins/core.c:221:qemu_plugin_vcpu_init_hook: assertion failed: (success)
        # Bail out! ERROR:../accel/tcg/cpu-exec.c:954:cpu_exec: assertion failed: (cpu == current_cpu)
        disabledTestPaths = orig.disabledTestPaths ++ [
          # "tests/functional/test_processpool.py::TestProcessPoolDownloader::test_cleans_up_tempfile_on_failure"
          "tests/functional/test_processpool.py"
          # "tests/unit/test_compat.py::TestBaseManager::test_can_provide_signal_handler_initializers_to_start"
          "tests/unit/test_compat.py"
        ];
      });
      scipy = py-prev.scipy.override {
        inherit (emulated) stdenv;
      };
      # scipy = py-prev.scipy.overridePythonAttrs (orig: {
      #   # "/nix/store/yhz6yy9bp52x9fvcda4lr6kgsngxnv2l-python3.10-numpy-1.24.2/lib/python3.10/site-packages/numpy/core/include/../lib/libnpymath.a: error adding symbols: file in wrong format"
      #   # mesonFlags = orig.mesonFlags or [] ++ [ "-Duse-pythran=false" ];
      #   # don't know how to plumb meson falgs through python apps
      #   # postPatch = orig.postPatch or "" + ''
      #   #   sed -i "s/option('use-pythran', type: 'boolean', value: true,/option('use-pythran', type: 'boolean', value: false,/" meson_options.txt
      #   # '';
      #   SCIPY_USE_PYTHRAN = false;
      #   nativeBuildInputs = lib.remove py-final.pythran orig.nativeBuildInputs;
      # });
      # skia-pathops = ?
      #   it tries to call `cc` during the build, but can't find it.
    })
  ];

  # qt5 = prev.qt5.overrideScope' (self: super: {
  #   qtbase = super.qtbase.override {
  #     inherit (emulated) stdenv;
  #   };
  #   qtx11extras = super.qtx11extras.override {
  #     # "Project ERROR: Cannot run compiler 'g++'";
  #     # this fails an assert though, where the cross qt now references the emulated qt.
  #     inherit (emulated.qt5) qtModule;
  #   };
  # });
  qt5 = emulated.qt5.overrideScope' (self: super: {
    # emulate all the qt5 packages, but rework `libsForQt5.callPackage` and `mkDerivation`
    # to use non-emulated stdenv by default.
    mkDerivation = self.mkDerivationWith final.stdenv.mkDerivation;
    callPackage = self.newScope { inherit (self) qtCompatVersion qtModule srcs; inherit (final) stdenv; };
  });
  qt6 = prev.qt6.overrideScope' (self: super: {
    # # inherit (emulated.qt6) qtModule;
    # qtbase = super.qtbase.overrideAttrs (upstream: {
    #   # cmakeFlags = upstream.cmakeFlags ++ lib.optionals (final.stdenv.buildPlatform != final.stdenv.hostPlatform) [
    #   cmakeFlags = upstream.cmakeFlags ++ lib.optionals (final.stdenv.buildPlatform != final.stdenv.hostPlatform) [
    #     # "-DCMAKE_CROSSCOMPILING=True" # fails to solve QT_HOST_PATH error
    #     "-DQT_HOST_PATH=${final.buildPackages.qt6.full}"
    #   ];
    # });
    # qtModule = args: (super.qtModule args).overrideAttrs (upstream: {
    #   # the nixpkgs comment about libexec seems to be outdated:
    #   # it's just that cross-compiled syncqt.pl doesn't get its #!/usr/bin/env shebang replaced.
    #   preConfigure = lib.replaceStrings
    #     ["${lib.getDev self.qtbase}/libexec/syncqt.pl"]
    #     ["perl ${lib.getDev self.qtbase}/libexec/syncqt.pl"]
    #     upstream.preConfigure;
    # });
    # # qtwayland = super.qtwayland.overrideAttrs (upstream: {
    # #   preConfigure = "fixQtBuiltinPaths . '*.pr?'";
    # # });
    # # qtwayland = super.qtwayland.override {
    # #   inherit (self) qtbase;
    # # };
    # # qtbase = super.qtbase.override {
    # #   # fixes: "You need to set QT_HOST_PATH to cross compile Qt."
    # #   inherit (emulated) stdenv;
    # # };

    qtwebengine = super.qtwebengine.overrideAttrs (upstream: {
      # depsBuildBuild = upstream.depsBuildBuild or [] ++ [ final.pkg-config ];
      # XXX: qt seems to use its own terminology for "host" and "target":
      # - <https://www.qt.io/blog/qt6-development-hosts-and-targets>
      # - "host" = machine invoking the compiler
      # - "target" = machine on which the resulting qtwebengine.so binaries will run
      # XXX: NIX_CFLAGS_COMPILE_<machine> is how we get the `-isystem <dir>` flags.
      #      probably we shouldn't blindly copy these from host machine to build machine,
      #      as the headers could reasonably make different assumptions.
      preConfigure = upstream.preConfigure + ''
        # export PKG_CONFIG_HOST="$PKG_CONFIG"
        export PKG_CONFIG_HOST="$PKG_CONFIG_FOR_BUILD"
        # expose -isystem <zlib> to x86 builds
        export NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu="$NIX_CFLAGS_COMPILE"
        export NIX_LDFLAGS_x86_64_unknown_linux_gnu="-L${final.buildPackages.zlib}/lib"
      '';
      patches = upstream.patches or [] ++ [
        # ./qtwebengine-host-pkg-config.patch
        # alternatively, look at dlopenBuildInputs
        ./qtwebengine-host-cc.patch
      ];
      # patch the qt pkg-config script to show us more debug info
      postPatch = upstream.postPatch or "" + ''
        sed -i s/options.debug/True/g src/3rdparty/chromium/build/config/linux/pkg-config.py
      '';
      nativeBuildInputs = upstream.nativeBuildInputs ++ [
        final.bintools-unwrapped  # for readelf
        final.buildPackages.cups  # for cups-config
        final.buildPackages.fontconfig
        final.buildPackages.glib
        final.buildPackages.harfbuzz
        final.buildPackages.icu
        final.buildPackages.libjpeg
        final.buildPackages.libpng
        final.buildPackages.libwebp
        final.buildPackages.nss
        # final.gcc-unwrapped.libgcc  # for libgcc_s.so
        final.buildPackages.zlib
      ];
      depsBuildBuild = upstream.depsBuildBuild or [] ++ [ final.pkg-config ];
      # buildInputs = upstream.buildInputs ++ [
      #   final.gcc-unwrapped.libgcc  # for libgcc_s.so. this gets loaded during build, suggesting i surely messed something up
      # ];
      # buildInputs = upstream.buildInputs ++ [
      #   final.gcc-unwrapped.libgcc
      # ];
      # nativeBuildInputs = upstream.nativeBuildInputs ++ [
      #   final.icu
      # ];
      # buildInputs = upstream.buildInputs ++ [
      #   final.icu
      # ];
      # env.NIX_DEBUG="1";
      # env.NIX_DEBUG="7";
      # cmakeFlags = lib.remove "-DQT_FEATURE_webengine_system_icu=ON" upstream.cmakeFlags;
      cmakeFlags = upstream.cmakeFlags ++ lib.optionals (final.stdenv.hostPlatform != final.stdenv.buildPlatform) [
        # "--host-cc=${final.buildPackages.stdenv.cc}/bin/cc"
        # "--host-cxx=${final.buildPackages.stdenv.cc}/bin/c++"
        # these are my own vars, used by my own patch
        "-DCMAKE_HOST_C_COMPILER=${final.buildPackages.stdenv.cc}/bin/gcc"
        "-DCMAKE_HOST_CXX_COMPILER=${final.buildPackages.stdenv.cc}/bin/g++"
        "-DCMAKE_HOST_AR=${final.buildPackages.stdenv.cc}/bin/ar"
        "-DCMAKE_HOST_NM=${final.buildPackages.stdenv.cc}/bin/nm"
      ];
    });
  });

  rmlint = prev.rmlint.override {
    # fixes "Checking whether the C compiler works... no"
    # rmlint is scons; it reads the CC environment variable, though, so *may* be cross compilable
    inherit (emulated) stdenv;
  };
  # samba = prev.samba.overrideAttrs (_upstream: {
  #   # we get "cannot find C preprocessor: aarch64-unknown-linux-gnu-cpp", but ONLY when building with the ccache stdenv.
  #   # this solves that, but `CPP` must be a *single* path -- not an expression.
  #   # i do not understand how the original error arises, as my ccacheStdenv should match the API of the base stdenv (except for cpp being a symlink??).
  #   # but oh well, this fixes it.
  #   CPP = final.buildPackages.writeShellScript "cpp" ''
  #     exec ${lib.getBin final.stdenv.cc}/bin/${final.stdenv.cc.targetPrefix}cc -E $@;
  #   '';
  # });
  # sequoia = prev.sequoia.override {
  #   # fails to fix original error
  #   inherit (emulated) stdenv;
  # };

  spandsp = prev.spandsp.overrideAttrs (upstream: {
    configureFlags = upstream.configureFlags or [] ++ [
      # fixes runtime error: "undefined symbol: rpl_realloc"
      # source is <https://github.com/NixOS/nixpkgs/pull/57825>
      "ac_cv_func_malloc_0_nonnull=yes"
      "ac_cv_func_realloc_0_nonnull=yes"
    ];
  });

  # squeekboard = prev.squeekboard.overrideAttrs (upstream: {
  #   # fixes: "meson.build:1:0: ERROR: 'rust' compiler binary not defined in cross or native file"
  #   # new error: "meson.build:1:0: ERROR: Rust compiler rustc --target aarch64-unknown-linux-gnu -C linker=aarch64-unknown-linux-gnu-gcc can not compile programs."
  #   # NB(2023/03/04): upstream nixpkgs has a new squeekboard that's closer to cross-compiling; use that
  #   mesonFlags =
  #     let
  #       # ERROR: 'rust' compiler binary not defined in cross or native file
  #       crossFile = final.writeText "cross-file.conf" ''
  #         [binaries]
  #         rust = [ 'rustc', '--target', '${final.rust.toRustTargetSpec final.stdenv.hostPlatform}' ]
  #       '';
  #     in
  #       # upstream.mesonFlags or [] ++
  #       [
  #         "-Dtests=false"
  #         "-Dnewer=false"
  #         "-Donline=false"
  #       ]
  #       ++ lib.optional
  #         (final.stdenv.hostPlatform != final.stdenv.buildPlatform)
  #         "--cross-file=${crossFile}"
  #       ;

  #   cargoDeps = null;
  #   cargoVendorDir = "vendor";

  #   depsBuildBuild = upstream.depsBuildBuild or [] ++ [
  #     final.pkg-config
  #   ];
  #   nativeBuildInputs = with final; [
  #     meson
  #     ninja
  #     pkg-config
  #     glib
  #     wayland
  #     wrapGAppsHook
  #     rustPlatform.cargoSetupHook
  #     cargo
  #     rustc
  #   ];
  # });

  squeekboard = prev.squeekboard.override {
    inherit (emulated)
      rustPlatform  # fixes original "'rust' compiler binary not defined in cross or native file"
      rustc
      cargo
      stdenv  # fixes "gcc: error: unrecognized command line option '-m64'"
      glib  # fixes error when linking src/squeekboard: "/nix/store/3c0dqm093ylw8ks7myzxdaif0m16rgcl-binutils-2.40/bin/ld: /nix/store/jzh15bi6zablx3d9s928w3lgqy6and91-glib-2.74.3/lib/libgio-2.0.so"
      wayland  # fixes error when linking src/squeekboard: "/nix/store/3c0dqm093ylw8ks7myzxdaif0m16rgcl-binutils-2.40/bin/ld: /nix/store/ni0vb1pnaznx85378i3h9xhw9cay68g5-wayland-1.21.0/lib/libwayland-client.so: error adding symbols: file in wrong format"
      # gtk3  # fails to fix: "/nix/store/acl3fg3z4i96d6lha2cbr16k7bl1zjs5-binutils-2.40/bin/ld: /nix/store/k2jd14yl5qcl3kwifhhs271607fjafbx-gtk+3-3.24.36/lib/libgtk-3.so: error adding symbols: file in wrong format"
      wrapGAppsHook  # introduces a competing gtk3 at link-time, unless emulated
    ;
  };

  sysprof = (
    # fixes: "src/meson.build:12:2: ERROR: Program 'gdbus-codegen' not found or not executable"
    mvToNativeInputs [ final.glib ] prev.sysprof
  ).override {
    # fixes -msse2, -mfpmath=sse flags
    wrapGAppsHook4 = final.wrapGAppsHook;
  };
  tracker-miners = prev.tracker-miners.override {
    # fixes "meson.build:183:0: ERROR: Can not run test applications in this cross environment."
    inherit (emulated) stdenv;
  };
  tuba = (prev.tuba.override {
    # fixes -msse2, -mfpmath=sse flags
    wrapGAppsHook4 = final.wrapGAppsHook;
  }).overrideAttrs (upstream: {
    # error: Package `{libadwaita-1,gtksourceview-5,libsecret-1,gee-0.8}' not found in specified Vala API directories or GObject-Introspection GIR directories
    buildInputs = upstream.buildInputs ++ [ final.vala ];
  });
  # twitter-color-emoji = prev.twitter-color-emoji.override {
  #   # fails to fix original error
  #   inherit (emulated) stdenv;
  # };

  # fixes: "ar: command not found"
  # `ar` is provided by bintools
  unar = addNativeInputs [ final.bintools ] prev.unar;
  unixODBCDrivers = prev.unixODBCDrivers // {
    # TODO: should this package be deduped with toplevel psqlodbc in upstream nixpkgs?
    psql = prev.unixODBCDrivers.psql.overrideAttrs (_upstream: {
      # XXX: these are both available as configureFlags, if we prefer that (we probably do, so as to make them available only during specific parts of the build).
      ODBC_CONFIG = final.buildPackages.writeShellScript "odbc_config" ''
        exec ${final.stdenv.hostPlatform.emulator final.buildPackages} ${final.unixODBC}/bin/odbc_config $@
      '';
      PG_CONFIG = final.buildPackages.writeShellScript "pg_config" ''
        exec ${final.stdenv.hostPlatform.emulator final.buildPackages} ${final.postgresql}/bin/pg_config $@
      '';
    });
  };

  visidata = prev.visidata.override {
    # hdf5 / h5py don't cross-compile, but i don't use that file format anyway.
    # setting this to null means visidata will work as normal but not be able to load hdf files.
    h5py = null;
  };
  vlc = prev.vlc.overrideAttrs (orig: {
    # fixes: "configure: error: could not find the LUA byte compiler"
    # fixes: "configure: error: protoc compiler needed for chromecast was not found"
    nativeBuildInputs = orig.nativeBuildInputs ++ [ final.lua5 final.protobuf ];
    # fix that it can't find the c compiler
    # makeFlags = orig.makeFlags or [] ++ [ "CC=${prev.stdenv.cc.targetPrefix}cc" ];
    BUILDCC = "${prev.stdenv.cc}/bin/${prev.stdenv.cc.targetPrefix}cc";
  });
  # fixes "perl: command not found"
  vpnc = mvToNativeInputs [ final.perl ] prev.vpnc;
  wrapGAppsHook4 = prev.wrapGAppsHook4.override {
    gtk3 = final.emptyDirectory;
  };
  xapian = prev.xapian.overrideAttrs (upstream: {
    # the output has #!/bin/sh scripts.
    # - shebangs get re-written on native build, but not cross build
    buildInputs = upstream.buildInputs ++ [ final.bash ];
  });
  # fixes "No package 'xdg-desktop-portal' found"
  xdg-desktop-portal-gtk = mvToBuildInputs [ final.xdg-desktop-portal ] prev.xdg-desktop-portal-gtk;
  # fixes: "data/meson.build:33:5: ERROR: Program 'msgfmt' not found or not executable"
  # fixes: "src/meson.build:25:0: ERROR: Program 'gdbus-codegen' not found or not executable"
  xdg-desktop-portal-gnome = (
    addNativeInputs [ final.wayland-scanner ] (
      mvToNativeInputs [ final.gettext final.glib ] prev.xdg-desktop-portal-gnome
    )
  ).override {
    # fixes -msse2, -mfpmath=sse flags
    wrapGAppsHook4 = final.wrapGAppsHook;
  };
  # "fatal error: urcu.h: No such file or directory"
  # xfsprogs wants to compile things for the build target (BUILD_CC)
  # xfsprogs = useEmulatedStdenv prev.xfsprogs;
  xfsprogs = addNativeInputs [ final.liburcu ] prev.xfsprogs;
  # webkitgtk = prev.webkitgtk.override { stdenv = final.ccacheStdenv; };
  # webp-pixbuf-loader = prev.webp-pixbuf-loader.override {
  #   # fixes "Builder called die: Cannot wrap '/nix/store/kpp8qhzdjqgvw73llka5gpnsj0l4jlg8-gdk-pixbuf-aarch64-unknown-linux-gnu-2.42.10/bin/gdk-pixbuf-thumbnailer' because it is not an executable file"
  #   # new failure mode: "/nix/store/grqh2wygy9f9wp5bgvqn4im76v82zmcx-binutils-2.39/bin/ld: /nix/store/2syg6jxk8zi1zkpqvkxkz87x8sl27c6b-gdk-pixbuf-2.42.10/lib/libgdk_pixbuf-2.0.so: error adding symbols: file in wrong format"
  #   inherit (emulated) stdenv;
  # };
  webp-pixbuf-loader = prev.webp-pixbuf-loader.overrideAttrs (upstream: {
    # fixes: "Builder called die: Cannot wrap '/nix/store/kpp8qhzdjqgvw73llka5gpnsj0l4jlg8-gdk-pixbuf-aarch64-unknown-linux-gnu-2.42.10/bin/gdk-pixbuf-thumbnailer' because it is not an executable file"
    # gdk-pixbuf doesn't create a `bin/` directory when cross-compiling, breaks some thumbnailing stuff.
    # - gnome's gdk-pixbuf *explicitly* doesn't build thumbnailer on cross builds
    # see `librsvg` for a more bullet-proof cross-compilation approach
    postInstall = "";
  });
  # XXX: aarch64 webp-pixbuf-loader wanted by gdk-pixbuf-loaders.cache.drv, wanted by aarch64 gnome-control-center

  wrapFirefox = prev.wrapFirefox.override {
    buildPackages = let
      bpkgs = final.buildPackages;
    in bpkgs // {
      # fixes "extract-binary-wrapper-cmd: line 2: strings: command not found"
      # ^- in the `nix log` output of cross-compiled `firefox` (it's non-fatal)
      makeBinaryWrapper = bpkgs.makeBinaryWrapper.overrideAttrs (upstream: {
        passthru.extractCmd = bpkgs.writeShellScript "extract-binary-wrapper-cmd" ''
          ${final.stdenv.cc.targetPrefix}strings -dw "$1" | sed -n '/^makeCWrapper/,/^$/ p'
        '';
      });
    };
  };

  wvkbd = (
    # "wayland-scanner: no such program"
    mvToNativeInputs [ final.wayland-scanner ] prev.wvkbd
  ).overrideAttrs (upstream: {
    postPatch = upstream.postPatch or "" + ''
      substituteInPlace Makefile \
        --replace "pkg-config" "$PKG_CONFIG"
    '';
  });
}
