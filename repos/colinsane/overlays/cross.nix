# outstanding issues:
# - 2023/10/10: build python3 is pulled in by many things
#   - nix why-depends --all /nix/store/8g3kd2jxifq10726p6317kh8srkdalf5-nixos-system-moby-23.11.20231011.dirty /nix/store/pzf6dnxg8gf04xazzjdwarm7s03cbrgz-python3-3.10.12/bin/python3.10
#   - blueman
#   - gstreamer-vaapi -> gstreamer-dev -> glib-dev
#   - phog -> gnome-shell
#   - portfolio -> {glib,cairo,pygobject}-dev
#   - komikku -> python3.10-brotlicffi -> python3.10-cffi
#   - many others. python3.10-cffi seems to be the offender which infects 70% of consumers though
# - 2023/10/11: build ruby is pulled in by `neovim`:
#   - nix why-depends --all /nix/store/rhli8vhscv93ikb43639c2ysy3a6dmzp-nixos-system-moby-23.11.20231011.30c7fd8 /nix/store/5xbwwbyjmc1xvjzhghk6r89rn4ylidv8-ruby-3.1.4
#
# partially fixed:
# - 2023/10/11: build coreutils pulled in by rpm 4.18.1, but NOT by 4.19.0
#   - nix why-depends --all /nix/store/gjwd2x507x7gjycl5q0nydd39d3nkwc5-dtrx-8.5.3-aarch64-unknown-linux-gnu /nix/store/y9gr7abwxvzcpg5g73vhnx1fpssr5frr-coreutils-9.3
#
# upstreaming status:
#
# - blueman builds on servo branch
# - libgudev builds on servo branch
#
# - argyllcms needs investigation on servo
# - directfb needs investigation on servo
# - evolution-data-server needs investigation on servo
# - gnome-clocks needs investigation on servo
# - ibus needs investigation on servo
# - luajit needs investigation on servo
# - rpm needs investigation on servo
# - waybar needs investigation on servo
# - webkitgtk build fails at the nix layer (OOM?)
#
# non-binfmt build status:
# - webkitgtk fails 90% through build:
#   - ```
#     [6376/6819] Generating ../../WebKitGTK/DerivedSources/pointer-constraints-unstable-v1-protocol.c
#     FAILED: WebKitGTK/DerivedSources/pointer-constraints-unstable-v1-protocol.c /build/webkitgtk-2.40.5/build/WebKitGTK/DerivedSources/pointer-constraints-unstable-v1-protocol.c 
#     cd /build/webkitgtk-2.40.5/build/Source/WebKit && /nix/store/6xbpap00kkdgrayizbc61mzf19ygsp9j-wayland-aarch64-unknown-linux-gnu-1.22.0-bin/bin/wayland-scanner private-code //nix/store/26nypvflsc8ggbdkns0wjvh4mjrj>
#     /nix/store/6xbpap00kkdgrayizbc61mzf19ygsp9j-wayland-aarch64-unknown-linux-gnu-1.22.0-bin/bin/wayland-scanner: line 5: syntax error: unterminated quoted string
#     ```
# - x11_ssh_askpass fails with tricky wants-to-run-its-own-compiled-code issue (imake)
# - tuba fails trying to invoke the aarch64 gettext during build
# - rpm (wanted by dtrx, but technically optional) fails during configure; can't find python
# - portfolio fails during meson configure; finds host python, can't execute it
# - neovim-ruby fails; tries to run host ruby
# - luajit fails; tries to run the host gcc
# - cozy fails during install; can't run post_install_desktop_database.py
#
# outstanding issues for software i don't have deployed:
# - gdk-pixbuf doesn't generate `gdk-pixbuf-thumbnailer` on cross
#   - been this way since 2018: <https://gitlab.gnome.org/GNOME/gdk-pixbuf/-/merge_requests/20>
#   - as authored upstream, thumbnailer depends on loader.cache, and neither are built during cross compilation.
#   - nixos manually builds loader.cache in postInstall (via emulator).
#   - even though we have loader.cache, ordering means that thumbnailer still can't be built.
#   - solution is probably to integrate meson's cross_file stuff, and pushing all this emulation upstream.

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
  rmNativeInputs = nativeBuildInputs: rmInputs { inherit nativeBuildInputs; };
  # move items from buildInputs into nativeBuildInputs, or vice-versa.
  # arguments represent the final location of specific inputs.
  mvInputs = { buildInputs ? [], nativeBuildInputs ? [] }: pkg:
    addInputs { buildInputs = buildInputs; nativeBuildInputs = nativeBuildInputs; }
    (
      rmInputs { buildInputs = nativeBuildInputs; nativeBuildInputs = buildInputs; }
      pkg
    );

  wrapGAppsHook4Fix = p: rmNativeInputs [ final.wrapGAppsHook4 ] (addNativeInputs [ final.wrapGAppsNoGuiHook final.gtk4 ] p);

  dontCheck = p: p.overrideAttrs (_: {
    doCheck = false;
  });
  useEmulatedStdenv = p: p.override {
    inherit (emulated) stdenv;
  };
  emulated = mkEmulated final prev;

  linuxMinimal = final.linux.override {
    # customize stock linux to compile using fewer resources.
    # on desko, takes 24 min v.s. 35~40 min for linux-megous
    # default config is in:
    # - <pkgs/os-specific/linux/kernel/common-config.nix>
    # documentation per config option is found with, for example:
    # - `fd Kconfig . | xargs rg 'config SUNRPC_DEBUG'`
    structuredExtraConfig = with lib.kernel; {
      # recommended by: <https://nixos.wiki/wiki/Linux_kernel#Too_high_ram_usage>
      DEBUG_INFO_BTF = lib.mkForce no;

      # other debug-related things i can probably disable
      CC_OPTIMIZE_FOR_SIZE = lib.mkForce yes;
      DEBUG_INFO = lib.mkForce no;
      DEBUG_KERNEL = lib.mkForce no;
      GDB_SCRIPTS = lib.mkForce no;
      SCHED_DEBUG = lib.mkForce no;
      SUNRPC_DEBUG = lib.mkForce no;

      # disable un-needed features
      BT = no;
      CAN = no;
      DRM = no;  # uses a lot of space when compiling
      FPGA = no;
      GNSS = no;
      IIO = no;  # 500 MB
      INPUT_TOUCHSCREEN = no;
      MEDIA_SDR_SUPPORT = no;
      NFC = no;
      SND = no;  # also uses a lot of disk space when compiling
      SOUND = no;
      WAN = no;  # X.25 protocol support
      WIRELESS = no;  # 1.4 GB (drivers/net/wireless), doesn't actually disable this
      WWAN = no;  # Wireless WAN
      # disable features nixos explicitly enables, which we still don't need
      FONTS = lib.mkForce no;
      FB = lib.mkForce no;
      # INET = no;  # TCP/IP. `INET` means "IP network" (even when used on a LAN), not "Internet"
      MEMTEST = lib.mkForce no;
      # # NET = lib.mkForce no;  # we need net (9pnet_virtio; unix) for sharing fs with the build machine
      MEDIA_ANALOG_TV_SUPPORT = lib.mkForce no;
      MEDIA_CAMERA_SUPPORT = lib.mkForce no;
      MEDIA_DIGITAL_TV_SUPPORT = lib.mkForce no;  # 150 MB disk space when compiling
      MICROCODE = lib.mkForce no;
      STAGING = lib.mkForce no;  # 450 MB disk space when compiling
    };
  };
  # given a package that's defined for build == host,
  # build it from the native build machine by emulating the builder.
  emulateBuilderQemu = pkg: let
    inherit (final) vmTools;
    # vmTools = final.vmTools.override {
    #   kernel = final.linux-megous or final.linux;  #< HACK: guess at whatever deployed linux we're using, to avoid building two kernels
    # };
    # fix up the nixpkgs command that runs a Linux OS inside QEMU:
    # qemu_kvm doesn't support x86_64 -> aarch64; but full qemu package does.
    qemu = final.buildPackages.qemu.override {
      # disable a bunch of unneeded features, particularly graphics.
      # this avoids a mesa build failure (2023/10/26).
      smartcardSupport = false;
      spiceSupport = false;
      openGLSupport = false;
      virglSupport = false;
      vncSupport = false;
      gtkSupport = false;
      sdlSupport = false;
      pulseSupport = false;
      pipewireSupport = false;
      smbdSupport = false;
      seccompSupport = false;
      enableDocs = false;
    };
    # qemuCommandLinux = lib.replaceStrings
    #   [ "${final.buildPackages.qemu_kvm}" ]
    #   [ "${qemu}" ]
    #   vmTools.qemuCommandLinux;
    # this qemuCommandLinux is effectively an inline substitution of the above, to avoid taking an unnecessary dep on `buildPackages.qemu_kvm`
    qemuCommandLinux = ''
      ${vmTools.qemu-common.qemuBinary qemu} \
        -nographic -no-reboot \
        -device virtio-rng-pci \
        -virtfs local,path=${builtins.storeDir},security_model=none,mount_tag=store \
        -virtfs local,path=$TMPDIR/xchg,security_model=none,mount_tag=xchg \
        ''${diskImage:+-drive file=$diskImage,if=virtio,cache=unsafe,werror=report} \
        -kernel ${final.linux}/${final.stdenv.hostPlatform.linux-kernel.target} \
        -initrd ${vmTools.initrd}/initrd \
        -append "console=${vmTools.qemu-common.qemuSerialDevice} panic=1 command=${vmTools.stage2Init} out=$out mountDisk=$mountDisk loglevel=4" \
        $QEMU_OPTS
    '';
    vmRunCommand = final.buildPackages.vmTools.vmRunCommand qemuCommandLinux;
  in
    # without binfmt emulation, leverage the `vmTools.runInLinuxVM` infrastructure:
    # final.buildPackages.vmTools.runInLinuxVM pkg
    #
    # except `runInLinuxVM` doesn't quite work OOTB (see above),
    # so hack its components into something which *does* work.
    lib.overrideDerivation pkg ({ builder, args, ... }: {
      builder = "${final.buildPackages.bash}/bin/sh";
      args = [ "-e" vmRunCommand ];
      # orig{Builder,Args} gets used by the vmRunCommand script:
      origBuilder = builder;
      origArgs = args;

      QEMU_OPTS = "-m 16384";  # MiB of RAM
      enableParallelBuilding = true;

      # finally, let nix know that this package should be built by the build system
      system = final.stdenv.buildPlatform.system;
    }) // {
      override = attrs: emulateBuilderQemu (pkg.override attrs);
      overrideAttrs = mergeFn: emulateBuilderQemu (pkg.overrideAttrs mergeFn);
    }
  ;

  # given a package that's defined for build == host,
  # build it from a "proot": a chroot-like environment where `exec` is hooked to invoke qemu instead.
  # this is like binfmt, but configured to run *only* the emulated host and not the build machine
  # see: <https://proot-me.github.io/>
  # hinted at by: <https://www.tweag.io/blog/2022-03-31-running-wasm-native-hybrid-code/>
  #
  # this doesn't quite work:
  # - proot'd aarch64 shell will launch child processes in qemu
  # - but those children won't launch their children in qemu
  # need to somehow recursively proot...
  # emulateBuilderProot = pkg:
  #   lib.overrideDerivation pkg ({ builder, args, ... }: {
  #     builder = "${final.buildPackages.bash}/bin/sh";
  #     args = [ "-e" prootBuilder ];
  #     origBuilder = builder;
  #     origArgs = args;

  #     enableParallelBuilding = true;  # TODO: inherit from `pkg`?
  #     NIX_DEBUG = "6";

  #     # finally, let nix know that this package should be built by the build system
  #     system = final.stdenv.buildPlatform.system;
  #   }) // {
  #     override = attrs: emulateBuilderProot (pkg.override attrs);
  #     overrideAttrs = mergeFn: emulateBuilderProot (pkg.overrideAttrs mergeFn);
  #   };

  # prootBuilder = let
  #   proot = "${final.buildPackages.proot}/bin/proot";
  #   # prootFlags = "-r / -b /:/";
  #   prootFlags = "-b /nix:/nix -b /tmp:/tmp";
  #   # prootFlags = "-b /:/ -b ${final.bash}/bin/sh:/bin/sh";  # --mixed-mode false
  #   qemu = "${final.buildPackages.qemu}/bin/qemu-aarch64";
  # in
  #   final.pkgs.writeText "proot-run" ''
  #     echo "proot: ${proot} -q ${qemu} ${prootFlags} $origBuilder $origArgs"
  #     ${proot} -q ${qemu} ${prootFlags} $origBuilder $origArgs
  #     echo "exited proot"
  #   '';

  # given a package defined for build != host, transform it to build on the host.
  # i.e. build using the host's stdenv.
  buildOnHost =
    let
      # patch packages which don't expect to be moved to a different platform
      preFixPkg = p:
        if p.name or null == "make-shell-wrapper-hook" then
          p.overrideAttrs (_: {
            # unconditionally use the outermost targetPackages shell
            shell = final.runtimeShell;
          })
          # final.makeBinaryWrapper
        else if p.pname or null == "pkg-config-wrapper" then
          p.override {
            # default pkg-config.__spliced.hostTarget still wants to run on the build machine.
            # overriding buildPackages fixes that, and overriding stdenvNoCC makes it be just `pkg-config`, unmangled.
            stdenvNoCC = emulated.stdenvNoCC;
            buildPackages = final.hostPackages;  # TODO: just `final`?
          }
        # else if p.pname == final.python3.pname then
        #   p // {
        #     pythonForBuild = p;
        #   }
        # else if p.pname == "wrap-gapps-hook" then
        #   # avoid faulty propagated gtk3/gtk4
        #   final.wrapGAppsNoGuiHook
        else
          p
        ;
      unsplicePkg = p: p.__spliced.hostTarget or p;
      unsplicePkgs = ps: map (p: unsplicePkg (preFixPkg p)) ps;
    in
      pkg: (pkg.override {
        inherit (emulated) stdenv;
      }).overrideAttrs (upstream: {
        # for this purpose, the naming in `depsAB` is "inputs build for A, used to create packages in B" (i think).
        # when cross compiling x86_64 -> aarch64, most packages are
        # - build: x86_64
        # - target: aarch64
        # - host: aarch64
        # so, we only need to replace the build packages with alternates.
        depsBuildBuild = unsplicePkgs (upstream.depsBuildBuild or []);
        nativeBuildInputs = unsplicePkgs (upstream.nativeBuildInputs or []);
        depsBuildTarget = unsplicePkgs (upstream.depsBuildTarget or []);

        depsBuildBuildPropagated = unsplicePkgs (upstream.depsBuildBuildPropagated or []);
        propagatedNativeBuildInputs = unsplicePkgs (upstream.propagatedNativeBuildInputs or []);
        depsBuildTargetPropagated = unsplicePkgs (upstream.depsBuildTargetPropagated or []);

        nativeCheckInputs = unsplicePkgs (upstream.nativeCheckInputs or []);
        nativeInstallCheckInputs = unsplicePkgs (upstream.nativeInstallCheckInputs or []);
      });

  buildInQemu = pkg: emulateBuilderQemu (buildOnHost pkg);
  # buildInProot = pkg: emulateBuilderProot (buildOnHost pkg);
in {
  inherit emulated;

  # pkgsi686Linux = prev.pkgsi686Linux.extend (i686Self: i686Super: {
  #   # fixes eval-time error: "Unsupported cross architecture"
  #   #   it happens even on a x86_64 -> x86_64 build:
  #   #   - defining `config.nixpkgs.buildPlatform` to the non-default causes that setting to be inherited by pkgsi686.
  #   #   - hence, `pkgsi686` on a non-cross build is ordinarily *emulated*:
  #   #     defining a cross build causes it to also be cross (but to the right hostPlatform)
  #   # this has no inputs other than stdenv, and fetchurl, so emulating it is fine.
  #   tbb = prev.emulated.pkgsi686Linux.tbb;
  #   # tbb = i686Super.tbb.overrideAttrs (orig: (with i686Self; {
  #   #   makeFlags = lib.optionals stdenv.cc.isClang [
  #   #     "compiler=clang"
  #   #   ] ++ (lib.optional (stdenv.buildPlatform != stdenv.hostPlatform)
  #   #     (if stdenv.hostPlatform.isAarch64 then "arch=arm64"
  #   #     else if stdenv.hostPlatform.isx86_64 then "arch=intel64"
  #   #     else throw "Unsupported cross architecture: ${stdenv.buildPlatform.system} -> ${stdenv.hostPlatform.system}"));
  #   # }));
  # });

  # packages which don't cross compile
  inherit (emulated)
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

  # apacheHttpdPackagesFor = apacheHttpd: self:
  #   let
  #     prevHttpdPkgs = prev.apacheHttpdPackagesFor apacheHttpd self;
  #   in prevHttpdPkgs // {
  #     # fixes "configure: error: *** Sorry, could not find apxs ***"
  #     # mod_dnssd = prevHttpdPkgs.mod_dnssd.override {
  #     #   inherit (emulated) stdenv;
  #     # };
  #     # N.B.: the below apxs doesn't have a valid shebang (#!/replace/with/...).
  #     #   we can't replace it at the origin?
  #     mod_dnssd = prevHttpdPkgs.mod_dnssd.overrideAttrs (upstream: {
  #       configureFlags = upstream.configureFlags ++ [
  #         "--with-apxs=${self.apacheHttpd.dev}/bin"
  #       ];
  #     });
  #   };

  # binutils = prev.binutils.override {
  #   # fix that resulting binary files would specify build #!sh as their interpreter.
  #   # dtrx is the primary beneficiary of this.
  #   # this doesn't actually cause mass rebuilding.
  #   # note that this isn't enough to remove all build references:
  #   # - expand-response-params still references build stuff.
  #   shell = final.runtimeShell;
  # };

  # 2023/08/03: upstreaming is unblocked,implemented on servo, but has x86 in the runtime closure
  # blueman = prev.blueman.overrideAttrs (orig: {
  #   # configure: error: ifconfig or ip not found, install net-tools or iproute2
  #   nativeBuildInputs = orig.nativeBuildInputs ++ [ final.iproute2 ];
  # });
  # bonsai = emulateBuildMachine (prev.bonsai.override {
  #   hare = emulateBuildMachine (final.hare.override {
  #     qbe = emulateBuildMachine final.qbe;
  #     harePackages.harec = emulateBuildMachine (final.harePackages.harec.override {
  #       qbe = emulateBuildMachine final.qbe;
  #     });
  #   });
  # });
  # bonsai = prev.bonsai.override {
  #   inherit (emulated) stdenv hare;
  # };

  # brltty = prev.brltty.override {
  #   # configure: error: no acceptable C compiler found in $PATH
  #   inherit (emulated) stdenv;
  # };

  # 2023/10/23: upstreaming blocked by gvfs, webkitgtk 4.1 (OOMs)
  # fixes: "error: Package <foo> not found in specified Vala API directories or GObject-Introspection GIR directories"
  calls = addNativeInputs [ final.gobject-introspection] prev.calls;

  # cantarell-fonts = prev.cantarell-fonts.override {
  #   # close this after upstreaming: <https://github.com/NixOS/nixpkgs/issues/50855>
  #   # fixes error where python3.10-skia-pathops dependency isn't available for the build platform
  #   inherit (emulated) stdenv;
  # };
  # fixes "FileNotFoundError: [Errno 2] No such file or directory: 'gtk4-update-icon-cache'"
  # 2023/07/27: upstreaming is blocked on p11-kit cross compilation
  # celluloid = wrapGAppsHook4Fix prev.celluloid;
  # cdrtools = prev.cdrtools.override {
  #   # "configure: error: installation or configuration problem: C compiler cc not found."
  #   inherit (emulated) stdenv;
  # };
  # cdrtools = prev.cdrtools.overrideAttrs (upstream: {
  #   # can't get it to actually use our CC, even when specifying these explicitly
  #   # CC = "${final.stdenv.cc}/bin/${final.stdenv.cc.targetPrefix}cc";
  #   makeFlags = upstream.makeFlags ++ [
  #     "CC=${final.stdenv.cc}/bin/${final.stdenv.cc.targetPrefix}cc"
  #   ];
  # });

  # 2023/07/31: upstreaming is unblocked, implemented on servo
  # clapper = prev.clapper.overrideAttrs (upstream: {
  #   # use the host gjs (meson's find_program expects it to be executable)
  #   postPatch = (upstream.postPatch or "") + ''
  #     substituteInPlace bin/meson.build \
  #       --replace "find_program('gjs').path()" "'${final.gjs}/bin/gjs'"
  #   '';
  # });

  # conky = ((useEmulatedStdenv prev.conky).override {
  #   # docbook2x dependency doesn't cross compile
  #   docsSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [ final.git ];
  # });
  # conky = (prev.conky.override {
  #   # docbook2x dependency doesn't cross compile
  #   docsSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     # "Unable to find program 'git'"
  #     final.git
  #     # "bash: line 1: toluapp: command not found"
  #     final.toluapp
  #   ];
  # });

  # cozy = prev.cozy.override {
  #   cozy = prev.cozy.upstream.cozy.override {
  #     # fixes runtime error: "Settings schema 'org.gtk.Settings.FileChooser' is not installed"
  #     # otherwise gtk3+ schemas aren't added to XDG_DATA_DIRS
  #     inherit (emulated) wrapGAppsHook;
  #   };
  # };

  # dante = prev.dante.override {
  #   # fixes: "configure: error: error: getaddrinfo() error value count too low"
  #   inherit (emulated) stdenv;
  # };

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


  dialect = prev.dialect.overrideAttrs (upstream: {
    # dialect's meson build script sets host binaries to use build PYTHON
    # disallowedReferences = [];
    postFixup = (upstream.postFixup or "") + ''
      patchShebangs --update --host $out/share/dialect/search_provider
    '';
  });

  dtrx = prev.dtrx.override {
    # `binutils` is the nix wrapper, which reads nix-related env vars
    # before passing on to e.g. `ld`.
    # dtrx probably only needs `ar` at runtime, not even `ld`.
    binutils = final.binutils-unwrapped;
  };

  # emacs = prev.emacs.override {
  #   # fixes "configure: error: cannot run test program while cross compiling"
  #   inherit (emulated) stdenv;
  # };
  # emacs = prev.emacs.override {
  #   nativeComp = false;  # will be renamed to `withNativeCompilation` in future
  #   # future: we can specify 'action-if-cross-compiling' to actually invoke the test programs:
  #   # <https://www.gnu.org/software/autoconf/manual/autoconf-2.63/html_node/Runtime.html>
  # };

  firefox-extensions = prev.firefox-extensions.overrideScope' (self: super: {
    unwrapped = super.unwrapped // {
      browserpass-extension = super.unwrapped.browserpass-extension.override {
        # this overlay is optional for binfmt machines, but non-binfmt can't cross-compile the modules (for use at runtime)
        mkYarnModules = args: buildInQemu {
          override = { stdenv }: (
            (final.yarn2nix-moretea.override {
              pkgs = final.pkgs.__splicedPackages // { inherit stdenv; };
            }).mkYarnModules args
          ).overrideAttrs (upstream: {
            # i guess the VM creates the output directory for the derivation? not sure.
            # and `mv` across the VM boundary breaks, too?
            # original errors:
            # - "mv: cannot create directory <$out>: File exists"
            # - "mv: failed to preserve ownership for"
            buildPhase = lib.replaceStrings
              [
                "mkdir $out"
                "mv "
              ]
              [
                "mkdir $out || true ; chmod +w deps/browserpass-extension-modules/package.json"
                "cp -Rv "
              ]
              upstream.buildPhase
            ;
          });
        };
      };
    };
  });

  flare-signal = prev.flare-signal.override {
    # fixes "cargo:warning=aarch64-unknown-linux-gnu-gcc: error: unrecognized command-line option ‘-m64’"
    inherit (emulated) cargo meson rustc rustPlatform stdenv;
  };

  flare-signal-nixified = prev.flare-signal-nixified.override {
    # N.B. blueprint-compiler is in nativeBuildInputs.
    # the trick here is to force the aarch64 versions to be used during build (via emulation).
    # blueprint-compiler override shared with tangram.
    blueprint-compiler = buildInQemu (final.blueprint-compiler.overrideAttrs (_: {
      # default is to propagate gobject-introspection *as a buildInput*, when it's supposed to be native.
      propagatedBuildInputs = [];
      # "Namespace Gtk not available"
      doCheck = false;
    }));
  };

  # 2023/07/31: upstreaming is blocked on ostree dep
  flatpak = prev.flatpak.overrideAttrs (upstream: {
    # fixes "No package 'libxml-2.0' found"
    buildInputs = upstream.buildInputs ++ [ final.libxml2 ];
    configureFlags = upstream.configureFlags ++ [
      "--enable-selinux-module=no"  # fixes "checking for /usr/share/selinux/devel/Makefile... configure: error: cannot check for file existence when cross compiling"
      "--disable-gtk-doc"  # fixes "You must have gtk-doc >= 1.20 installed to build documentation for Flatpak"
    ];
  });

  # future: use `buildRustPackage`?
  # - find another rust package that uses a `-sys` crate (with a build script)?
  #   - `halloy` uses openssl-sys (1 patch version ahead of fractal), builds
  #   - uses `cargoBuildHook`, which sets the x86 CC
  # - copy from gst_all_1.gst-plugins-rs
  #   - that's the rust dep which fails to build; nixpkgs chatter makes it sound like cargo-c is the culprit
  # fractal-next = prev.fractal-next.override {
  #   # fixes "cargo:warning=aarch64-unknown-linux-gnu-gcc: error: unrecognized command-line option ‘-m64’"
  #   # seems to hang when compiling fractal
  #   inherit (emulated) cargo meson rustc rustPlatform stdenv;
  # };
  fractal-latest = prev.fractal-latest.override {
    # fixes "cargo:warning=aarch64-unknown-linux-gnu-gcc: error: unrecognized command-line option ‘-m64’"
    # seems to hang when compiling fractal
    fractal-next = final.fractal-next.override {
      inherit (emulated) cargo meson rustc rustPlatform stdenv;
    };
  };
  # fractal-next = prev.fractal-next.overrideAttrs (upstream: {
  #   env = let
  #     inherit (final) buildPackages stdenv rust;
  #     ccForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc";
  #     cxxForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}c++";
  #     ccForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";
  #     cxxForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++";
  #     rustBuildPlatform = rust.toRustTarget stdenv.buildPlatform;
  #     rustTargetPlatform = rust.toRustTarget stdenv.hostPlatform;
  #     rustTargetPlatformSpec = rust.toRustTargetSpec stdenv.hostPlatform;
  #   in {
  #     # taken from <pkgs/build-support/rust/hooks/default.nix>
  #     # fixes "cargo:warning=aarch64-unknown-linux-gnu-gcc: error: unrecognized command-line option ‘-m64’"
  #     "CC_${rustBuildPlatform}" = "${ccForBuild}";
  #     "CXX_${rustBuildPlatform}" = "${cxxForBuild}";
  #     "CC_${rustTargetPlatform}" = "${ccForHost}";
  #     "CXX_${rustTargetPlatform}" = "${cxxForHost}";
  #   };
  #   mesonFlags = (upstream.mesonFlags or []) ++
  #     (let
  #       # ERROR: 'rust' compiler binary not defined in cross or native file
  #       crossFile = final.writeText "cross-file.conf" ''
  #       [binaries]
  #       rust = [ 'rustc', '--target', '${final.rust.toRustTargetSpec final.stdenv.hostPlatform}' ]
  #     '';
  #     in
  #       lib.optionals (final.stdenv.hostPlatform != final.stdenv.buildPlatform) [ "--cross-file=${crossFile}" ]
  #     );
  #   # 2023/09/15: fails with:
  #   # - error: linking with `/nix/store/75slks1wr3b3sxr5advswjzg9lvbv9jc-gcc-wrapper-12.3.0/bin/cc` failed: exit status: 1
  #   # - error: could not compile `gst-plugin-gtk4` (lib) due to previous error
  #   # seems it's trying to link something for the build platform instead of the host platform
  #   # fractal-next 5.beta2 is using gst-plugin-gtk4 0.11.
  #   # - gst-plugin-gtk4 tip is at 0.12.0-alpha1, but that's not published to Crates.io
  #   # - <https://lib.rs/crates/gst-plugin-gtk4>
  #   # - no obvious PRs that merged after 0.11 release relevant to cross compilation
  #   # patching gst-plugin-gtk4 to not build cdylib fixes the issue in the `fractal-nixified` variant of this package
  # });

  # 2023/07/31: upstreaming is unblocked -- if i can rework to not use emulation
  # fwupd-efi = prev.fwupd-efi.override {
  #   # fwupd-efi queries meson host_machine to decide what arch to build for.
  #   #   for some reason, this gives x86_64 unless meson itself is emulated.
  #   #   maybe meson's use of "host_machine" actually mirrors nix's "build machine"?
  #   inherit (emulated)
  #     stdenv  # fixes: "efi/meson.build:162:0: ERROR: Program or command 'gcc' not found or not executable"
  #     meson  # fixes: "efi/meson.build:33:2: ERROR: Problem encountered: gnu-efi support requested, but headers were not found"
  #   ;
  # };
  # fwupd-efi = prev.fwupd-efi.overrideAttrs (upstream: {
  #   # does not fix: "efi/meson.build:162:0: ERROR: Program or command 'gcc' not found or not executable"
  #   makeFlags = upstream.makeFlags or [] ++ [ "CC=${prev.stdenv.cc.targetPrefix}cc" ];
  #   # does not fix: "efi/meson.build:162:0: ERROR: Program or command 'gcc' not found or not executable"

  #   # nativeBuildInputs = upstream.nativeBuildInputs ++ lib.optionals (!prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform) [
  #   #   final.mesonEmulatorHook
  #   # ];
  # });
  # solves (meson) "Run-time dependency libgcab-1.0 found: NO (tried pkgconfig and cmake)", and others.
  # 2023/07/31: upstreaming is blocked on argyllcms, fwupd-efi, libavif
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

  # 2023/07/31: upstreaming is blocked on qttranslations (via pipewire)
  # N.B.: should be able to remove gnupg/ssh from {native}buildInputs when upstreaming
  gcr_4 = prev.gcr_4.overrideAttrs (upstream: {
    # fixes (meson): "ERROR: Program 'gpg2 gpg' not found or not executable"
    mesonFlags = (upstream.mesonFlags or []) ++ [
      "-Dgpg_path=${final.gnupg}/bin/gpg"
    ];
  });
  # 2023/10/23: upstreaming: <https://github.com/NixOS/nixpkgs/pull/263158>
  # gcr = prev.gcr.overrideAttrs (upstream: {
  #   # removes build platform's gnupg from runtime closure
  #   mesonFlags = (upstream.mesonFlags or []) ++ [
  #     "-Dgpg_path=${final.gnupg}/bin/gpg"
  #   ];
  # });
  # gnustep = prev.gnustep.overrideScope' (self: super: {
  #   # gnustep is going to need a *lot* of work/domain-specific knowledge to truly cross-compile,
  #   # base = emulated.gnustep.base;
  #   base = (super.base.override {
  #     # fixes: "configure: error: Your compiler does not appear to implement the -fconstant-string-class option needed for support of strings."
  #     # emulating gsmake amounts to emulating stdenv.
  #     inherit (emulated.gnustep) gsmakeDerivation;
  #   }).overrideAttrs (upstream: {
  #     # fixes: "checking FFI library usage... ./configure: line 11028: pkg-config: command not found"
  #     # nixpkgs has this in nativeBuildInputs... but that's failing when we partially emulate things.
  #     buildInputs = (upstream.buildInputs or []) ++ [ prev.pkg-config ];
  #   });
  # });
  # 2023/07/27: upstreaming is blocked on p11-kit, libavif cross compilation
  gthumb = mvInputs { nativeBuildInputs = [ final.glib ]; } prev.gthumb;

  gnome = prev.gnome.overrideScope' (self: super: {
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
    # dconf-editor = addNativeInputs [ final.dconf ] super.dconf-editor;
    evince = super.evince.overrideAttrs (orig: {
      # 2023/07/31: upstreaming is blocked on libavif
      # fixes (meson) "Run-time dependency gi-docgen found: NO (tried pkgconfig and cmake)"
      # inspired by gupnp
      outputs = [ "out" "dev" ]
        ++ lib.optionals (prev.stdenv.buildPlatform == prev.stdenv.hostPlatform) [ "devdoc" ];
      mesonFlags = orig.mesonFlags ++ [
        "-Dgtk_doc=${lib.boolToString (prev.stdenv.buildPlatform == prev.stdenv.hostPlatform)}"
      ];
    });
    evolution-data-server = super.evolution-data-server.overrideAttrs (upstream: {
      # 2023/08/01: upstreaming is blocked on libavif
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

    # 2023/08/01: upstreaming is blocked on nautilus, gnome-user-share (apache-httpd, webp-pixbuf-loader)
    # fixes: "src/meson.build:106:0: ERROR: Program 'glib-compile-resources' not found or not executable"
    file-roller = mvToNativeInputs [ final.glib ] super.file-roller;

    geary = super.geary.overrideAttrs (upstream: {
      buildInputs = upstream.buildInputs ++ [
        # final.glib
        final.appstream-glib
        final.libxml2
      ];
    });

    # 2023/08/01: upstreaming is unblocked
    # fixes: "meson.build:75:6: ERROR: Program 'gtk-update-icon-cache' not found or not executable"
    gnome-clocks = wrapGAppsHook4Fix super.gnome-clocks;

    # 2023/07/31: upstreaming is blocked on argyllcms, libavif
    # fixes: "src/meson.build:3:0: ERROR: Program 'glib-compile-resources' not found or not executable"
    # gnome-color-manager = mvToNativeInputs [ final.glib ] super.gnome-color-manager;
    # 2023/08/01: upstreaming is blocked by apache-httpd, argyllcms, ibus, libavif, webp-pixbuf-loader
    # fixes "subprojects/gvc/meson.build:30:0: ERROR: Program 'glib-mkenums mkenums' not found or not executable"
    # gnome-control-center = mvToNativeInputs [ final.glib ] super.gnome-control-center;
    gnome-keyring = super.gnome-keyring.overrideAttrs (orig: {
      # 2023/07/31: upstreaming is unblocked, but requires a different fix
      # fixes "configure.ac:374: error: possibly undefined macro: AM_PATH_LIBGCRYPT"
      nativeBuildInputs = orig.nativeBuildInputs ++ [ final.libgcrypt final.openssh final.glib ];
    });
    gnome-maps = super.gnome-maps.overrideAttrs (upstream: {
      postPatch = (upstream.postPatch or "") + ''
        # fixes: "ERROR: Program 'gjs' not found or not executable"
        substituteInPlace meson.build \
          --replace "find_program('gjs')" "find_program('${final.gjs}/bin/gjs')"
        # fixes missing `gapplication` binary when not on PATH (needed for non-cross build too)
        substituteInPlace data/org.gnome.Maps.desktop.in.in \
          --replace "gapplication" "${final.glib.bin}/bin/gapplication"
      '';
    });
    # fixes: "Program gdbus-codegen found: NO"
    # gnome-remote-desktop = mvToNativeInputs [ final.glib ] super.gnome-remote-desktop;
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
      # 2023/08/01: upstreaming is blocked on argyllcms, gnome-keyring, gnome-clocks, ibus, libavif, webp-pixbuf-loader
      nativeBuildInputs = upstream.nativeBuildInputs ++ [
        final.gjs  # fixes "meson.build:128:0: ERROR: Program 'gjs' not found or not executable"
      ];
    });
    gnome-settings-daemon = super.gnome-settings-daemon.overrideAttrs (orig: {
      # 2023/07/31: upstreaming is blocked on argyllcms, libavif
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
    # 2023/08/01: upstreaming is blocked on argyllcms, gnome-keyring, gnome-clocks, ibus, libavif, webp-pixbuf-loader (gnome-shell)
    # fixes: "gdbus-codegen not found or executable"
    # gnome-session = mvToNativeInputs [ final.glib ] super.gnome-session;
    # gnome-terminal = super.gnome-terminal.overrideAttrs (orig: {
    #   # 2023/07/31: upstreaming is blocked on argyllcms, apache-httpd, gnome-keyring, libavif, gnome-clocks, ibus, webp-pixbuf-loader
    #   # fixes "meson.build:343:0: ERROR: Dependency "libpcre2-8" not found, tried pkgconfig"
    #   buildInputs = orig.buildInputs ++ [ final.pcre2 ];
    # });
    # 2023/07/31: upstreaming is blocked on apache-httpd
    # fixes: meson.build:111:6: ERROR: Program 'glib-compile-schemas' not found or not executable
    # gnome-user-share = addNativeInputs [ final.glib ] super.gnome-user-share;
    mutter = (super.mutter.overrideAttrs (orig: {
      # 2023/07/31: upstreaming is blocked on argyllcms, libavif
      # N.B.: not all of this suitable to upstreaming, as-is.
      # mesa and xorgserver are removed here because they *themselves* don't build for `buildPackages` (temporarily: 2023/10/26)
      nativeBuildInputs = lib.subtractLists [ final.mesa final.xorg.xorgserver ] orig.nativeBuildInputs;
      buildInputs = orig.buildInputs ++ [
        final.mesa  # fixes "meson.build:237:2: ERROR: Dependency "gbm" not found, tried pkgconfig"
      ];
      # Run-time dependency gi-docgen found: NO (tried pkgconfig and cmake)
      mesonFlags = lib.remove "-Ddocs=true" orig.mesonFlags;
      outputs = lib.remove "devdoc" orig.outputs;
    }));
    nautilus = (
      # 2023/07/31: upstreaming is blocked on apache-httpd, webp-pixbuf-loader
      addInputs {
        # fixes: "meson.build:123:0: ERROR: Dependency "libxml-2.0" not found, tried pkgconfig"
        buildInputs = [ final.libxml2 ];
        # fixes: "meson.build:226:6: ERROR: Program 'gtk-update-icon-cache' not found or not executable"
        nativeBuildInputs = [ final.gtk4 ];
      }
      # fixes -msse2, -mfpmath=sse flags
      (wrapGAppsHook4Fix super.nautilus)
    );
  });

  # gnome2 = prev.gnome2.overrideScope' (self: super: {
  #   # inherit (emulated.gnome2)
  #   #   GConf
  #   # ;
  #   # GConf = (
  #   #   # python3 -> nativeBuildInputs fixes "2to3: command not found"
  #   #   # glib.dev in nativeBuildInputs fixes "gconfmarshal.list: command not found"
  #   #   # new error: "** (orbit-idl-2): WARNING **: ./GConfX.idl compilation failed"
  #   #   addNativeInputs
  #   #     [ final.glib.dev ]
  #   #     (mvToNativeInputs [ final.python3 ] super.GConf);
  #   # );
  #   # avoid gconf. last release was 2013: it's dead.
  #   GConf = super.GConf.override {
  #     inherit (emulated) stdenv;
  #   };

  #   # gnome_vfs = (
  #   #   # fixes: "configure: error: gconftool-2 executable not found in your path - should be installed with GConf"
  #   #   # new error: "configure: error: cannot run test program while cross compiling"
  #   #   mvToNativeInputs [ self.GConf ] super.gnome_vfs
  #   # );
  #   gnome_vfs = useEmulatedStdenv super.gnome_vfs;
  #   libIDL  = super.libIDL.override {
  #     # "configure: error: cannot run test program while cross compiling"
  #     inherit (emulated) stdenv;
  #   };
  #   ORBit2 = super.ORBit2.override {
  #     # "configure: error: Failed to find alignment. Check config.log for details."
  #     inherit (emulated) stdenv;
  #   };
  # });

  # 2023/07/27: upstreaming is blocked on xdg-utils cross compilation
  # - fails in different way than here: tries to run host python during build
  gpodder = prev.gpodder.overridePythonAttrs (upstream: {
    # fix gobject-introspection overrides import that otherwise fails on launch
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      final.buildPackages.gobject-introspection
    ];
    buildInputs = lib.remove final.gobject-introspection upstream.buildInputs;
    strictDeps = true;
  });

  # 2023/10/23: out for review: <https://github.com/NixOS/nixpkgs/pull/263107>
  # gsound = prev.gsound.overrideAttrs (upstream: {
  #   # remove logic which was removing introspection/vala on cross compilation
  #   mesonFlags = [];
  # });
  # 2023/10/23: out for review: <https://github.com/NixOS/nixpkgs/pull/263135>
  # gspell = prev.gspell.overrideAttrs (upstream: {
  #   depsBuildBuild = (upstream.depsBuildBuild or []) ++ [
  #     # without this, vapi files ($dev/share/vapi/vala/gspell-1.vapi) aren't generated.
  #     # that breaks consumers like `gnome.geary`
  #     final.pkg-config
  #   ];
  #   configureFlags = upstream.configureFlags ++ [
  #     # not necessary, but enforces that we really do produce vapi files
  #     "--enable-vala"
  #   ];
  # });

  # 2023/10/23: out for review: <https://github.com/NixOS/nixpkgs/pull/263175>
  # gvfs = prev.gvfs.overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     # XXX: this ends up on the runtime closure
  #     final.openssh
  #     final.glib  # fixes "gdbus-codegen: command not found"
  #   ];
  #   # fixes "meson.build:312:2: ERROR: Assert failed: http required but libxml-2.0 not found"
  #   buildInputs = upstream.buildInputs ++ [ final.libxml2 ];
  # });

  # hdf5 = prev.hdf5.override {
  #   inherit (emulated) stdenv;
  # };

  # out for PR: <https://github.com/NixOS/nixpkgs/pull/263182>
  # hspell = prev.hspell.overrideAttrs (upstream: {
  #   # build perl is needed by the Makefile,
  #   # but $out/bin/multispell (which is simply copied from src) should use host perl
  #   buildInputs = (upstream.buildInputs or []) ++ [ final.perl ];
  #   postInstall = ''
  #     patchShebangs --update $out/bin/multispell
  #   '';
  # });

  # "setup: line 1595: ant: command not found"
  # i2p = mvToNativeInputs [ final.ant final.gettext ] prev.i2p;

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
  # ibus = buildInQemu (prev.ibus.override {
  #   # not enough: still tries to execute build machine perl
  #   buildPackages.gtk-doc = final.gtk-doc;
  # });

  # 2023/10/23: upstreaming blocked on argyllcms
  graphicsmagick = prev.graphicsmagick.overrideAttrs (upstream: {
    # by default the build holds onto a reference to build `mv`
    # N.B.: `imagemagick` package has this identical issue
    configureFlags = upstream.configureFlags ++ [
      "MVDelegate=${final.coreutils}/bin/mv"
    ];
  });

  # fixes: "make: gcc: No such file or directory"
  # java-service-wrapper = useEmulatedStdenv prev.java-service-wrapper;

  # javaPackages = prev.javaPackages // {
  #   compiler = prev.javaPackages.compiler // {
  #     adoptopenjdk-8 = prev.javaPackages.compiler.adoptopenjdk-8 // {
  #       # fixes "error: auto-patchelf could not satisfy dependency libgcc_s.so.1 wanted by /nix/store/fvln9pahd3c4ys8xv5c0w91xm2347cvq-adoptopenjdk-hotspot-bin-aarch64-unknown-linux-gnu-8.0.322/jre/lib/aarch64/libsunec.so"
  #       jdk-hotspot  = useEmulatedStdenv prev.javaPackages.compiler.adoptopenjdk-8.jdk-hotspot;
  #     };
  #     openjdk8-bootstrap = useEmulatedStdenv prev.javaPackages.compiler.openjdk8-bootstrap;
  #     # fixes "configure: error: Could not find required tool for WHICH"
  #     openjdk8 = useEmulatedStdenv prev.javaPackages.compiler.openjdk8;
  #     # openjdk19 = (
  #     #   # fixes "configure: error: Could not find required tool for ZIPEXE"
  #     #   # new failure: "checking for cc... [not found]"
  #     #   (mvToNativeInputs
  #     #     [ final.zip ]
  #     #     (useEmulatedStdenv prev.javaPackages.compiler.openjdk19)
  #     #   ).overrideAttrs (_upstream: {
  #     #     # avoid building `support/demos`, which segfaults
  #     #     buildFlags = [ "product-images" ];
  #     #     doCheck = false;  # pre-emptive
  #     #   })
  #     # );
  #     openjdk19 = emulated.javaPackages.compiler.openjdk19;
  #   };
  # };

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

  komikku = wrapGAppsHook4Fix prev.komikku;
  koreader = (prev.koreader.override {
    # fixes runtime error: luajit: ./ffi/util.lua:757: attempt to call field 'pack' (a nil value)
    # inherit (emulated) luajit;
    luajit = buildInQemu (final.luajit.override {
      buildPackages.stdenv = emulated.stdenv;  # it uses buildPackages.stdenv for HOST_CC
    });
  }).overrideAttrs (upstream: {
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      final.autoPatchelfHook
    ];
  });
  # koreader-from-src = prev.koreader-from-src.override {
  #   # fixes runtime error: luajit: ./ffi/util.lua:757: attempt to call field 'pack' (a nil value)
  #   # inherit (emulated) luajit;
  #   luajit = buildInQemu (final.luajit.override {
  #     buildPackages.stdenv = emulated.stdenv;  # it uses buildPackages.stdenv for HOST_CC
  #   });
  # };
  # libgweather = rmNativeInputs [ final.glib ] (prev.libgweather.override {
  #   # alternative to emulating python3 is to specify it in `buildInputs` instead of `nativeBuildInputs` (upstream),
  #   #   but presumably that's just a different way to emulate it.
  #   # the python gobject-introspection stuff is a tangled mess that's impossible to debug:
  #   # don't dig further, leave this for some other dedicated soul.
  #   inherit (emulated)
  #     stdenv  # fixes "Run-time dependency vapigen found: NO (tried pkgconfig)"
  #     gobject-introspection  # fixes gir x86-64 python -> aarch64 shared object import
  #     python3  # fixes build-aux/meson/gen_locations_variant.py x86-64 python -> aarch64 import of glib
  #   ;
  # });
  # libgweather = prev.libgweather.overrideAttrs (upstream: {
  #   nativeBuildInputs = (lib.remove final.gobject-introspection upstream.nativeBuildInputs) ++ [
  #     final.buildPackages.gobject-introspection  # fails to fix "gi._error.GError: g-invoke-error-quark: Could not locate g_option_error_quark: /nix/store/dsx6kqmyg7f3dz9hwhz7m3jrac4vn3pc-glib-aarch64-unknown-linux-gnu-2.74.3/lib/libglib-2.0.so.0"
  #   ];
  #   # fixes "Run-time dependency vapigen found: NO (tried pkgconfig)"
  #   buildInputs = upstream.buildInputs ++ [ final.vala ];
  # });

  # 2023/08/27: out for PR: <https://github.com/NixOS/nixpkgs/pull/251956>
  # libgweather = (prev.libgweather.override {
  #   # we need introspection for bindings, used by e.g.
  #   # - gnome.gnome-weather (javascript)
  #   # - sane-weather (python)
  #   #
  #   # enabling introspection on cross is tricky because `gen_locations_variant.py`
  #   # outputs binary files (Locations.bin) which use the endianness of the build machine
  #   # OTOH, aarch64 and x86_64 have same endianness: why not just ignore the issue, then?
  #   # upstream issue (loosely related): <https://gitlab.gnome.org/GNOME/libgweather/-/issues/154>
  #   withIntrospection = true;
  # }).overrideAttrs (upstream: {
  #   # TODO: the `is_cross_build` change to meson.build is in nixpkgs, but specifies the wrong filepath
  #   #   (libgweather/meson.build instead of meson.build)
  #   postPatch = (upstream.postPatch or "") + ''
  #     sed -i '2i import os; os.environ["GI_TYPELIB_PATH"] = ""' build-aux/meson/gen_locations_variant.py
  #     substituteInPlace meson.build \
  #       --replace "g_ir_scanner.found() and not meson.is_cross_build()" "g_ir_scanner.found()"
  #     substituteInPlace libgweather/meson.build \
  #       --replace "dependency('vapigen'," "dependency('vapigen', native:true,"
  #   '';
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

  libshumate = prev.libshumate.overrideAttrs (upstream: {
    # fixes "Build-time dependency gi-docgen found: NO (tried pkgconfig and cmake)"
    mesonFlags = (upstream.mesonFlags or []) ++ [ "-Dgtk_doc=false" ];
    # alternative partial fix, but then it tries to link against the build glib
    # depsBuildBuild = (upstream.depsBuildBuild or []) ++ [ final.pkg-config ];
  });

  mepo = (prev.mepo.override {
    # nixpkgs mepo correctly puts `zig_0_11.hook` in nativeBuildInputs,
    # but for some reason that tries to use the host zig instead of the build zig.
    zig_0_11 = final.buildPackages.zig_0_11;
  }).overrideAttrs (upstream: {
    dontUseZigCheck = true;
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      # zig hardcodes the /lib/ld-linux.so interpreter which breaks nix dynamic linking & dep tracking.
      # this shouldn't have to be buildPackages.autoPatchelfHook...
      # but without specifying `buildPackages` the host coreutils ends up on the builder's path and breaks things
      final.buildPackages.autoPatchelfHook
      # zig hard-codes `pkg-config` inside lib/std/build.zig
      (final.buildPackages.writeShellScriptBin "pkg-config" ''
        exec $PKG_CONFIG $@
      '')
    ];
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace src/sdlshim.zig \
        --replace 'cInclude("SDL2/SDL2_gfxPrimitives.h")' 'cInclude("SDL2_gfxPrimitives.h")' \
        --replace 'cInclude("SDL2/SDL_image.h")' 'cInclude("SDL_image.h")' \
        --replace 'cInclude("SDL2/SDL_ttf.h")' 'cInclude("SDL_ttf.h")'
      substituteInPlace build.zig \
        --replace 'step.linkSystemLibrary("curl")' 'step.linkSystemLibrary("libcurl")' \
        --replace 'exe.install();' 'exe.install(); if (true) { return; } // skip tests when cross compiling'
    '';
    # skip the mepo -docman self-documenting invocation
    postInstall = ''
      install -d $out/share/man/man1
    '';
    # optional `zig build` debugging flags:
    # - --verbose
    # - --verbose-cimport
    # - --help
    zigBuildFlags = [ "-Dtarget=aarch64-linux-gnu" ];
  });

  # mepo = emulateBuildMachine (prev.mepo.override {
  #   zig = (final.buildPackages.zig.overrideAttrs (upstream: {
  #     cmakeFlags = (upstream.cmakeFlags or []) ++ [
  #       "-DZIG_EXECUTABLE=${final.buildPackages.zig}/bin/zig"
  #       "-DZIG_TARGET_TRIPLE=aarch64-linux-gnu"
  #       # "-DZIG_MCPU=${final.targetPlatform.gcc.cpu}"
  #     ];
  #     # makeFlags = (upstream.makeFlags or []) ++ [
  #     #   # stop at the second stage.
  #     #   # the third stage would be a self-hosted compiler (i.e. build the compiler using what you just built),
  #     #   # but that only works on native builds
  #     #   "zig2"
  #     # ];
  #   }));
  # });
  # mepo = prev.mepo.overrideAttrs (upstream: {
  #   installPhase = lib.replaceStrings [ "zig " ] [ "zig -Dtarget=aarch64-linux "] upstream.installPhase;
  #   doCheck = false;
  # });

  # mepo =
  #   # let
  #   #   zig = final.zig.override {
  #   #     inherit (emulated) stdenv;
  #   #   };
  #   #   # makeWrapper = final.makeWrapper.override {
  #   #   #   inherit (emulated) stdenv;
  #   #   # };
  #   #   # makeWrapper = emulated.stdenv.mkDerivation final.makeWrapper;
  #   # in
  #   # (prev.mepo.overrideAttrs (upstream: {
  #   #   checkPhase = lib.replaceStrings [ "zig" ] [ "${zig}/bin/zig" ] upstream.checkPhase;
  #   #   installPhase = lib.replaceStrings [ "zig" ] [ "${zig}/bin/zig" ] upstream.installPhase;
  #   # })).override {
  #   #   inherit (emulated) stdenv;
  #   #   inherit zig;
  #   # };
  # let
  #   mepoDefn = {
  #     stdenv
  #     , upstreamMepo
  #     , makeWrapper
  #     , pkg-config
  #     , zig
  #     # buildInputs
  #     , curl
  #     , SDL2
  #     , SDL2_gfx
  #     , SDL2_image
  #     , SDL2_ttf
  #     , jq
  #     , ncurses
  #   }: stdenv.mkDerivation {
  #     inherit (upstreamMepo)
  #       pname
  #       version
  #       src
  #       # buildInputs
  #       preBuild
  #       doCheck
  #       postInstall
  #       meta
  #     ;
  #     # moves pkg-config to buildInputs where zig can see it, and uses the host build of zig.
  #     nativeBuildInputs = [ makeWrapper ];
  #     buildInputs = [
  #       curl SDL2 SDL2_gfx SDL2_image SDL2_ttf jq ncurses pkg-config
  #     ];
  #     checkPhase = lib.replaceStrings [ "zig" ] [ "${zig}/bin/zig" ] upstreamMepo.checkPhase;
  #     installPhase = lib.replaceStrings [ "zig" ] [ "${zig}/bin/zig" ] upstreamMepo.installPhase;
  #   };
  # in
  #   emulateBuildMachine (final.callPackage mepoDefn {
  #     upstreamMepo = prev.mepo;
  #     zig = final.zig.overrideAttrs (upstream: {
  #       # TODO: for zig1 we can actually set ZIG_EXECUTABLE and use the build zig.
  #       # zig2 doesn't support that.
  #       postPatch = (upstream.postPatch or "") + ''
  #         substituteInPlace CMakeLists.txt \
  #           --replace "COMMAND zig1 " "COMMAND ${final.stdenv.hostPlatform.emulator final.buildPackages} $PWD/build/zig1 " \
  #           --replace "COMMAND zig2 " "COMMAND ${final.stdenv.hostPlatform.emulator final.buildPackages} $PWD/build/zig2 "
  #       '';
  #     });
  #     # zig = emulateBuildMachine (final.zig.overrideAttrs (upstream: {
  #     #   # speed up the emulated build by skipping docs and tests
  #     #   outputs = [ "out" ];
  #     #   postBuild = "";  # don't build docs
  #     #   doInstallCheck = false;
  #     #   doCheck = false;
  #     # }));
  #   });
  #   # (prev.mepo.override {
  #   #   # emulate zig and stdenv to fix:
  #   #   # - "/build/source/src/sdlshim.zig:1:20: error: C import failed"
  #   #   # emulate makeWrapper to fix:
  #   #   # - "error: makeWrapper/makeShellWrapper must be in nativeBuildInputs"
  #   #   # inherit (emulated) makeWrapper stdenv;
  #   #   inherit (emulated) stdenv;
  #   #   inherit zig;
  #   #   # inherit makeWrapper;
  #   # }).overrideAttrs (upstream: {
  #   #   # nativeBuildInputs = [ final.pkg-config makeWrapper ];
  #   #   # nativeBuildInputs = [ final.pkg-config emulated.makeWrapper ];
  #   #   # ref to zig by full path because otherwise it doesn't end up on the path...
  #   #   #checkPhase = lib.replaceStrings [ "zig" ] [ "${zig}/bin/zig" ] upstream.checkPhase;
  #   #   #installPhase = lib.replaceStrings [ "zig" ] [ "${zig}/bin/zig" ] upstream.installPhase;
  #   # });
  # mepo = (prev.mepo.override {
  #   # emulate zig and stdenv to fix:
  #   # - "/build/source/src/sdlshim.zig:1:20: error: C import failed"
  #   # emulate makeWrapper to fix:
  #   # - "error: makeWrapper/makeShellWrapper must be in nativeBuildInputs"
  #   inherit (emulated) makeWrapper stdenv zig;
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = [ final.pkg-config emulated.makeWrapper ];
  #   # ref to zig by full path because otherwise it doesn't end up on the path...
  #   checkPhase = lib.replaceStrings [ "zig" ] [ "${emulated.zig}/bin/zig" ] upstream.checkPhase;
  #   installPhase = lib.replaceStrings [ "zig" ] [ "${emulated.zig}/bin/zig" ] upstream.installPhase;
  # });
  # mepo = (prev.mepo.override {
  #   inherit (emulated) stdenv;
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = with final; [ pkg-config emulated.makeWrapper ];
  #   buildInputs = with final; [
  #     curl SDL2 SDL2_gfx SDL2_image SDL2_ttf jq ncurses
  #     emulated.zig
  #   ];
  # });
  # mepo = mvToBuildInputs [ emulated.zig ] (prev.mepo.override {
  #   inherit (emulated) makeWrapper stdenv zig;
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

  mpv-unwrapped = prev.mpv-unwrapped.overrideAttrs (upstream: {
    # 2023/10/10: upstreaming is easiest to do after the next staging -> master merge
    #   otherwise the result will still have a transient dep on python.
    #   - <https://github.com/NixOS/nixpkgs/pull/259109>
    # nativeBuildInputs = lib.remove final.python3 upstream.nativeBuildInputs;
    # umpv gets the build python, somehow -- even with python3 removed from nativeBuildInputs.
    # and mpv_identify.sh gets the build bash.
    # patch these both to use the host files
    buildInputs = (upstream.buildInputs or []) ++ [ final.bash final.python3 ];
    postFixup = (upstream.postFixup or "") + ''
      patchShebangs --update --host $out/bin/umpv $out/bin/mpv_identify.sh
    '';
  });

  # mpvScripts = prev.mpvScripts // {
  #   # "line 1: pkg-config: command not found"
  #   #   "mpris.c:1:10: fatal error: gio/gio.h: No such file or directory"
  #   # 2023/07/31: upstreaming unblocked, implemented on servo
  #   mpris = addNativeInputs [ final.pkg-config ] prev.mpvScripts.mpris;
  # };
  # fixes: "ar: command not found"
  # `ar` is provided by bintools
  # 2023/07/27: upstreaming is unblocked by deps; but turns out to not be this simple
  ncftp = addNativeInputs [ final.bintools ] prev.ncftp;
  # fixes "gdbus-codegen: command not found"
  # 2023/07/31: upstreaming is blocked on p11-kit, openfortivpn, qttranslations (qtbase) cross compilation
  networkmanager-fortisslvpn = mvToNativeInputs [ final.glib ] prev.networkmanager-fortisslvpn;
  # networkmanager-iodine = prev.networkmanager-iodine.overrideAttrs (orig: {
  #   # fails to fix "configure.ac:58: error: possibly undefined macro: AM_GLIB_GNU_GETTEXT"
  #   nativeBuildInputs = orig.nativeBuildInputs ++ [ final.gettext ];
  # });
  # networkmanager-iodine = prev.networkmanager-iodine.override {
  #   # fixes "configure.ac:58: error: possibly undefined macro: AM_GLIB_GNU_GETTEXT"
  #   inherit (emulated) stdenv;
  # };
  # networkmanager-iodine = addNativeInputs [ final.gettext ] prev.networkmanager-iodine;
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
  # 2023/07/31: upstreaming is unblocked,implemented
  # networkmanager-l2tp = addNativeInputs [ final.gtk4 ]
  #   (mvToNativeInputs [ final.glib ] prev.networkmanager-l2tp);
  # fixes "properties/gresource.xml: Permission denied"
  #   - by providing glib-compile-resources
  # 2023/07/31: upstreaming is blocked on libavif cross compilation
  # networkmanager-openconnect = mvToNativeInputs [ final.glib ] prev.networkmanager-openconnect;
  # fixes "properties/gresource.xml: Permission denied"
  #   - by providing glib-compile-resources
  # 2023/07/31: upstreaming is unblocked,implemented
  # networkmanager-openvpn = mvToNativeInputs [ final.glib ] prev.networkmanager-openvpn;
  # 2023/07/31: upstreaming is unblocked,implemented
  # networkmanager-sstp = (
  #   # fixes "gdbus-codegen: command not found"
  #   mvToNativeInputs [ final.glib ] (
  #     # fixes gtk4-builder-tool wrong format
  #     addNativeInputs [ final.gtk4.dev ] prev.networkmanager-sstp
  #   )
  # );
  # 2023/07/31: upstreaming is blocked on vpnc cross compilation
  # networkmanager-vpnc = mvToNativeInputs [ final.glib ] prev.networkmanager-vpnc;
  # fixes "properties/gresource.xml: Permission denied"
  #   - by providing glib-compile-resources
  # 2023/07/27: upstreaming is blocked on p11-kit, coeurl cross compilation
  nheko = (prev.nheko.override {
    gst_all_1 = final.gst_all_1 // {
      # don't build gst-plugins-good with "qt5 support"
      # alternative build fix is to remove `qtbase` from nativeBuildInputs:
      # - that avoids the mixd qt5 deps, but forces a rebuild of gst-plugins-good and +20MB to closure
      gst-plugins-good.override = attrs: final.gst_all_1.gst-plugins-good.override (builtins.removeAttrs attrs [ "qt5Support" ]);
    };
  }).overrideAttrs (orig: {
    # fixes "fatal error: lmdb++.h: No such file or directory
    buildInputs = orig.buildInputs ++ [ final.lmdbxx ];
  });
  # 2023/08/02: upstreaming in PR: <https://github.com/NixOS/nixpkgs/pull/225111/files>
  # - needs (my) review
  # notmuch = prev.notmuch.overrideAttrs (upstream: {
  #   # fixes "Error: The dependencies of notmuch could not be satisfied"  (xapian, gmime, glib, talloc)
  #   # when cross-compiling, we only have a triple-prefixed pkg-config which notmuch's configure script doesn't know how to find.
  #   # so just replace these with the nix-supplied env-var which resolves to the relevant pkg-config.
  #   postPatch = upstream.postPatch or "" + ''
  #     sed -i 's/pkg-config/\$PKG_CONFIG/g' configure
  #   '';
  #   XAPIAN_CONFIG = final.buildPackages.writeShellScript "xapian-config" ''
  #     exec ${lib.getBin final.xapian}/bin/xapian-config $@
  #   '';
  #   # depsBuildBuild = [ final.gnupg ];
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     final.gnupg  # nixpkgs specifies gpg as a buildInput instead of a nativeBuildInput
  #     final.perl  # used to build manpages
  #     # final.pythonPackages.python
  #     # final.shared-mime-info
  #   ];
  #   buildInputs = with final; [
  #     xapian gmime3 talloc zlib  # dependencies described in INSTALL
  #     # perl
  #     # pythonPackages.python
  #     ruby  # notmuch links against ruby.so
  #   ];
  #   # buildInputs =
  #   #   (lib.remove
  #   #     final.perl
  #   #     (lib.remove
  #   #       final.gmime
  #   #       (lib.remove final.gnupg upstream.buildInputs)
  #   #     )
  #   #   ) ++ [ final.gmime ];
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

  # openfortivpn = prev.openfortivpn.override {
  #   # fixes "checking for /proc/net/route... configure: error: cannot check for file existence when cross compiling"
  #   inherit (emulated) stdenv;
  # };
  # ostree = prev.ostree.override {
  #   # fixes "configure: error: Need GPGME_PTHREAD version 1.1.8 or later"
  #   inherit (emulated) stdenv;
  # };

  # 2023/09/02: upstreaming is implemented on servo `wip-ostree` branch
  ostree = prev.ostree.overrideAttrs (upstream: {
    # fixes: "configure: error: Need GPGME_PTHREAD version 1.1.8 or later"
    # new failure mode: "./src/libotutil/ot-gpg-utils.h:22:10: fatal error: gpgme.h: No such file or directory"
    # buildInputs = lib.remove final.gpgme upstream.buildInputs;
    # nativeBuildInputs = upstream.nativeBuildInputs ++ [ final.gpgme ];
    # buildInputs = lib.remove final.gjs upstream.buildInputs;
    # configureFlags = lib.remove "--enable-installed-tests" upstream.configureFlags;
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace Makefile-libostree.am \
        --replace "CC=gcc" "CC=${final.stdenv.cc.targetPrefix}cc"
    '';
  });

  # fixes (meson) "Program 'glib-mkenums mkenums' not found or not executable"
  # 2023/07/27: upstreaming is blocked on p11-kit, argyllcms, libavif cross compilation
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

  # pipewire = prev.pipewire.override {
  #   # avoid a dep on python3.10-PyQt5, which has mixed qt5 versions.
  #   # this means we lose firewire support (oh well..?)
  #   ffadoSupport = false;
  # };

  # playerctl = prev.playerctl.overrideAttrs (upstream: {
  #   mesonFlags = upstream.mesonFlags ++ [ "-Dgtk-doc=false" ];
  # });

  # psqlodbc = prev.psqlodbc.override {
  #   # fixes "configure: error: odbc_config not found (required for unixODBC build)"
  #   inherit (emulated) stdenv;
  # };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (py-final: py-prev: {

      # aiohttp = py-prev.aiohttp.overridePythonAttrs (orig: {
      #   # fixes "ModuleNotFoundError: No module named 'setuptools'"
      #   propagatedBuildInputs = orig.propagatedBuildInputs ++ [
      #     py-final.setuptools
      #   ];
      # });

      # defcon = py-prev.defcon.overridePythonAttrs (orig: {
      #   nativeBuildInputs = orig.nativeBuildInputs ++ orig.nativeCheckInputs;
      # });
      # executing = py-prev.executing.overridePythonAttrs (orig: {
      #   # test has an assertion that < 1s of CPU time elapsed => flakey
      #   disabledTestPaths = orig.disabledTestPaths or [] ++ [
      #     # "tests/test_main.py::TestStuff::test_many_source_for_filename_calls"
      #     "tests/test_main.py"
      #   ];
      # });

      eyeD3 = py-prev.eyeD3.overrideAttrs (orig: {
        # weird double-wrapping of the output executable, but somehow with the build python ends up on PYTHONPATH
        postInstall = "";
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
      # ipython = py-prev.ipython.overridePythonAttrs (orig: {
      #   # fixes "FAILED IPython/terminal/tests/test_debug_magic.py::test_debug_magic_passes_through_generators - pexpect.exceptions.TIMEOUT: Timeout exceeded."
      #   disabledTests = orig.disabledTests ++ [ "test_debug_magic_passes_through_generator" ];
      # });
      # mutatormath = py-prev.mutatormath.overridePythonAttrs (orig: {
      #   nativeBuildInputs = orig.nativeBuildInputs or [] ++ orig.nativeCheckInputs;
      # });
      # pandas = py-prev.pandas.overridePythonAttrs (orig: {
      #   # XXX: we only actually need numpy when building in ~/nixpkgs repo: not sure why we need all the propagatedBuildInputs here.
      #   # nativeBuildInputs = orig.nativeBuildInputs ++ [ py-final.numpy ];
      #   nativeBuildInputs = orig.nativeBuildInputs ++ orig.propagatedBuildInputs;
      # });
      # psycopg2 = py-prev.psycopg2.overridePythonAttrs (orig: {
      #   # TODO: upstream  (see tracking issue)
      #   #
      #   # psycopg2 *links* against libpg, so we need the host postgres available at build time!
      #   # present-day nixpkgs only includes it in nativeBuildInputs
      #   buildInputs = orig.buildInputs ++ [ final.postgresql ];
      # });
      # s3transfer = py-prev.s3transfer.overridePythonAttrs (orig: {
      #   # tests explicitly expect host CPU == build CPU
      #   # Bail out! ERROR:../plugins/core.c:221:qemu_plugin_vcpu_init_hook: assertion failed: (success)
      #   # Bail out! ERROR:../accel/tcg/cpu-exec.c:954:cpu_exec: assertion failed: (cpu == current_cpu)
      #   disabledTestPaths = orig.disabledTestPaths ++ [
      #     # "tests/functional/test_processpool.py::TestProcessPoolDownloader::test_cleans_up_tempfile_on_failure"
      #     "tests/functional/test_processpool.py"
      #     # "tests/unit/test_compat.py::TestBaseManager::test_can_provide_signal_handler_initializers_to_start"
      #     "tests/unit/test_compat.py"
      #   ];
      # });
      # scipy = py-prev.scipy.override {
      #   inherit (emulated) stdenv;
      # };
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

  qt5 = let
    emulatedQt5 = prev.qt5.override {
      # emulate qt5base and all qtModules.
      # because qt5 doesn't place this `stdenv` argument into its scope, `libsForQt5` doesn't inherit
      # this stdenv. so anything using `libsForQt5.callPackage` builds w/o emulation.
      stdenv = final.stdenv // {
        mkDerivation = args: buildInQemu {
          override = { stdenv }: stdenv.mkDerivation args;
        };
      };
    };
  in prev.qt5.overrideScope (self: super: {
    inherit (emulatedQt5)
      qtbase
      # without emulation these all fail with "Project ERROR: Cannot run compiler 'g++'."
      qtdeclarative
      qtgraphicaleffects
      qtimageformats
      qtmultimedia
      qtquickcontrols
      qtquickcontrols2
      qtsvg
      qttools
      qtwayland
    ;
  });

  # qt5 = prev.qt5.overrideScope (self: super: {
  #   # emulate all qt5 modules
  #   # this is a good idea, because qt is touchy about mixing "versions",
  #   # but idk if it's necessary -- i haven't tried selective emulation.
  #   #
  #   # qt5's `callPackage` doesn't use the final `qtModule`, but the non-overriden one.
  #   # so to modify `qtModule` we have to go through callPackage.
  #   callPackage = self.newScope {
  #     inherit (self) qtCompatVersion srcs stdenv;
  #     qtModule = args: buildInQemu {
  #       # clunky buildInQemu API, when not used via `callPackage`
  #       override = _attrs: super.qtModule args;
  #     };
  #   };
  #   # emulate qtbase (which doesn't go through qtModule)
  #   qtbase = buildInQemu super.qtbase;
  # });

  # qt5 = prev.qt5.overrideScope (self: super:
  #   let
  #     emulateQtModule = pkg: buildInQemu {
  #       # qtModule never gets `stdenv`
  #       override = _stdenv: pkg;
  #     };
  #   in {
  #   qtbase = buildInQemu super.qtbase;
  #   qtdeclarative = emulateQtModule super.qtdeclarative;
  #   qtgraphicaleffects = emulateQtModule super.qtgraphicaleffects;
  #   qtimageformats = emulateQtModule super.qtimageformats;
  #   qtkeychain = emulateQtModule super.qtkeychain;  #< doesn't exist?
  #   qtmultimedia = emulateQtModule super.qtmultimedia;
  #   qtquickcontrols = emulateQtModule super.qtquickcontrols;
  #   qtquickcontrols2 = emulateQtModule super.qtquickcontrols2;
  #   qtsvg = emulateQtModule super.qtsvg;
  #   qttools = emulateQtModule super.qttools;
  #   qtwayland = emulateQtModule super.qtwayland;
  # });

  # qt5 = prev.qt5.overrideScope (self: super: {
  #   # stdenv.mkDerivation is used by qtModule, so this emulates all the qt modules
  #   stdenv = final.stdenv // {
  #     mkDerivation = args: buildInQemu {
  #       override = { stdenv }: stdenv.mkDerivation args;
  #     };
  #   };
  #   # callPackage/mkDerivation is used by libsForQt5, so we avoid emulating qt consumers.
  #   # mkDerivation = final.stdenv.mkDerivation;
  #   # callPackage = self.newScope {
  #   #   inherit (self) qtCompatVersion qtModule srcs;
  #   #   inherit (final) stdenv;
  #   # };

  #   # qtbase = buildInQemu super.qtbase;
  # });
  # libsForQt5 = prev.libsForQt5.overrideScope (self: super: {
  #   stdenv = final.stdenv;
  #   inherit (self.stdenv) mkderivation;
  # });

  # qt5 = (prev.qt5.override {
  #   # qt5 modules see this stdenv; they don't pick up the scope's qtModule or stdenv
  #   stdenv = emulated.stdenv // {
  #     # mkDerivation = args: buildInQemu (final.stdenv.mkDerivation args);
  #     mkDerivation = args: buildInQemu {
  #       # clunky buildInQemu API, when not used via `callPackage`
  #       override = _attrs: final.stdenv.mkDerivation args;
  #     };
  #   };
  # }).overrideScope (self: super: {
  #   # but for anything using `libsForQt5.callPackage`, don't emulate.
  #   # note: alternative approach is to only `libsForQt5` (it's a separate scope),.
  #   # it inherits so much from the `qt5` scope, so not a clear improvement.
  #   mkDerivation = self.mkDerivationWith final.stdenv.mkDerivation;
  #   callPackage = self.newScope { inherit (self) qtCompatVersion qtModule srcs; inherit (final) stdenv; };
  #   # except, still emulate qtbase.
  #   # all other modules build with qtModule (which emulates), except for qtbase which is behind a `callPackage` and uses `stdenv.mkDerivation`.
  #   # therefore we need to re-emulate it when make callPackage not emulate here.
  #   qtbase = buildInQemu super.qtbase;
  #   # qtbase = super.qtbase.override {
  #   #   # qtbase is the only thing in `qt5` scope that references `[stdenv.]mkDerivation`.
  #   #   # to emulate it, we emulate stdenv; all the other qt5 members are emulated via `qt5.qtModule`
  #   #   inherit (emulated) stdenv;
  #   # };
  # });
  # qt5 = emulated.qt5.overrideScope (self: super: {
  #   # emulate all the qt5 packages, but rework `libsForQt5.callPackage` and `mkDerivation`
  #   # to use non-emulated stdenv by default.
  #   mkDerivation = self.mkDerivationWith final.stdenv.mkDerivation;
  #   callPackage = self.newScope { inherit (self) qtCompatVersion qtModule srcs; inherit (final) stdenv; };
  # });
  # qt6 = prev.qt6.overrideScope' (self: super: {
  #   # # inherit (emulated.qt6) qtModule;
  #   # qtbase = super.qtbase.overrideAttrs (upstream: {
  #   #   # cmakeFlags = upstream.cmakeFlags ++ lib.optionals (final.stdenv.buildPlatform != final.stdenv.hostPlatform) [
  #   #   cmakeFlags = upstream.cmakeFlags ++ lib.optionals (final.stdenv.buildPlatform != final.stdenv.hostPlatform) [
  #   #     # "-DCMAKE_CROSSCOMPILING=True" # fails to solve QT_HOST_PATH error
  #   #     "-DQT_HOST_PATH=${final.buildPackages.qt6.full}"
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
  #   # # qtbase = super.qtbase.override {
  #   # #   # fixes: "You need to set QT_HOST_PATH to cross compile Qt."
  #   # #   inherit (emulated) stdenv;
  #   # # };

  #   qtwebengine = super.qtwebengine.overrideAttrs (upstream: {
  #     # depsBuildBuild = upstream.depsBuildBuild or [] ++ [ final.pkg-config ];
  #     # XXX: qt seems to use its own terminology for "host" and "target":
  #     # - <https://www.qt.io/blog/qt6-development-hosts-and-targets>
  #     # - "host" = machine invoking the compiler
  #     # - "target" = machine on which the resulting qtwebengine.so binaries will run
  #     # XXX: NIX_CFLAGS_COMPILE_<machine> is how we get the `-isystem <dir>` flags.
  #     #      probably we shouldn't blindly copy these from host machine to build machine,
  #     #      as the headers could reasonably make different assumptions.
  #     preConfigure = upstream.preConfigure + ''
  #       # export PKG_CONFIG_HOST="$PKG_CONFIG"
  #       export PKG_CONFIG_HOST="$PKG_CONFIG_FOR_BUILD"
  #       # expose -isystem <zlib> to x86 builds
  #       export NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu="$NIX_CFLAGS_COMPILE"
  #       export NIX_LDFLAGS_x86_64_unknown_linux_gnu="-L${final.buildPackages.zlib}/lib"
  #     '';
  #     patches = upstream.patches or [] ++ [
  #       # ./qtwebengine-host-pkg-config.patch
  #       # alternatively, look at dlopenBuildInputs
  #       ./qtwebengine-host-cc.patch
  #     ];
  #     # patch the qt pkg-config script to show us more debug info
  #     postPatch = upstream.postPatch or "" + ''
  #       sed -i s/options.debug/True/g src/3rdparty/chromium/build/config/linux/pkg-config.py
  #     '';
  #     nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #       final.bintools-unwrapped  # for readelf
  #       final.buildPackages.cups  # for cups-config
  #       final.buildPackages.fontconfig
  #       final.buildPackages.glib
  #       final.buildPackages.harfbuzz
  #       final.buildPackages.icu
  #       final.buildPackages.libjpeg
  #       final.buildPackages.libpng
  #       final.buildPackages.libwebp
  #       final.buildPackages.nss
  #       # final.gcc-unwrapped.libgcc  # for libgcc_s.so
  #       final.buildPackages.zlib
  #     ];
  #     depsBuildBuild = upstream.depsBuildBuild or [] ++ [ final.pkg-config ];
  #     # buildInputs = upstream.buildInputs ++ [
  #     #   final.gcc-unwrapped.libgcc  # for libgcc_s.so. this gets loaded during build, suggesting i surely messed something up
  #     # ];
  #     # buildInputs = upstream.buildInputs ++ [
  #     #   final.gcc-unwrapped.libgcc
  #     # ];
  #     # nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     #   final.icu
  #     # ];
  #     # buildInputs = upstream.buildInputs ++ [
  #     #   final.icu
  #     # ];
  #     # env.NIX_DEBUG="1";
  #     # env.NIX_DEBUG="7";
  #     # cmakeFlags = lib.remove "-DQT_FEATURE_webengine_system_icu=ON" upstream.cmakeFlags;
  #     cmakeFlags = upstream.cmakeFlags ++ lib.optionals (final.stdenv.hostPlatform != final.stdenv.buildPlatform) [
  #       # "--host-cc=${final.buildPackages.stdenv.cc}/bin/cc"
  #       # "--host-cxx=${final.buildPackages.stdenv.cc}/bin/c++"
  #       # these are my own vars, used by my own patch
  #       "-DCMAKE_HOST_C_COMPILER=${final.buildPackages.stdenv.cc}/bin/gcc"
  #       "-DCMAKE_HOST_CXX_COMPILER=${final.buildPackages.stdenv.cc}/bin/g++"
  #       "-DCMAKE_HOST_AR=${final.buildPackages.stdenv.cc}/bin/ar"
  #       "-DCMAKE_HOST_NM=${final.buildPackages.stdenv.cc}/bin/nm"
  #     ];
  #   });
  # });

  # rmlint = prev.rmlint.override {
  #   # fixes "Checking whether the C compiler works... no"
  #   # rmlint is scons; it reads the CC environment variable, though, so *may* be cross compilable
  #   inherit (emulated) stdenv;
  # };
  # 2023/07/30: upstreaming requires some changes, as configure tries to invoke our `python`
  # implemented (broken) on servo cross-staging-2023-07-30 branch
  rpm = prev.rpm.overrideAttrs (upstream: {
    # fixes "python too old". might also be specifiable as a configure flag?
    env = upstream.env // lib.optionalAttrs (upstream.version == "4.18.1") {
      # 4.19.0 upgrade should fix cross compilation.
      # see: <https://github.com/NixOS/nixpkgs/pull/260558>
      PYTHON = final.python3.interpreter;
    };
  });

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

  # 2023/10/23: upstreaming: <https://github.com/NixOS/nixpkgs/pull/263187>
  # snapper = prev.snapper.overrideAttrs (upstream: {
  #   # replace references to build diff/rm to runtime diff/rm
  #   # also reduces closure 305628736 -> 262698112
  #   configureFlags = (upstream.configureFlags or []) ++ [
  #     "DIFFBIN=${final.diffutils}/bin/diff"
  #     "RMBIN=${final.coreutils}/bin/rm"
  #   ];
  #   # strictDeps = true;  #< doesn't actually prevent original symptom
  # });

  spandsp = prev.spandsp.overrideAttrs (upstream: {
    configureFlags = upstream.configureFlags or [] ++ [
      # fixes runtime error: "undefined symbol: rpl_realloc"
      # source is <https://github.com/NixOS/nixpkgs/pull/57825>
      "ac_cv_func_malloc_0_nonnull=yes"
      "ac_cv_func_realloc_0_nonnull=yes"
    ];
  });

  spot = prev.spot.overrideAttrs (upstream:
    let
      rustTargetPlatform = final.rust.toRustTarget final.stdenv.hostPlatform;
    in {
      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace build-aux/cargo.sh --replace \
          'OUTPUT_BIN="$CARGO_TARGET_DIR"' \
          'OUTPUT_BIN="$CARGO_TARGET_DIR/${rustTargetPlatform}"'
      '';
      # nixpkgs sets CARGO_BUILD_TARGET to the build platform target, so correct that.
      buildPhase = ''
        runHook preBuild

        ${final.rust.envVars.setEnv} "CARGO_BUILD_TARGET=${rustTargetPlatform}" ninja -j$NIX_BUILD_CORES

        runHook postBuild
      '';
    }
  );

  squeekboard = prev.squeekboard.overrideAttrs (upstream: {
    # fixes: "meson.build:1:0: ERROR: 'rust' compiler binary not defined in cross or native file"
    # new error: "meson.build:1:0: ERROR: Rust compiler rustc --target aarch64-unknown-linux-gnu -C linker=aarch64-unknown-linux-gnu-gcc can not compile programs."
    # NB(2023/03/04): upstream nixpkgs has a new squeekboard that's closer to cross-compiling; use that
    # NB(2023/08/24): this emulates the entire rust build process
    mesonFlags =
      let
        # ERROR: 'rust' compiler binary not defined in cross or native file
        crossFile = final.writeText "cross-file.conf" ''
          [binaries]
          rust = [ 'rustc', '--target', '${final.rust.toRustTargetSpec final.stdenv.hostPlatform}' ]
        '';
      in
        # upstream.mesonFlags or [] ++
        [
          "-Dtests=false"
          "-Dnewer=true"
          "-Donline=false"
        ]
        ++ lib.optional
          (final.stdenv.hostPlatform != final.stdenv.buildPlatform)
          "--cross-file=${crossFile}"
        ;

    # cargoDeps = null;
    # cargoVendorDir = "vendor";

    # depsBuildBuild = (upstream.depsBuildBuild or []) ++ [
    #   final.pkg-config
    # ];
    # this is identical to upstream, but somehow build fails if i remove it??
    nativeBuildInputs = with final; [
      meson
      ninja
      pkg-config
      glib
      wayland
      wrapGAppsHook
      rustPlatform.cargoSetupHook
      cargo
      rustc
    ];
  });

  # squeekboard = prev.squeekboard.override {
  #   inherit (emulated)
  #     rustPlatform  # fixes original "'rust' compiler binary not defined in cross or native file"
  #     rustc
  #     cargo
  #     stdenv  # fixes "gcc: error: unrecognized command line option '-m64'"
  #     glib  # fixes error when linking src/squeekboard: "/nix/store/3c0dqm093ylw8ks7myzxdaif0m16rgcl-binutils-2.40/bin/ld: /nix/store/jzh15bi6zablx3d9s928w3lgqy6and91-glib-2.74.3/lib/libgio-2.0.so"
  #     wayland  # fixes error when linking src/squeekboard: "/nix/store/3c0dqm093ylw8ks7myzxdaif0m16rgcl-binutils-2.40/bin/ld: /nix/store/ni0vb1pnaznx85378i3h9xhw9cay68g5-wayland-1.21.0/lib/libwayland-client.so: error adding symbols: file in wrong format"
  #     # gtk3  # fails to fix: "/nix/store/acl3fg3z4i96d6lha2cbr16k7bl1zjs5-binutils-2.40/bin/ld: /nix/store/k2jd14yl5qcl3kwifhhs271607fjafbx-gtk+3-3.24.36/lib/libgtk-3.so: error adding symbols: file in wrong format"
  #     wrapGAppsHook  # introduces a competing gtk3 at link-time, unless emulated
  #   ;
  # };

  swaynotificationcenter = prev.swaynotificationcenter.overrideAttrs (upstream: {
    mesonFlags = (upstream.mesonFlags or []) ++ [
      # fixes "[can't find scdoc]"
      # could instead add pkg-config to depsBuildBuild, but then the build tries to link against native deps and fails elsewhere
      "-Dman-pages=false"
    ];
    # for "error: Package `libpulse' not found in specified Vala API directories or GObject-Introspection GIR directories"
    # apparently vala setuphook incorrectly uses hostOffset, instead of targetOffset?
    nativeBuildInputs = upstream.nativeBuildInputs ++ [ final.libpulseaudio ];
  });

  # sysprof = (
  #   # fixes: "src/meson.build:12:2: ERROR: Program 'gdbus-codegen' not found or not executable"
  #   # 2023/07/27: upstreaming is blocked on p11-kit cross compilation
  #   mvToNativeInputs [ final.glib ] prev.sysprof
  # );
  # tangram = rmNativeInputs [ final.gobject-introspection ] (
  # tangram = mvToBuildInputs [ (dontCheck (useEmulatedStdenv final.blueprint-compiler)) ] (
  #   addNativeInputs [ final.gjs ] (  # new error: "gi._error.GError: g-invoke-error-quark: Could not locate g_option_error_quark" loading glib
  #     prev.tangram.override {
  #       blueprint-compiler = dontCheck (useEmulatedStdenv final.blueprint-compiler);
  #     }
  #   )
  # );
  # tangram = (prev.tangram.override {
  #   inherit (emulated) stdenv;
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = (lib.remove final.blueprint-compiler upstream.nativeBuildInputs)++ [
  #     # final.gjs
  #   ];
  #   buildInputs = upstream.buildInputs ++ [
  #     (dontCheck (useEmulatedStdenv final.blueprint-compiler))
  #   ];
  # });
  # tangram = prev.tangram.override {
  #   gjs = emulated.gjs.overrideAttrs {
  #     doCheck = false;  # tests time out
  #   };
  # };
  # tangram = useEmulatedStdenv prev.tangram;
  # tangram = addNativeInputs [ final.gjs ] (prev.tangram.override {
  #   gjs = emulated.gjs.overrideAttrs {
  #     doCheck = false;  # tests time out
  #   };
  # });
  # tangram = prev.tangram.override {
  #   inherit (emulated) stdenv;
  #   gjs = emulated.gjs.overrideAttrs {
  #     doCheck = false;  # tests time out
  #   };
  # };
  tangram = (prev.tangram.override {
    # N.B. blueprint-compiler is in nativeBuildInputs.
    # the trick here is to force the aarch64 versions to be used during build (via emulation).
    # blueprint-compiler override shared with flare-signal-nixified.
    blueprint-compiler = buildInQemu (final.blueprint-compiler.overrideAttrs (_: {
      # default is to propagate gobject-introspection *as a buildInput*, when it's supposed to be native.
      propagatedBuildInputs = [];
      # "Namespace Gtk not available"
      doCheck = false;
    }));
    # blueprint-compiler = dontCheck emulated.blueprint-compiler;
    # gjs = dontCheck emulated.gjs;
    # gjs = dontCheck (mvToBuildInputs [ final.gobject-introspection ] (useEmulatedStdenv final.gjs));
    # gjs = dontCheck (final.gjs.override {
    #   inherit (emulated) stdenv gobject-introspection;
    # });
    # inherit (emulated) gobject-introspection;
    # gobject-introspection = useEmulatedStdenv final.gobject-introspection;
  }).overrideAttrs (upstream: {
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace src/meson.build \
        --replace "find_program('gjs').full_path()" "'${final.gjs}/bin/gjs'"
    '';
    # buildInputs = upstream.buildInputs ++ [ final.gobject-introspection ];
    # nativeBuildInputs = lib.remove final.gobject-introspection upstream.nativeBuildInputs;
  });
  # tangram = (mvToBuildInputs [ final.blueprint-compiler final.gobject-introspection ] prev.tangram).overrideAttrs (upstream: {
  #   postPatch = (upstream.postPatch or "") + ''
  #     substituteInPlace src/meson.build \
  #       --replace "find_program('gjs').full_path()" "'${final.gjs}/bin/gjs'"
  #   '';
  # });

  # fixes "meson.build:425:23: ERROR: Program 'glib-compile-schemas' not found or not executable"
  # 2023/07/31: upstreaming is unblocked,implemented on servo
  # tracker-miners = mvToNativeInputs [ final.glib ] (
  #   # fixes "meson.build:183:0: ERROR: Can not run test applications in this cross environment."
  #   addNativeInputs [ final.mesonEmulatorHook ] prev.tracker-miners
  # );
  # twitter-color-emoji = prev.twitter-color-emoji.override {
  #   # fails to fix original error
  #   inherit (emulated) stdenv;
  # };

  # fixes: "ar: command not found"
  # `ar` is provided by bintools
  # 2023/07/27: upstreaming is blocked on p11-kit, gnustep cross compilation
  unar = addNativeInputs [ final.bintools ] prev.unar;
  # unixODBCDrivers = prev.unixODBCDrivers // {
  #   # TODO: should this package be deduped with toplevel psqlodbc in upstream nixpkgs?
  #   psql = prev.unixODBCDrivers.psql.overrideAttrs (_upstream: {
  #     # XXX: these are both available as configureFlags, if we prefer that (we probably do, so as to make them available only during specific parts of the build).
  #     ODBC_CONFIG = final.buildPackages.writeShellScript "odbc_config" ''
  #       exec ${final.stdenv.hostPlatform.emulator final.buildPackages} ${final.unixODBC}/bin/odbc_config $@
  #     '';
  #     PG_CONFIG = final.buildPackages.writeShellScript "pg_config" ''
  #       exec ${final.stdenv.hostPlatform.emulator final.buildPackages} ${final.postgresql}/bin/pg_config $@
  #     '';
  #   });
  # };

  # visidata = prev.visidata.override {
  #   # hdf5 / h5py don't cross-compile, but i don't use that file format anyway.
  #   # setting this to null means visidata will work as normal but not be able to load hdf files.
  #   h5py = null;
  # };
  # 2023/07/27: upstreaming is blocked on p11-kit, qtbase cross compilation
  vlc = prev.vlc.overrideAttrs (orig: {
    # fixes: "configure: error: could not find the LUA byte compiler"
    # fixes: "configure: error: protoc compiler needed for chromecast was not found"
    nativeBuildInputs = orig.nativeBuildInputs ++ [ final.lua5 final.protobuf ];
    # fix that it can't find the c compiler
    # makeFlags = orig.makeFlags or [] ++ [ "CC=${prev.stdenv.cc.targetPrefix}cc" ];
    env = orig.env // {
      BUILDCC = "${final.stdenv.cc}/bin/${final.stdenv.cc.targetPrefix}cc";
    };
  });
  # fixes "perl: command not found"
  # 2023/07/30: upstreaming is unblocked, but requires alternative fix
  # - i think the build script tries to run the generated binary?
  vpnc = mvToNativeInputs [ final.perl ] prev.vpnc;
  # wrapGAppsHook = prev.wrapGAppsHook.override {
  #   # prevents build gtk3 from being propagated into places it shouldn't (e.g. waybar)
  #   isGraphical = false;
  # };
  # wrapGAppsHook4 = prev.wrapGAppsHook4.override {
  #   # fixes -msse2, -mfpmath=sse flags being inherited by consumers.
  #   # ^ maybe that's because of the stuff in depsTargetTargetPropagated?
  #   # N.B.: this makes the hook functionally equivalent to `wrapGAppsNoGuiHook`
  #   isGraphical = false;
  #   # gtk3 = final.emptyDirectory;
  # };
  # xapian = prev.xapian.overrideAttrs (upstream: {
  #   # the output has #!/bin/sh scripts.
  #   # - shebangs get re-written on native build, but not cross build
  #   buildInputs = upstream.buildInputs ++ [ final.bash ];
  # });
  # fixes "No package 'xdg-desktop-portal' found"
  # 2023/07/27: upstreaming is blocked on p11-kit,argyllcms cross compilation
  xdg-desktop-portal-gtk = mvToBuildInputs [ final.xdg-desktop-portal ] prev.xdg-desktop-portal-gtk;
  # fixes: "data/meson.build:33:5: ERROR: Program 'msgfmt' not found or not executable"
  # fixes: "src/meson.build:25:0: ERROR: Program 'gdbus-codegen' not found or not executable"
  # 2023/07/27: upstreaming is blocked on p11-kit cross compilation
  xdg-desktop-portal-gnome = (
    addNativeInputs [ final.wayland-scanner ] (
      mvToNativeInputs [ final.gettext final.glib ] prev.xdg-desktop-portal-gnome
    )
  );

  # 2023/07/31: upstreaming is blocked on playerctl
  waybar = (prev.waybar.override {
    runTests = false;
    cavaSupport = false;  # doesn't cross compile
    hyprlandSupport = false;  # doesn't cross compile
    # hopefully fixes: "/nix/store/sc1pz0zaqwpai24zh7xx0brjinflmc6v-aarch64-unknown-linux-gnu-binutils-2.40/bin/aarch64-unknown-linux-gnu-ld: /nix/store/ghxl1zrfnvh69dmv7xa1swcbyx06va4y-wayland-1.22.0/lib/libwayland-client.so: error adding symbols: file in wrong format"
    wrapGAppsHook = final.wrapGAppsHook.override {
      isGraphical = false;
    };
  }).overrideAttrs (upstream: {
    depsBuildBuild = upstream.depsBuildBuild or [] ++ [ final.pkg-config ];
  });

  webkitgtk = prev.webkitgtk.overrideAttrs (upstream: {
    # fixes "wayland-scanner: line 5: syntax error: unterminated quoted string"
    # also: `/nix/store/nnnn-wayland-aarch64-unknown-linux-gnu-1.22.0-bin/bin/wayland-scanner: line 0: syntax error: unexpected word (expecting ")")`
    # with this i can maybe remove `wayland` from nativeBuildInputs, too?
    # note that `webkitgtk` != `webkitgtk_6_0`, so this patch here might be totally unnecessary.
    # 2023/11/06: hostPkgs.moby.webkitgtk_6_0 builds fine on servo; stock pkgsCross.aarch64-multiplatform.webkitgtk_6_0 does not.
    # 2023/11/06: out for PR: <https://github.com/NixOS/nixpkgs/pull/265968>
    cmakeFlags = upstream.cmakeFlags ++ [
      "-DWAYLAND_SCANNER=${final.buildPackages.wayland-scanner}/bin/wayland-scanner"
    ];
  });
  # webkitgtk = prev.webkitgtk.override { stdenv = final.ccacheStdenv; };

  webp-pixbuf-loader = prev.webp-pixbuf-loader.overrideAttrs (upstream: {
    # fixes: "Builder called die: Cannot wrap '/nix/store/kpp8qhzdjqgvw73llka5gpnsj0l4jlg8-gdk-pixbuf-aarch64-unknown-linux-gnu-2.42.10/bin/gdk-pixbuf-thumbnailer' because it is not an executable file"
    # gdk-pixbuf doesn't create a `bin/` directory when cross-compiling, breaks some thumbnailing stuff.
    # - gnome's gdk-pixbuf *explicitly* doesn't build thumbnailer on cross builds
    # see `librsvg` for a more bullet-proof cross-compilation approach
    postInstall = "";
  });
  # XXX: aarch64 webp-pixbuf-loader wanted by gdk-pixbuf-loaders.cache.drv, wanted by aarch64 gnome-control-center

  wike = prev.wike.overrideAttrs (upstream: {
    # wike's meson build script sets host binaries to use build PYTHON
    # disallowedReferences = [];
    postFixup = (upstream.postFixup or "") + ''
      patchShebangs --update $out/share/wike/wike-sp
    '';
  });

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

  # 2023/07/30: upstreaming is blocked on unar (gnustep), unless i also make that optional
  xarchiver = mvToNativeInputs [ final.libxslt ] prev.xarchiver;
}
