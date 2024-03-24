# outstanding cross-compilation PRs/issues:
# - all: <https://github.com/NixOS/nixpkgs/labels/6.topic%3A%20cross-compilation>
# - qtsvg mixed deps: <https://github.com/NixOS/nixpkgs/issues/269756>
#   - big Qt fix: <https://github.com/NixOS/nixpkgs/pull/267311>
#
# outstanding issues:
# - 2023/12/20: argyllcms requires a fully-emulated build
# - 2023/10/10: build python3 is pulled in by many things
#   - nix why-depends --all /nix/store/8g3kd2jxifq10726p6317kh8srkdalf5-nixos-system-moby-23.11.20231011.dirty /nix/store/pzf6dnxg8gf04xazzjdwarm7s03cbrgz-python3-3.10.12/bin/python3.10
#   - gstreamer-vaapi -> gstreamer-dev -> glib-dev
#   - phog -> gnome-shell
#   - portfolio -> {glib,cairo,pygobject}-dev
#   - komikku -> python3.10-brotlicffi -> python3.10-cffi
#   - many others. python3.10-cffi seems to be the offender which infects 70% of consumers though
# - 2023/10/11: build ruby is pulled in by `neovim`:
#   - nix why-depends --all /nix/store/rhli8vhscv93ikb43639c2ysy3a6dmzp-nixos-system-moby-23.11.20231011.30c7fd8 /nix/store/5xbwwbyjmc1xvjzhghk6r89rn4ylidv8-ruby-3.1.4
# - 2023/12/19: rustPlatform.cargoSetupHook outside of `buildRustPackage` or python packages is a mess
#   - it doesn't populate `.cargo/config` with valid cross-compilation config
#   - something to do with the way it's spliced: `nativeBuildInputs = [ rustPlatform.cargoSetupHook.__spliced.hostHost ]` (or hostTarget) WORKS
#   - see <https://github.com/NixOS/nixpkgs/pull/260068> -- it's probably wrong.
#   - WIP fix in `pr-cross-cargo`/`pr-cross-cargo2` nixpkgs branch.
#     - sanity check by building `pkgsCross.aarch64-multiplatform.rav1e`, and the `fd` program mentioned in PR 260068
#     - `pkgsCross.musl64.fd`
#     - `pkgsStatic.fd`
#   - this is way too tricky to enable cross compilation without breaking the musl stuff.
#     - i lost a whole day trying to get it to work: don't do it!
#
# partially fixed:
# - 2023/10/11: build coreutils pulled in by rpm 4.18.1, but NOT by 4.19.0
#   - nix why-depends --all /nix/store/gjwd2x507x7gjycl5q0nydd39d3nkwc5-dtrx-8.5.3-aarch64-unknown-linux-gnu /nix/store/y9gr7abwxvzcpg5g73vhnx1fpssr5frr-coreutils-9.3
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
  buildOnHost = { overrides ? { inherit (emulated) stdenv; } }: pkg:
    let
      # patch packages which don't expect to be moved to a different platform
      preFixPkg = p:
        if p.name or null == "make-shell-wrapper-hook" then
          p.overrideAttrs (_: {
            # unconditionally use the outermost targetPackages shell
            shell = final.runtimeShell;
          })
          # final.makeBinaryWrapper
        # else if p.name or null == "make-binary-wrapper-hook" then
        #   p.override { DNE = "not-yet-implemented"; }
        else if p.pname or null == "pkg-config-wrapper" then
          p.override {
            # default pkg-config.__spliced.hostTarget still wants to run on the build machine.
            # overriding buildPackages fixes that, and overriding stdenvNoCC makes it be just `pkg-config`, unmangled.
            stdenvNoCC = emulated.stdenvNoCC;
            buildPackages = final.hostPackages;  # TODO: just `final`?
          }
        else if p.name or null == "npm-install-hook" then
          p.overrideAttrs (base: {
            propagatedNativeBuildInputs = base.propagatedBuildInputs;
            propagatedBuildInputs = [];
          })
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
      # unsplicePkg = p: p.__spliced.hostHost or p;
      unsplicePkgs = ps: map (p: unsplicePkg (preFixPkg p)) ps;
    in
      (pkg.override overrides).overrideAttrs (upstream: {
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

  # TODO: may be able to use qemu-system instead of booting a full linux?
  # - <https://github.com/NixOS/nixpkgs/issues/119885#issuecomment-858491472>
  buildInQemu = overrides: pkg: emulateBuilderQemu (buildOnHost overrides pkg);
  # buildInProot = pkg: emulateBuilderProot (buildOnHost pkg);
in with final; {
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


  # adwaita-qt6 = prev.adwaita-qt6.override {
  #   # adwaita-qt6 still uses the qt5 version of these libs by default?
  #   inherit (qt6) qtbase qtwayland;
  # };
  # qt6 doesn't cross compile. the only thing that wants it is phosh/gnome, in order to
  # configure qt6 apps to look stylistically like gtk apps.
  # adwaita-qt6 isn't an input into any other packages we build -- it's just placed on the systemPackages.
  # so... just set it to null and that's Good Enough (TM).
  # adwaita-qt6 = derivation { name = "null-derivation"; builder = "/dev/null"; }; # null;
  # adwaita-qt6 = stdenv.mkDerivation { name = "null-derivation"; };
  # adwaita-qt6 = emptyDirectory;
  # same story as adwaita-qt6
  # qgnomeplatform-qt6 = emptyDirectory;

  # 2024/02/27: upstreaming is unblocked (but this solution no longer works)
  # apacheHttpd_2_4 = prev.apacheHttpd_2_4.overrideAttrs (upstream: {
  #   configureFlags = upstream.configureFlags or [] ++ [
  #     "ap_cv_void_ptr_lt_long=no"  # configure can't AC_TRY_RUN, and can't validate that sizeof (void*) == sizeof long
  #   ];
  #   # let nix figure out the perl shebangs.
  #   # some of these perl scripts are shipped on the host, others in the .dev output for the build machine.
  #   # postPatch methods create cycles
  #   # postPatch = ''
  #   #   substituteInPlace configure --replace \
  #   #     '/replace/with/path/to/perl/interpreter' \
  #   #     '/usr/bin/perl'
  #   # '';
  #   # postPatch = ''
  #   #   substituteInPlace support/apxs.in --replace \
  #   #     '@perlbin@' \
  #   #     '/usr/bin/perl'
  #   # '';
  #   postFixup = upstream.postFixup or "" + ''
  #     sed -i 's:/replace/with/path/to/perl/interpreter:${buildPackages.perl}/bin/perl:' $dev/bin/apxs
  #   '';
  # });

  # apacheHttpd_2_4 = (prev.apacheHttpd_2_4.override {
  #   # fixes `configure: error: Size of "void *" is less than size of "long"`
  #   inherit (emulated) stdenv;
  # }).overrideAttrs (upstream: {
  #   # nativeBuildInputs = upstream.nativeBuildInputs ++ [ bintools ];
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     buildPackages.stdenv.cc  # fixes: "/nix/store/czvaa9y9ch56z53c0b0f5bsjlgh14ra6-apr-aarch64-unknown-linux-gnu-1.7.0-dev/share/build/libtool: line 1890: aarch64-unknown-linux-gnu-ar: command not found"
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

  # 2024/02/27: upstreaming is unblocked
  appstream = prev.appstream.overrideAttrs (upstream: {
    # fixes: "Message: Native appstream required for cross-building"
    # error introduced in:
    # - <https://github.com/ximion/appstream/pull/510>
    # - <https://github.com/NixOS/nixpkgs/pull/273297>
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace data/meson.build \
        --replace 'meson.is_cross_build()' 'false'
    '';
    # nativeBuildInputs = upstream.nativeBuildInputs ++ [
    #   prev.appstream
    # ];
  });

  # binutils = prev.binutils.override {
  #   # fix that resulting binary files would specify build #!sh as their interpreter.
  #   # dtrx is the primary beneficiary of this.
  #   # this doesn't actually cause mass rebuilding.
  #   # note that this isn't enough to remove all build references:
  #   # - expand-response-params still references build stuff.
  #   shell = runtimeShell;
  # };

  # 2023/10/23: upstreaming blocked by gvfs, webkitgtk 4.1
  # fixes: "error: Package <foo> not found in specified Vala API directories or GObject-Introspection GIR directories"
  calls = prev.calls.overrideAttrs (upstream: {
    # TODO: try building with mesonEmulatorHook when i upstream this
    # nativeBuildInputs = upstream.nativeBuildInputs ++ lib.optionals (!prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform) [
    #   mesonEmulatorHook
    # ];
    outputs = lib.remove "devdoc" upstream.outputs;
    mesonFlags = lib.remove "-Dgtk_doc=true" upstream.mesonFlags;
  });

  # 2024/02/27: upstreaming is unblocked
  # cdrtools = prev.cdrtools.override {
  #   # "configure: error: installation or configuration problem: C compiler cc not found."
  #   inherit (emulated) stdenv;
  # };
  # cdrtools = prev.cdrtools.overrideAttrs (upstream: {
  #   # can't get it to actually use our CC, even when specifying these explicitly
  #   # CC = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";
  #   makeFlags = upstream.makeFlags ++ [
  #     "CC=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
  #   ];
  # });

  # cinny = buildInQemu { overrides = {
  #   buildNpmPackage = buildNpmPackage.override {
  #     inherit (emulated) stdenv;
  #     buildPackages = final.pkgsHostHost;
  #   };
  # }; } (prev.cinny.overrideAttrs (upstream: {
  #   postPatch = ''
  #     mkdir $TMP
  #   '';
  #   NIX_DEBUG = "6";
  # }));

  # 2024/02/27: upstreaming is blocked on appstream, qtsvg
  # clapper = prev.clapper.overrideAttrs (upstream: {
  #   # use the host gjs (meson's find_program expects it to be executable)
  #   postPatch = (upstream.postPatch or "") + ''
  #     substituteInPlace bin/meson.build \
  #       --replace "find_program('gjs').path()" "'${gjs}/bin/gjs'"
  #   '';
  # });

  # conky = ((useEmulatedStdenv prev.conky).override {
  #   # docbook2x dependency doesn't cross compile
  #   docsSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [ git ];
  # });
  # conky = (prev.conky.override {
  #   # docbook2x dependency doesn't cross compile
  #   docsSupport = prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform;
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     # "Unable to find program 'git'"
  #     git
  #     # "bash: line 1: toluapp: command not found"
  #     toluapp
  #   ];
  # });

  delfin = prev.delfin.overrideAttrs (upstream:
  let
    cargoEnvWrapper = buildPackages.writeShellScript "cargo-env-wrapper" ''
      CARGO_BIN="$1"
      shift
      CARGO_OP="$1"
      shift

      ${rust.envVars.setEnv} "$CARGO_BIN" "$CARGO_OP" --target "${rust.envVars.rustHostPlatformSpec}" "$@"
    '';
  in {
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      # fixes: loaders/meson.build:72:7: ERROR: Program 'msgfmt' not found or not executable
      buildPackages.gettext
    ];
    postPatch = ''
      substituteInPlace delfin/meson.build \
        --replace "cargo, 'build'," "'${cargoEnvWrapper}', cargo, 'build'," \
        --replace "'delfin' / rust_target" "'delfin' / '${rust.envVars.rustHostPlatformSpec}' / rust_target"
    '';
  });

  # 2023/12/08: upstreaming blocked on qtsvg (pipewire)
  dialect = prev.dialect.overrideAttrs (upstream: {
    # blueprint-compiler runs on the build machine, but tries to load gobject-introspection types meant for the host.
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace data/resources/meson.build --replace \
        "find_program('blueprint-compiler')" \
        "'env', 'GI_TYPELIB_PATH=${buildPackages.gdk-pixbuf.out}/lib/girepository-1.0:${buildPackages.harfbuzz.out}/lib/girepository-1.0:${buildPackages.gtk4.out}/lib/girepository-1.0:${buildPackages.graphene}/lib/girepository-1.0:${buildPackages.libadwaita}/lib/girepository-1.0:${buildPackages.pango.out}/lib/girepository-1.0', find_program('blueprint-compiler')"
    '';
    # error: "<dialect> is not allowed to refer to the following paths: <build python>"
    # dialect's meson build script sets host binaries to use build PYTHON
    # disallowedReferences = [];
    postFixup = (upstream.postFixup or "") + ''
      patchShebangs --update --host $out/share/dialect/search_provider
    '';
    # upstream sets strictDeps=false which makes gAppsWrapperHook wrap with the build dependencies
    strictDeps = true;
  });

  # 2023/12/08: upstreaming is blocked on rpm
  dtrx = prev.dtrx.override {
    # `binutils` is the nix wrapper, which reads nix-related env vars
    # before passing on to e.g. `ld`.
    # dtrx probably only needs `ar` at runtime, not even `ld`.
    binutils = binutils-unwrapped;
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

  # firefox-extensions = prev.firefox-extensions.overrideScope (self: super: {
  #   unwrapped = super.unwrapped // {
  #     browserpass-extension = super.unwrapped.browserpass-extension.override {
  #       mkYarnModules = args: buildInQemu {
  #         override = { stdenv }: (
  #           (yarn2nix-moretea.override {
  #             pkgs = pkgs.__splicedPackages // { inherit stdenv; };
  #           }).mkYarnModules args
  #         ).overrideAttrs (upstream: {
  #           # i guess the VM creates the output directory for the derivation? not sure.
  #           # and `mv` across the VM boundary breaks, too?
  #           # original errors:
  #           # - "mv: cannot create directory <$out>: File exists"
  #           # - "mv: failed to preserve ownership for"
  #           buildPhase = lib.replaceStrings
  #             [
  #               "mkdir $out"
  #               "mv "
  #             ]
  #             [
  #               "mkdir $out || true ; chmod +w deps/browserpass-extension-modules/package.json"
  #               "cp -Rv "
  #             ]
  #             upstream.buildPhase
  #           ;
  #         });
  #       };
  #     };
  #   };
  # });

  # 2024/02/27: upstreaming is unblocked
  firejail = prev.firejail.overrideAttrs (upstream: {
    # firejail executes its build outputs to produce the default filter list.
    # i think we *could* copy the default filters from pkgsBuildBuild, but that doesn't seem future proof
    # for any (future) arch-specific filtering
    postPatch = (upstream.postPatch or "") + (let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in lib.optionalString (!prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform) ''
      substituteInPlace Makefile \
        --replace '	src/fseccomp/fseccomp' '	${emulator} src/fseccomp/fseccomp' \
        --replace '	src/fsec-optimize/fsec-optimize' '	${emulator} src/fsec-optimize/fsec-optimize'
    '');
  });

  # flare-signal = prev.flare-signal.override {
  #   # fixes "cargo:warning=aarch64-unknown-linux-gnu-gcc: error: unrecognized command-line option ‘-m64’"
  #   inherit (emulated) cargo meson rustc rustPlatform stdenv;
  # };
  flare-signal = prev.flare-signal.overrideAttrs (upstream: {
    # blueprint-compiler runs on the build machine, but tries to load gobject-introspection types meant for the host.
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace data/resources/meson.build --replace \
        "find_program('blueprint-compiler')" \
        "'env', 'GI_TYPELIB_PATH=${buildPackages.gdk-pixbuf.out}/lib/girepository-1.0:${buildPackages.harfbuzz.out}/lib/girepository-1.0:${buildPackages.gtk4.out}/lib/girepository-1.0:${buildPackages.graphene}/lib/girepository-1.0:${buildPackages.libadwaita}/lib/girepository-1.0:${buildPackages.pango.out}/lib/girepository-1.0', find_program('blueprint-compiler')"
    '';
     env = let
       inherit buildPackages stdenv rust;
       ccForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc";
       cxxForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}c++";
       ccForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";
       cxxForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++";
       rustBuildPlatform = rust.toRustTarget stdenv.buildPlatform;
       rustTargetPlatform = rust.toRustTarget stdenv.hostPlatform;
       rustTargetPlatformSpec = rust.toRustTargetSpec stdenv.hostPlatform;
     in {
       # taken from <pkgs/build-support/rust/hooks/default.nix>
       # fixes "cargo:warning=aarch64-unknown-linux-gnu-gcc: error: unrecognized command-line option ‘-m64’"
       # XXX: these aren't necessarily valid environment variables: the referenced nix file is more clever to get them to work.
       "CC_${rustBuildPlatform}" = "${ccForBuild}";
       "CXX_${rustBuildPlatform}" = "${cxxForBuild}";
       "CC_${rustTargetPlatform}" = "${ccForHost}";
       "CXX_${rustTargetPlatform}" = "${cxxForHost}";
     };
  });

  flare-signal-nixified = prev.flare-signal-nixified.overrideAttrs (upstream: {
    # blueprint-compiler runs on the build machine, but tries to load gobject-introspection types meant for the host.
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace data/resources/meson.build --replace \
        "find_program('blueprint-compiler')" \
        "'env', 'GI_TYPELIB_PATH=${buildPackages.gdk-pixbuf.out}/lib/girepository-1.0:${buildPackages.harfbuzz.out}/lib/girepository-1.0:${buildPackages.gtk4.out}/lib/girepository-1.0:${buildPackages.graphene}/lib/girepository-1.0:${buildPackages.libadwaita}/lib/girepository-1.0:${buildPackages.pango.out}/lib/girepository-1.0', find_program('blueprint-compiler')"
    '';
  });

  # 2024/02/27: upstreaming is blocked on appstream
  flatpak = prev.flatpak.overrideAttrs (upstream: {
    # fixes "No package 'libxml-2.0' found"
    buildInputs = upstream.buildInputs ++ [ libxml2 ];
    configureFlags = upstream.configureFlags ++ [
      "--enable-selinux-module=no"  # fixes "checking for /usr/share/selinux/devel/Makefile... configure: error: cannot check for file existence when cross compiling"
      "--disable-gtk-doc"  # fixes "You must have gtk-doc >= 1.20 installed to build documentation for Flatpak"
    ];

    postPatch = let
      # copied from nixpkgs flatpak and modified to use buildPackages python
      vsc-py = buildPackages.python3.withPackages (pp: [
        pp.pyparsing
      ]);
    in ''
      patchShebangs buildutil
      patchShebangs tests
      PATH=${lib.makeBinPath [vsc-py]}:$PATH patchShebangs --build subprojects/variant-schema-compiler/variant-schema-compiler
    '' + ''
      sed -i s:'\$BWRAP --version:${stdenv.hostPlatform.emulator buildPackages} \$BWRAP --version:' configure.ac
      sed -i s:'\$DBUS_PROXY --version:${stdenv.hostPlatform.emulator buildPackages} \$DBUS_PROXY --version:' configure.ac
    '';
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
  # fractal-latest = prev.fractal-latest.override {
  #   # fixes "cargo:warning=aarch64-unknown-linux-gnu-gcc: error: unrecognized command-line option ‘-m64’"
  #   # seems to hang when compiling fractal
  #   fractal-next = fractal-next.override {
  #     inherit (emulated) cargo meson rustc rustPlatform stdenv;
  #   };
  # };
  # fractal = prev.fractal.overrideAttrs (upstream: {
  #   env = let
  #     inherit buildPackages stdenv rust;
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
  #     # XXX: these aren't necessarily valid environment variables: the referenced nix file is more clever to get them to work.
  #     "CC_${rustBuildPlatform}" = "${ccForBuild}";
  #     "CXX_${rustBuildPlatform}" = "${cxxForBuild}";
  #     "CC_${rustTargetPlatform}" = "${ccForHost}";
  #     "CXX_${rustTargetPlatform}" = "${cxxForHost}";
  #   };
  #   mesonFlags = (upstream.mesonFlags or []) ++
  #     (let
  #       # ERROR: 'rust' compiler binary not defined in cross or native file
  #       crossFile = writeText "cross-file.conf" ''
  #       [binaries]
  #       rust = [ 'rustc', '--target', '${rust.toRustTargetSpec stdenv.hostPlatform}' ]
  #     '';
  #     in
  #       lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [ "--cross-file=${crossFile}" ]
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

  # 2024/02/27: upstreaming is unblocked -- if i can rework to not use emulation
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
  #   #   mesonEmulatorHook
  #   # ];
  # });
  # solves (meson) "Run-time dependency libgcab-1.0 found: NO (tried pkgconfig and cmake)", and others.
  # 2024/02/27: upstreaming is blocked on fwupd-efi
  # fwupd = (addBuildInputs
  #   [ gcab ]
  #   (mvToBuildInputs [ gnutls ] prev.fwupd)
  # ).overrideAttrs (upstream: {
  #   # XXX: gcab is apparently needed as both build and native input
  #   # can't build docs w/o adding `gi-docgen` to ldpath, but that adds a new glibc to the ldpath
  #   # which causes host binaries to be linked against the build libc & fail
  #   mesonFlags = (lib.remove "-Ddocs=enabled" upstream.mesonFlags) ++ [ "-Ddocs=disabled" ];
  #   outputs = lib.remove "devdoc" upstream.outputs;
  # });

  # 2024/02/27: upstreaming is blocked on qtsvg (via pipewire)
  # required by epiphany, gnome-settings-daemon
  # N.B.: should be able to remove gnupg/ssh from {native}buildInputs when upstreaming
  gcr_4 = prev.gcr_4.overrideAttrs (upstream: {
    # fixes (meson): "ERROR: Program 'gpg2 gpg' not found or not executable"
    mesonFlags = (upstream.mesonFlags or []) ++ [
      "-Dgpg_path=${gnupg}/bin/gpg"
    ];
  });
  # 2023/10/23: upstreaming: <https://github.com/NixOS/nixpkgs/pull/263158>
  # gcr = prev.gcr.overrideAttrs (upstream: {
  #   # removes build platform's gnupg from runtime closure
  #   mesonFlags = (upstream.mesonFlags or []) ++ [
  #     "-Dgpg_path=${gnupg}/bin/gpg"
  #   ];
  # });

  # 2024/02/27: upstreaming is unblocked
  glycin-loaders = prev.glycin-loaders.overrideAttrs (upstream:
  let
    cargoEnvWrapper = buildPackages.writeShellScript "cargo-env-wrapper" ''
      CARGO_BIN="$1"
      shift
      CARGO_OP="$1"
      shift

      ${rust.envVars.setEnv} "$CARGO_BIN" "$CARGO_OP" --target "${rust.envVars.rustHostPlatformSpec}" "$@"
    '';
  in {
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      # fixes: loaders/meson.build:72:7: ERROR: Program 'msgfmt' not found or not executable
      buildPackages.gettext
    ];
    postPatch = ''
      substituteInPlace loaders/meson.build \
        --replace "cargo_bin, 'build'," "'${cargoEnvWrapper}', cargo_bin, 'build'," \
        --replace "'loaders' / rust_target" "'loaders' / '${rust.envVars.rustHostPlatformSpec}' / rust_target"
    '';
  });


  # gnustep = prev.gnustep.overrideScope (self: super: {
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
  # 2023/12/20: upstreaming is blocked on webp-pixbuf-loader
  # gthumb = mvInputs { nativeBuildInputs = [ glib ]; } prev.gthumb;

  # 2023/12/20: upstreaming is blocked on qtsvg (via pipewire)
  gnome-frog = prev.gnome-frog.overrideAttrs (upstream: {
    # blueprint-compiler runs on the build machine, but tries to load gobject-introspection types meant for the host.
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace data/meson.build --replace \
        "find_program('blueprint-compiler')" \
        "'env', 'GI_TYPELIB_PATH=${buildPackages.gdk-pixbuf.out}/lib/girepository-1.0:${buildPackages.harfbuzz.out}/lib/girepository-1.0:${buildPackages.gtk4.out}/lib/girepository-1.0:${buildPackages.graphene}/lib/girepository-1.0:${buildPackages.libadwaita}/lib/girepository-1.0:${buildPackages.pango.out}/lib/girepository-1.0', find_program('blueprint-compiler')"
    '';
  });

  gnome = prev.gnome.overrideScope (self: super: {
    evolution-data-server = super.evolution-data-server.overrideAttrs (upstream: {
      # 2023/12/08: upstreaming is unblocked, but depends on webkitgtk 4.1
      cmakeFlags = upstream.cmakeFlags ++ [
        "-DCMAKE_CROSSCOMPILING_EMULATOR=${stdenv.hostPlatform.emulator buildPackages}"
        "-DENABLE_TESTS=no"
        "-DGETTEXT_MSGFMT_EXECUTABLE=${lib.getBin buildPackages.gettext}/bin/msgfmt"
        "-DGETTEXT_MSGMERGE_EXECUTABLE=${lib.getBin buildPackages.gettext}/bin/msgmerge"
        "-DGETTEXT_XGETTEXT_EXECUTABLE=${lib.getBin buildPackages.gettext}/bin/xgettext"
        "-DGLIB_COMPILE_RESOURCES=${lib.getDev buildPackages.glib}/bin/glib-compile-resources"
        "-DGLIB_COMPILE_SCHEMAS=${lib.getDev buildPackages.glib}/bin/glib-compile-schemas"
      ];
      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace src/addressbook/libebook-contacts/CMakeLists.txt --replace \
          'COMMAND ''${CMAKE_CURRENT_BINARY_DIR}/gen-western-table' \
          'COMMAND ${stdenv.hostPlatform.emulator buildPackages} ''${CMAKE_CURRENT_BINARY_DIR}/gen-western-table' 
        substituteInPlace src/camel/CMakeLists.txt --replace \
          'COMMAND ''${CMAKE_CURRENT_BINARY_DIR}/camel-gen-tables' \
          'COMMAND ${stdenv.hostPlatform.emulator buildPackages} ''${CMAKE_CURRENT_BINARY_DIR}/camel-gen-tables'
      '';
      # N.B.: the deps are funky even without cross compiling.
      # upstream probably wants to replace pcre with pcre2, and maybe provide perl
      # nativeBuildInputs = upstream.nativeBuildInputs ++ [
      #   perl  # fixes "The 'perl' not found, not installing csv2vcard"
      #   # glib
      #   # libiconv
      #   # iconv
      # ];
      # buildInputs = upstream.buildInputs ++ [
      #   pcre2  # fixes: "Package 'libpcre2-8', required by 'glib-2.0', not found"
      #   mount  # fails to fix: "Package 'mount', required by 'gio-2.0', not found"
      # ];
    });

    # 2023/08/01: upstreaming is blocked on nautilus, gnome-user-share (apache-httpd, webp-pixbuf-loader)
    # fixes: "src/meson.build:106:0: ERROR: Program 'glib-compile-resources' not found or not executable"
    file-roller = mvToNativeInputs [ glib ] super.file-roller;

    # 2023/12/08: upstreaming is blocked by evolution-data-server
    geary = super.geary.overrideAttrs (upstream: {
      buildInputs = upstream.buildInputs ++ [
        # glib
        appstream-glib
        libxml2
      ];
    });

    # 2024/02/27: upstreaming is unblocked
    # fixes: "src/meson.build:3:0: ERROR: Program 'glib-compile-resources' not found or not executable"
    # gnome-color-manager = mvToNativeInputs [ glib ] super.gnome-color-manager;

    # 2023/08/01: upstreaming is blocked by apache-httpd, argyllcms, ibus, libavif, webp-pixbuf-loader
    # fixes "subprojects/gvc/meson.build:30:0: ERROR: Program 'glib-mkenums mkenums' not found or not executable"
    # gnome-control-center = mvToNativeInputs [ glib ] super.gnome-control-center;

    gnome-keyring = super.gnome-keyring.overrideAttrs (orig: {
      # 2024/02/27: upstreaming is unblocked
      # this seems to work in practice, but leaves gkr with a reference to the build openssl, sqlite, xz, libxcrypt, glibc
      # fixes "configure.ac:374: error: possibly undefined macro: AM_PATH_LIBGCRYPT"
      nativeBuildInputs = orig.nativeBuildInputs ++ [ libgcrypt openssh glib ];
    });
    gnome-maps = super.gnome-maps.overrideAttrs (upstream: {
      # 2023/11/21: upstreaming is blocked by libshumate, qtsvg (via pipewire/ffado)
      postPatch = (upstream.postPatch or "") + ''
        # fixes: "ERROR: Program 'gjs' not found or not executable"
        substituteInPlace meson.build \
          --replace "find_program('gjs')" "find_program('${gjs}/bin/gjs')"
        # fixes missing `gapplication` binary when not on PATH (needed for non-cross build too)
        substituteInPlace data/org.gnome.Maps.desktop.in.in \
          --replace "gapplication" "${glib.bin}/bin/gapplication"
      '';
    });
    # gnome-shell = super.gnome-shell.overrideAttrs (orig: {
    #   # fixes "meson.build:128:0: ERROR: Program 'gjs' not found or not executable"
    #   # does not fix "_giscanner.cpython-310-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory"  (python import failure)
    #   nativeBuildInputs = orig.nativeBuildInputs ++ [ gjs gobject-introspection ];
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
    # gnome-shell = super.gnome-shell.overrideAttrs (upstream: {
    #   # 2023/08/01: upstreaming is blocked on argyllcms, gnome-keyring, gnome-clocks, ibus, libavif, webp-pixbuf-loader
    #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
    #     gjs  # fixes "meson.build:128:0: ERROR: Program 'gjs' not found or not executable"
    #   ];
    # });
    gnome-settings-daemon = super.gnome-settings-daemon.overrideAttrs (orig: {
      # 2024/02/27: upstreaming is blocked on qtsvg (ffado)
      #   gsd is required by xdg-desktop-portal-gtk
      # glib solves: "Program 'glib-mkenums mkenums' not found or not executable"
      nativeBuildInputs = orig.nativeBuildInputs ++ [ glib ];
      # pkg-config solves: "plugins/power/meson.build:22:0: ERROR: Dependency lookup for glib-2.0 with method 'pkgconfig' failed: Pkg-config binary for machine 0 not found."
      # stdenv.cc fixes: "plugins/power/meson.build:60:0: ERROR: No build machine compiler for 'plugins/power/gsd-power-enums-update.c'"
      # but then it fails with a link-time error.
      # depsBuildBuild = orig.depsBuildBuild or [] ++ [ glib pkg-config buildPackages.stdenv.cc ];
      # hack to just not build the power plugin (panel?), to avoid cross compilation errors
      postPatch = orig.postPatch + ''
        sed -i "s/disabled_plugins = \[\]/disabled_plugins = ['power']/" plugins/meson.build
      '';
    });

    # 2023/08/01: upstreaming is blocked on argyllcms, gnome-keyring, gnome-clocks, ibus, libavif, webp-pixbuf-loader (gnome-shell)
    # fixes: "gdbus-codegen not found or executable"
    # gnome-session = mvToNativeInputs [ glib ] super.gnome-session;
    # gnome-terminal = super.gnome-terminal.overrideAttrs (orig: {
    #   # 2023/07/31: upstreaming is blocked on argyllcms, apache-httpd, gnome-keyring, libavif, gnome-clocks, ibus, webp-pixbuf-loader
    #   # fixes "meson.build:343:0: ERROR: Dependency "libpcre2-8" not found, tried pkgconfig"
    #   buildInputs = orig.buildInputs ++ [ pcre2 ];
    # });
    # 2023/07/31: upstreaming is blocked on apache-httpd
    # fixes: meson.build:111:6: ERROR: Program 'glib-compile-schemas' not found or not executable
    # gnome-user-share = addNativeInputs [ glib ] super.gnome-user-share;

    # mutter = super.mutter.overrideAttrs (orig: {
    #   # 2024/02/27: upstreaming is blocked on appstream, possibly others
    #   # N.B.: not all of this suitable to upstreaming, as-is.
    #   # mesa and xorgserver are removed here because they *themselves* don't build for `buildPackages` (temporarily: 2023/10/26)
    #   nativeBuildInputs = lib.subtractLists [ mesa xorg.xorgserver ] orig.nativeBuildInputs;
    #   buildInputs = orig.buildInputs ++ [
    #     mesa  # fixes "meson.build:237:2: ERROR: Dependency "gbm" not found, tried pkgconfig"
    #     libGL  # fixes "meson.build:184:11: ERROR: Dependency "gl" not found, tried pkgconfig and system"
    #   ];
    #   # Run-time dependency gi-docgen found: NO (tried pkgconfig and cmake)
    #   mesonFlags = lib.remove "-Ddocs=true" orig.mesonFlags;
    #   outputs = lib.remove "devdoc" orig.outputs;
    #   postInstall = lib.replaceStrings [ "${glib.dev}" ] [ "${buildPackages.glib.dev}" ] orig.postInstall;
    # });
    # nautilus = (
    #   # 2023/11/21: upstreaming is blocked on apache-httpd, webp-pixbuf-loader, qtsvg
    #   addInputs {
    #     # fixes: "meson.build:123:0: ERROR: Dependency "libxml-2.0" not found, tried pkgconfig"
    #     buildInputs = [ libxml2 ];
    #     # fixes: "meson.build:226:6: ERROR: Program 'gtk-update-icon-cache' not found or not executable"
    #     nativeBuildInputs = [ gtk4 ];
    #   }
    # );
  });

  # gnome2 = prev.gnome2.overrideScope (self: super: {
  #   # GConf = (
  #   #   # python3 -> nativeBuildInputs fixes "2to3: command not found"
  #   #   # glib.dev in nativeBuildInputs fixes "gconfmarshal.list: command not found"
  #   #   # new error: "** (orbit-idl-2): WARNING **: ./GConfX.idl compilation failed"
  #   #   addNativeInputs
  #   #     [ glib.dev ]
  #   #     (mvToNativeInputs [ python3 ] super.GConf);
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
  # });

  # 2024/02/27: upstreaming is blocked on python3Packages.eyeD3
  gpodder = prev.gpodder.overridePythonAttrs (upstream: {
    # fix gobject-introspection overrides import that otherwise fails on launch
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      buildPackages.gobject-introspection
    ];
    buildInputs = lib.remove gobject-introspection upstream.buildInputs;
    strictDeps = true;
  });

  # out for PR: <https://github.com/NixOS/nixpkgs/pull/263182>
  # hspell = prev.hspell.overrideAttrs (upstream: {
  #   # build perl is needed by the Makefile,
  #   # but $out/bin/multispell (which is simply copied from src) should use host perl
  #   buildInputs = (upstream.buildInputs or []) ++ [ perl ];
  #   postInstall = ''
  #     patchShebangs --update $out/bin/multispell
  #   '';
  # });

  # hyprland = prev.hyprland.overrideAttrs (_: {
  #   depsBuildBuild = [ pkg-config ];
  # });

  # 2024/02/27: upstreaming is blocked on gconf
  # "setup: line 1595: ant: command not found"
  # i2p = mvToNativeInputs [ ant gettext ] prev.i2p;

  # 2024/02/27: upstreaming is unblocked (see `pkgs/patched/ibus`)
  # ibus = (prev.ibus.override {
  #   inherit (emulated)
  #     stdenv # fixes: "configure: error: cannot run test program while cross compiling"
  #     gobject-introspection # "cannot open shared object ..."
  #   ;
  # });
  # .overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs or [] ++ [
  #     glib  # fixes: ImportError: /nix/store/fi1rsalr11xg00dqwgzbf91jpl3zwygi-gobject-introspection-aarch64-unknown-linux-gnu-1.74.0/lib/gobject-introspection/giscanner/_giscanner.cpython-310-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory
  #     buildPackages.gobject-introspection  # fixes "_giscanner.cpython-310-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory"
  #   ];
  #   buildInputs = lib.remove gobject-introspection upstream.buildInputs ++ [
  #     vala  # fixes: "Package `ibus-1.0' not found in specified Vala API directories or GObject-Introspection GIR directories"
  #   ];
  # });
  # ibus = buildInQemu (prev.ibus.override {
  #   # not enough: still tries to execute build machine perl
  #   buildPackages.gtk-doc = gtk-doc;
  # });

  # 2023/12/08: upstreaming is blocked on qtsvg
  iotas = prev.iotas.overrideAttrs (_: {
    # error: "<iotas> is not allowed to refer to the following paths: <build python>"
    # disallowedReferences = [];
    postPatch = ''
      # @PYTHON@ becomes the build python, but this file isn't executable anyway so shouldn't have a shebang
      substituteInPlace iotas/const.py.in \
        --replace '#!@PYTHON@' ""
    '';
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
  #     #     [ zip ]
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

  # jellyfin-media-player = mvToBuildInputs
  #   [ libsForQt5.wrapQtAppsHook ]  # this shouldn't be: but otherwise we get mixed qtbase deps
  #   (prev.jellyfin-media-player.overrideAttrs (upstream: {
  #     meta = upstream.meta // {
  #       platforms = upstream.meta.platforms ++ [
  #         "aarch64-linux"
  #       ];
  #     };
  #   }));
  # jellyfin-media-player-qt6 = prev.jellyfin-media-player-qt6.overrideAttrs (upstream: {
  #   # nativeBuildInputs => result targets x86.
  #   # buildInputs => result targets correct platform, but doesn't wrap the runtime deps
  #   # TODO: fix the hook in qt6 itself?
  #   depsHostHost = upstream.depsHostHost or [] ++ [ qt6.wrapQtAppsHook ];
  #   nativeBuildInputs = lib.remove [ qt6.wrapQtAppsHook ] upstream.nativeBuildInputs;
  # });
  # jellyfin-web = prev.jellyfin-web.override {
  #   # in node-dependencies-jellyfin-web: "node: command not found"
  #   inherit (emulated) stdenv;
  # };

  # 2023/12/08: upstreaming is blocked by qtsvg (pipewire)
  komikku = prev.komikku.overrideAttrs (upstream: {
    # blueprint-compiler runs on the build machine, but tries to load gobject-introspection types meant for the host.
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace data/meson.build --replace \
        "find_program('blueprint-compiler')" \
        "'env', 'GI_TYPELIB_PATH=${buildPackages.gdk-pixbuf.out}/lib/girepository-1.0:${buildPackages.harfbuzz.out}/lib/girepository-1.0:${buildPackages.gtk4.out}/lib/girepository-1.0:${buildPackages.graphene}/lib/girepository-1.0:${buildPackages.libadwaita}/lib/girepository-1.0:${buildPackages.pango.out}/lib/girepository-1.0', find_program('blueprint-compiler')"
    '';
  });

  # koreader = (prev.koreader.override {
  #   # fixes runtime error: luajit: ./ffi/util.lua:757: attempt to call field 'pack' (a nil value)
  #   # inherit (emulated) luajit;
  #   luajit = buildInQemu (luajit.override {
  #     buildPackages.stdenv = emulated.stdenv;  # it uses buildPackages.stdenv for HOST_CC
  #   });
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     autoPatchelfHook
  #   ];
  # });

  lemoa = prev.lemoa.overrideAttrs (upstream:
    let
      rustTargetPlatform = rust.toRustTarget stdenv.hostPlatform;
    in {
      # nixpkgs sets CARGO_BUILD_TARGET to the build platform target, so correct that.
      buildPhase = ''
        runHook preBuild

        mkdir -p target/release
        ln -s ../${rustTargetPlatform}/release/lemoa target/release/lemoa

        ${rust.envVars.setEnv} "CARGO_BUILD_TARGET=${rustTargetPlatform}" ninja -j$NIX_BUILD_CORES

        runHook postBuild
      '';
    }
  );

  # 2024/02/27: upstreaming is unblocked
  #             out for PR: <https://github.com/NixOS/nixpkgs/pull/292415>
  # fixes "proto/meson.build:17:15: ERROR: Failed running '/nix/store/sx2814jd7xim65qbiqry94vkq2b4xv5b-python3-aarch64-unknown-linux-gnu-3.11.7-env/bin/python3', binary or interpreter not executable."
  # source runs python during build only as a sanity check: we could instead disable that.
  # this library is probably only used by xwayland: <https://github.com/NixOS/nixpkgs/pull/280256>
  # it's a dependency of waybar (via sway), but doesn't actually occur in the output!
  # libei = prev.libei.override { python3 = buildPackages.python3; };

  # libgweather = prev.libgweather.overrideAttrs (upstream: {
  #   nativeBuildInputs = (lib.remove gobject-introspection upstream.nativeBuildInputs) ++ [
  #     buildPackages.gobject-introspection  # fails to fix "gi._error.GError: g-invoke-error-quark: Could not locate g_option_error_quark: /nix/store/dsx6kqmyg7f3dz9hwhz7m3jrac4vn3pc-glib-aarch64-unknown-linux-gnu-2.74.3/lib/libglib-2.0.so.0"
  #   ];
  #   # fixes "Run-time dependency vapigen found: NO (tried pkgconfig)"
  #   buildInputs = upstream.buildInputs ++ [ vala ];
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

  # 2024/02/27: upstreaming is blocked on appstream
  # libpanel = prev.libpanel.overrideAttrs (upstream: {
  #   doCheck = false;
  #   # depsBuildBuild = (upstream.depsBuildBuild or []) ++ [
  #   #   # fixes "Build-time dependency gi-docgen found: NO (tried pkgconfig and cmake)"
  #   #   pkg-config
  #   # ];
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     buildPackages.gtk4  # fixes "ERROR: Program 'gtk-update-icon-cache' not found or not executable"
  #   ];
  #   # it can't figure out where gi-docgen lives
  #   mesonFlags = (upstream.mesonFlags or []) ++ [
  #     "-Ddocs=disabled"
  #   ];
  #   outputs = lib.remove "devdoc" upstream.outputs;
  # });

  # libsForQt5 = prev.libsForQt5.overrideScope (self: super: {
  #   qgpgme = super.qgpgme.overrideAttrs (orig: {
  #     # fix so it can find the MOC compiler
  #     # it looks like it might not *need* to propagate qtbase, but so far unclear
  #     nativeBuildInputs = orig.nativeBuildInputs ++ [ self.qtbase ];
  #     propagatedBuildInputs = lib.remove self.qtbase orig.propagatedBuildInputs;
  #   });
  #   phonon = super.phonon.overrideAttrs (orig: {
  #     # fixes "ECM (required version >= 5.60), Extra CMake Modules"
  #     buildInputs = orig.buildInputs ++ [ extra-cmake-modules ];
  #   });
  # });
  # libsForQt5 = prev.libsForQt5.overrideScope (self: super: {
  #   # emulate all the qt5 packages, but rework `libsForQt5.callPackage` and `mkDerivation`
  #   # to use non-emulated stdenv by default.
  #   mkDerivation = self.mkDerivationWith stdenv.mkDerivation;
  #   callPackage = self.newScope { inherit (self) qtCompatVersion qtModule srcs; inherit stdenv; };
  # });

  # 2024/02/27: upstreaming is unblocked, out for PR: <https://github.com/NixOS/nixpkgs/pull/291947>
  #   but i don't think either the pkg-config fix (which breaks binfmt cross) nor disabling docs is the right fix.
  # libshumate = prev.libshumate.overrideAttrs (upstream: {
  #   # fixes "Build-time dependency gi-docgen found: NO (tried pkgconfig and cmake)"
  #   mesonFlags = (upstream.mesonFlags or []) ++ [ "-Dgtk_doc=false" ];
  #   # alternative partial fix, but then it tries to link against the build glib
  #   # depsBuildBuild = (upstream.depsBuildBuild or []) ++ [ pkg-config ];
  # });

  # 2023/12/19: upstreaming blocked on glycin-loaders
  loupe = prev.loupe.overrideAttrs (upstream:
  let
    cargoEnvWrapper = buildPackages.writeShellScript "cargo-env-wrapper" ''
      CARGO_BIN="$1"
      shift
      CARGO_OP="$1"
      shift

      ${rust.envVars.setEnv} "$CARGO_BIN" "$CARGO_OP" --target "${rust.envVars.rustHostPlatformSpec}" "$@"
    '';
  in {
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace src/meson.build \
        --replace "cargo, 'build'," "'${cargoEnvWrapper}', cargo, 'build'," \
        --replace "'src' / rust_target" "'src' / '${rust.envVars.rustHostPlatformSpec}' / rust_target"
    '';
  });

  mepo = (prev.mepo.override {
    # nixpkgs mepo correctly puts `zig_0_11.hook` in nativeBuildInputs,
    # but for some reason that tries to use the host zig instead of the build zig.
    zig_0_11 = buildPackages.zig_0_11;
  }).overrideAttrs (upstream: {
    dontUseZigCheck = true;
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      # zig hardcodes the /lib/ld-linux.so interpreter which breaks nix dynamic linking & dep tracking.
      # this shouldn't have to be buildPackages.autoPatchelfHook...
      # but without specifying `buildPackages` the host coreutils ends up on the builder's path and breaks things
      buildPackages.autoPatchelfHook
      # zig hard-codes `pkg-config` inside lib/std/build.zig
      (buildPackages.writeShellScriptBin "pkg-config" ''
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
  #   zig = (buildPackages.zig.overrideAttrs (upstream: {
  #     cmakeFlags = (upstream.cmakeFlags or []) ++ [
  #       "-DZIG_EXECUTABLE=${buildPackages.zig}/bin/zig"
  #       "-DZIG_TARGET_TRIPLE=aarch64-linux-gnu"
  #       # "-DZIG_MCPU=${targetPlatform.gcc.cpu}"
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
  #   #   zig = zig.override {
  #   #     inherit (emulated) stdenv;
  #   #   };
  #   #   # makeWrapper = makeWrapper.override {
  #   #   #   inherit (emulated) stdenv;
  #   #   # };
  #   #   # makeWrapper = emulated.stdenv.mkDerivation makeWrapper;
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
  #   emulateBuildMachine (callPackage mepoDefn {
  #     upstreamMepo = prev.mepo;
  #     zig = zig.overrideAttrs (upstream: {
  #       # TODO: for zig1 we can actually set ZIG_EXECUTABLE and use the build zig.
  #       # zig2 doesn't support that.
  #       postPatch = (upstream.postPatch or "") + ''
  #         substituteInPlace CMakeLists.txt \
  #           --replace "COMMAND zig1 " "COMMAND ${stdenv.hostPlatform.emulator buildPackages} $PWD/build/zig1 " \
  #           --replace "COMMAND zig2 " "COMMAND ${stdenv.hostPlatform.emulator buildPackages} $PWD/build/zig2 "
  #       '';
  #     });
  #     # zig = emulateBuildMachine (zig.overrideAttrs (upstream: {
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
  #   #   # nativeBuildInputs = [ pkg-config makeWrapper ];
  #   #   # nativeBuildInputs = [ pkg-config emulated.makeWrapper ];
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
  #   nativeBuildInputs = [ pkg-config emulated.makeWrapper ];
  #   # ref to zig by full path because otherwise it doesn't end up on the path...
  #   checkPhase = lib.replaceStrings [ "zig" ] [ "${emulated.zig}/bin/zig" ] upstream.checkPhase;
  #   installPhase = lib.replaceStrings [ "zig" ] [ "${emulated.zig}/bin/zig" ] upstream.installPhase;
  # });
  # mepo = (prev.mepo.override {
  #   inherit (emulated) stdenv;
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = [ pkg-config emulated.makeWrapper ];
  #   buildInputs = [
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

  # fixes: "ar: command not found"
  # `ar` is provided by bintools
  # 2023/07/27: upstreaming is unblocked by deps; but turns out to not be this simple
  ncftp = addNativeInputs [ bintools ] prev.ncftp;
  # fixes "gdbus-codegen: command not found"
  # 2023/07/31: upstreaming is blocked on p11-kit, openfortivpn, qttranslations (qtbase) cross compilation
  # networkmanager-fortisslvpn = mvToNativeInputs [ glib ] prev.networkmanager-fortisslvpn;
  # networkmanager-iodine = prev.networkmanager-iodine.overrideAttrs (orig: {
  #   # fails to fix "configure.ac:58: error: possibly undefined macro: AM_GLIB_GNU_GETTEXT"
  #   nativeBuildInputs = orig.nativeBuildInputs ++ [ gettext ];
  # });
  # networkmanager-iodine = prev.networkmanager-iodine.override {
  #   # fixes "configure.ac:58: error: possibly undefined macro: AM_GLIB_GNU_GETTEXT"
  #   inherit (emulated) stdenv;
  # };
  # networkmanager-iodine = addNativeInputs [ gettext ] prev.networkmanager-iodine;
  # networkmanager-iodine = prev.networkmanager-iodine.overrideAttrs (upstream: {
  #   # buildInputs = upstream.buildInputs ++ [ intltool gettext ];
  #   # nativeBuildInputs = lib.remove intltool upstream.nativeBuildInputs;
  #   # nativeBuildInputs = upstream.nativeBuildInputs ++ [ gettext ];
  #   postPatch = upstream.postPatch or "" + ''
  #     sed -i s/AM_GLIB_GNU_GETTEXT/AM_GNU_GETTEXT/ configure.ac
  #   '';
  # });

  # fixes "gdbus-codegen: command not found"
  # fixes "gtk4-builder-tool: command not found"
  # 2023/07/31: upstreaming is unblocked,implemented
  # networkmanager-l2tp = addNativeInputs [ gtk4 ]
  #   (mvToNativeInputs [ glib ] prev.networkmanager-l2tp);
  # fixes "properties/gresource.xml: Permission denied"
  #   - by providing glib-compile-resources
  # 2023/07/31: upstreaming is blocked on libavif cross compilation
  # networkmanager-openconnect = mvToNativeInputs [ glib ] prev.networkmanager-openconnect;
  # fixes "properties/gresource.xml: Permission denied"
  #   - by providing glib-compile-resources
  # 2023/07/31: upstreaming is unblocked,implemented
  # networkmanager-openvpn = mvToNativeInputs [ glib ] prev.networkmanager-openvpn;
  # 2023/07/31: upstreaming is unblocked,implemented
  # networkmanager-sstp = (
  #   # fixes "gdbus-codegen: command not found"
  #   mvToNativeInputs [ glib ] (
  #     # fixes gtk4-builder-tool wrong format
  #     addNativeInputs [ gtk4.dev ] prev.networkmanager-sstp
  #   )
  # );
  # 2023/07/31: upstreaming is blocked on vpnc cross compilation
  # networkmanager-vpnc = mvToNativeInputs [ glib ] prev.networkmanager-vpnc;
  # fixes "properties/gresource.xml: Permission denied"
  #   - by providing glib-compile-resources
  # 2023/07/27: upstreaming is blocked on p11-kit, coeurl cross compilation
  # nheko = (prev.nheko.override {
  #   gst_all_1 = gst_all_1 // {
  #     # don't build gst-plugins-good with "qt5 support"
  #     # alternative build fix is to remove `qtbase` from nativeBuildInputs:
  #     # - that avoids the mixd qt5 deps, but forces a rebuild of gst-plugins-good and +20MB to closure
  #     gst-plugins-good.override = attrs: gst_all_1.gst-plugins-good.override (builtins.removeAttrs attrs [ "qt5Support" ]);
  #   };
  # }).overrideAttrs (orig: {
  #   # fixes "fatal error: lmdb++.h: No such file or directory
  #   buildInputs = orig.buildInputs ++ [ lmdbxx ];
  # });
  # 2023/08/02: upstreaming in PR: <https://github.com/NixOS/nixpkgs/pull/225111/files>
  # - needs (my) review
  # notmuch = prev.notmuch.overrideAttrs (upstream: {
  #   # fixes "Error: The dependencies of notmuch could not be satisfied"  (xapian, gmime, glib, talloc)
  #   # when cross-compiling, we only have a triple-prefixed pkg-config which notmuch's configure script doesn't know how to find.
  #   # so just replace these with the nix-supplied env-var which resolves to the relevant pkg-config.
  #   postPatch = upstream.postPatch or "" + ''
  #     sed -i 's/pkg-config/\$PKG_CONFIG/g' configure
  #   '';
  #   XAPIAN_CONFIG = buildPackages.writeShellScript "xapian-config" ''
  #     exec ${lib.getBin xapian}/bin/xapian-config $@
  #   '';
  #   # depsBuildBuild = [ gnupg ];
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     gnupg  # nixpkgs specifies gpg as a buildInput instead of a nativeBuildInput
  #     perl  # used to build manpages
  #     # pythonPackages.python
  #     # shared-mime-info
  #   ];
  #   buildInputs = [
  #     xapian gmime3 talloc zlib  # dependencies described in INSTALL
  #     # perl
  #     # pythonPackages.python
  #     ruby  # notmuch links against ruby.so
  #   ];
  #   # buildInputs =
  #   #   (lib.remove
  #   #     perl
  #   #     (lib.remove
  #   #       gmime
  #   #       (lib.remove gnupg upstream.buildInputs)
  #   #     )
  #   #   ) ++ [ gmime ];
  # });
  # notmuch = prev.notmuch.overrideAttrs (upstream: {
  #   # fixes "Error: The dependencies of notmuch could not be satisfied"  (xapian, gmime, glib, talloc)
  #   # when cross-compiling, we only have a triple-prefixed pkg-config which notmuch's configure script doesn't know how to find.
  #   # so just replace these with the nix-supplied env-var which resolves to the relevant pkg-config.
  #   postPatch = upstream.postPatch or "" + ''
  #     sed -i 's/pkg-config/\$PKG_CONFIG/g' configure
  #     sed -i 's: gpg : ${buildPackages.gnupg}/bin/gpg :' configure
  #   '';
  #   XAPIAN_CONFIG = buildPackages.writeShellScript "xapian-config" ''
  #     exec ${lib.getBin xapian}/bin/xapian-config $@
  #   '';
  #   # depsBuildBuild = upstream.depsBuildBuild or [] ++ [
  #   #   buildPackages.stdenv.cc
  #   # ];
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     # gnupg
  #     perl
  #   ];
  #   # buildInputs = lib.remove gnupg upstream.buildInputs;
  # });

  # openfortivpn = prev.openfortivpn.override {
  #   # fixes "checking for /proc/net/route... configure: error: cannot check for file existence when cross compiling"
  #   inherit (emulated) stdenv;
  # };

  # fixes (meson) "Program 'glib-mkenums mkenums' not found or not executable"
  # 2023/07/27: upstreaming is blocked on p11-kit, argyllcms, libavif cross compilation
  # phoc = mvToNativeInputs [ wayland-scanner glib ] prev.phoc;
  # phosh = prev.phosh.overrideAttrs (upstream: {
  #   buildInputs = upstream.buildInputs ++ [
  #     libadwaita  # "plugins/meson.build:41:2: ERROR: Dependency "libadwaita-1" not found, tried pkgconfig"
  #   ];
  #   mesonFlags = upstream.mesonFlags ++ [
  #     "-Dphoc_tests=disabled"  # "tests/meson.build:20:0: ERROR: Program 'phoc' not found or not executable"
  #   ];
  #   # postPatch = upstream.postPatch or "" + ''
  #   #   sed -i 's:gio_querymodules = :gio_querymodules = "${buildPackages.glib.dev}/bin/gio-querymodules" if True else :' build-aux/post_install.py
  #   # '';
  # });
  # phosh-mobile-settings = mvInputs {
  #   # fixes "meson.build:26:0: ERROR: Dependency "phosh-plugins" not found, tried pkgconfig"
  #   # phosh is used only for its plugins; these are specified as a runtime dep in src.
  #   # it's correct for them to be runtime dep: src/ms-lockscreen-panel.c loads stuff from
  #   buildInputs = [ phosh ];
  #   nativeBuildInputs = [
  #     gettext  # fixes "data/meson.build:1:0: ERROR: Program 'msgfmt' not found or not executable"
  #     wayland-scanner  # fixes "protocols/meson.build:7:0: ERROR: Program 'wayland-scanner' not found or not executable"
  #     glib  # fixes "src/meson.build:1:0: ERROR: Program 'glib-mkenums mkenums' not found or not executable"
  #     desktop-file-utils  # fixes "meson.build:116:8: ERROR: Program 'update-desktop-database' not found or not executable"
  #   ];
  # } prev.phosh-mobile-settings;

  # pipewire = prev.pipewire.override {
  #   # avoid a dep on python3.10-PyQt5, which has mixed qt5 versions.
  #   # this means we lose firewire support (oh well..?)
  #   ffadoSupport = false;
  # };

  # psqlodbc = prev.psqlodbc.override {
  #   # fixes "configure: error: odbc_config not found (required for unixODBC build)"
  #   inherit (emulated) stdenv;
  # };

  # 2023/12/13: upstreaming is blocked by qtsvg (via pipewire)
  pwvucontrol = prev.pwvucontrol.overrideAttrs (upstream:
  let
    rustTargetPlatform = rust.toRustTarget stdenv.hostPlatform;
  in {
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace src/meson.build --replace \
        "'src' / rust_target" \
        "'src' / '${rustTargetPlatform}' / rust_target"
    '';
    # nixpkgs sets CARGO_BUILD_TARGET to the build platform target, so correct that.
    buildPhase = ''
      runHook preBuild

      ${rust.envVars.setEnv} "CARGO_BUILD_TARGET=${rustTargetPlatform}" ninja -j$NIX_BUILD_CORES

      runHook postBuild
    '';
  });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (py-final: py-prev: {
      # 2024/02/27: upstreaming is unblocked  (eyeD3 is a dep of gpodder)
      eyed3 = py-prev.eyed3.overrideAttrs (orig: {
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
      # skia-pathops = ?
      #   it tries to call `cc` during the build, but can't find it.
    })
  ];

  # qt5 = let
  #   emulatedQt5 = prev.qt5.override {
  #     # emulate qt5base and all qtModules.
  #     # because qt5 doesn't place this `stdenv` argument into its scope, `libsForQt5` doesn't inherit
  #     # this stdenv. so anything using `libsForQt5.callPackage` builds w/o emulation.
  #     stdenv = stdenv // {
  #       mkDerivation = args: buildInQemu {
  #         override = { stdenv }: stdenv.mkDerivation args;
  #       };
  #     };
  #   };
  # in prev.qt5.overrideScope (self: super: {
  #   inherit (emulatedQt5)
  #     qtbase
  #     # without emulation these all fail with "Project ERROR: Cannot run compiler 'g++'."
  #     qtdeclarative
  #     qtgraphicaleffects
  #     qtimageformats
  #     qtmultimedia
  #     qtquickcontrols
  #     qtquickcontrols2
  #     qtsvg
  #     qttools
  #     qtwayland
  #   ;
  # });

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
  #   stdenv = stdenv // {
  #     mkDerivation = args: buildInQemu {
  #       override = { stdenv }: stdenv.mkDerivation args;
  #     };
  #   };
  #   # callPackage/mkDerivation is used by libsForQt5, so we avoid emulating qt consumers.
  #   # mkDerivation = stdenv.mkDerivation;
  #   # callPackage = self.newScope {
  #   #   inherit (self) qtCompatVersion qtModule srcs;
  #   #   inherit stdenv;
  #   # };

  #   # qtbase = buildInQemu super.qtbase;
  # });
  # libsForQt5 = prev.libsForQt5.overrideScope (self: super: {
  #   inherit stdenv;
  #   inherit (self.stdenv) mkderivation;
  # });

  # qt5 = (prev.qt5.override {
  #   # qt5 modules see this stdenv; they don't pick up the scope's qtModule or stdenv
  #   stdenv = emulated.stdenv // {
  #     # mkDerivation = args: buildInQemu (stdenv.mkDerivation args);
  #     mkDerivation = args: buildInQemu {
  #       # clunky buildInQemu API, when not used via `callPackage`
  #       override = _attrs: stdenv.mkDerivation args;
  #     };
  #   };
  # }).overrideScope (self: super: {
  #   # but for anything using `libsForQt5.callPackage`, don't emulate.
  #   # note: alternative approach is to only `libsForQt5` (it's a separate scope),.
  #   # it inherits so much from the `qt5` scope, so not a clear improvement.
  #   mkDerivation = self.mkDerivationWith stdenv.mkDerivation;
  #   callPackage = self.newScope { inherit (self) qtCompatVersion qtModule srcs; inherit stdenv; };
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
  #   mkDerivation = self.mkDerivationWith stdenv.mkDerivation;
  #   callPackage = self.newScope { inherit (self) qtCompatVersion qtModule srcs; inherit stdenv; };
  # });
  # qt6 = prev.qt6.overrideScope (self: super: {
  #   # # inherit (emulated.qt6) qtModule;
  #   # qtbase = super.qtbase.overrideAttrs (upstream: {
  #   #   # cmakeFlags = upstream.cmakeFlags ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
  #   #   cmakeFlags = upstream.cmakeFlags ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
  #   #     # "-DCMAKE_CROSSCOMPILING=True" # fails to solve QT_HOST_PATH error
  #   #     "-DQT_HOST_PATH=${buildPackages.qt6.full}"
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
  #     # depsBuildBuild = upstream.depsBuildBuild or [] ++ [ pkg-config ];
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
  #       export NIX_LDFLAGS_x86_64_unknown_linux_gnu="-L${buildPackages.zlib}/lib"
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
  #       bintools-unwrapped  # for readelf
  #       buildPackages.cups  # for cups-config
  #       buildPackages.fontconfig
  #       buildPackages.glib
  #       buildPackages.harfbuzz
  #       buildPackages.icu
  #       buildPackages.libjpeg
  #       buildPackages.libpng
  #       buildPackages.libwebp
  #       buildPackages.nss
  #       # gcc-unwrapped.libgcc  # for libgcc_s.so
  #       buildPackages.zlib
  #     ];
  #     depsBuildBuild = upstream.depsBuildBuild or [] ++ [ pkg-config ];
  #     # buildInputs = upstream.buildInputs ++ [
  #     #   gcc-unwrapped.libgcc  # for libgcc_s.so. this gets loaded during build, suggesting i surely messed something up
  #     # ];
  #     # buildInputs = upstream.buildInputs ++ [
  #     #   gcc-unwrapped.libgcc
  #     # ];
  #     # nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     #   icu
  #     # ];
  #     # buildInputs = upstream.buildInputs ++ [
  #     #   icu
  #     # ];
  #     # env.NIX_DEBUG="1";
  #     # env.NIX_DEBUG="7";
  #     # cmakeFlags = lib.remove "-DQT_FEATURE_webengine_system_icu=ON" upstream.cmakeFlags;
  #     cmakeFlags = upstream.cmakeFlags ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
  #       # "--host-cc=${buildPackages.stdenv.cc}/bin/cc"
  #       # "--host-cxx=${buildPackages.stdenv.cc}/bin/c++"
  #       # these are my own vars, used by my own patch
  #       "-DCMAKE_HOST_C_COMPILER=${buildPackages.stdenv.cc}/bin/gcc"
  #       "-DCMAKE_HOST_CXX_COMPILER=${buildPackages.stdenv.cc}/bin/g++"
  #       "-DCMAKE_HOST_AR=${buildPackages.stdenv.cc}/bin/ar"
  #       "-DCMAKE_HOST_NM=${buildPackages.stdenv.cc}/bin/nm"
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
      PYTHON = python3.interpreter;
    };
  });

  # samba = prev.samba.overrideAttrs (_upstream: {
  #   # we get "cannot find C preprocessor: aarch64-unknown-linux-gnu-cpp", but ONLY when building with the ccache stdenv.
  #   # this solves that, but `CPP` must be a *single* path -- not an expression.
  #   # i do not understand how the original error arises, as my ccacheStdenv should match the API of the base stdenv (except for cpp being a symlink??).
  #   # but oh well, this fixes it.
  #   CPP = buildPackages.writeShellScript "cpp" ''
  #     exec ${lib.getBin stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc -E $@;
  #   '';
  # });

  # sequoia = prev.sequoia.override {
  #   # fails to fix original error
  #   inherit (emulated) stdenv;
  # };

  # 2023/12/19: upstreaming is blocked by qtsvg (via pipewire)
  spot = prev.spot.overrideAttrs (upstream:
    let
      rustTargetPlatform = rust.toRustTarget stdenv.hostPlatform;
    in {
      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace build-aux/cargo.sh --replace \
          'OUTPUT_BIN="$CARGO_TARGET_DIR"' \
          'OUTPUT_BIN="$CARGO_TARGET_DIR/${rustTargetPlatform}"'
      '';
      # nixpkgs sets CARGO_BUILD_TARGET to the build platform target, so correct that.
      buildPhase = ''
        runHook preBuild

        ${rust.envVars.setEnv} "CARGO_BUILD_TARGET=${rustTargetPlatform}" ninja -j$NIX_BUILD_CORES

        runHook postBuild
      '';
    }
  );

  # squeekboard = prev.squeekboard.overrideAttrs (upstream: {
  #   # fixes: "meson.build:1:0: ERROR: 'rust' compiler binary not defined in cross or native file"
  #   # new error: "meson.build:1:0: ERROR: Rust compiler rustc --target aarch64-unknown-linux-gnu -C linker=aarch64-unknown-linux-gnu-gcc can not compile programs."
  #   # NB(2023/03/04): upstream nixpkgs has a new squeekboard that's closer to cross-compiling; use that
  #   # NB(2023/08/24): this emulates the entire rust build process
  #   mesonFlags =
  #     let
  #       # ERROR: 'rust' compiler binary not defined in cross or native file
  #       crossFile = writeText "cross-file.conf" ''
  #         [binaries]
  #         rust = [ 'rustc', '--target', '${rust.toRustTargetSpec stdenv.hostPlatform}' ]
  #       '';
  #     in
  #       # upstream.mesonFlags or [] ++
  #       [
  #         "-Dtests=false"
  #         "-Dnewer=true"
  #         "-Donline=false"
  #       ]
  #       ++ lib.optional
  #         (stdenv.hostPlatform != stdenv.buildPlatform)
  #         "--cross-file=${crossFile}"
  #       ;

  #   # cargoDeps = null;
  #   # cargoVendorDir = "vendor";

  #   # depsBuildBuild = (upstream.depsBuildBuild or []) ++ [
  #   #   pkg-config
  #   # ];
  #   # this is identical to upstream, but somehow build fails if i remove it??
  #   nativeBuildInputs = [
  #     meson
  #     ninja
  #     pkg-config
  #     glib
  #     wayland
  #     rustPlatform.cargoSetupHook
  #     cargo
  #     rustc
  #   ];
  # });

  # 2023/12/08: upstreaming is blocked by qtsvg (via pipewire)
  tangram = prev.tangram.overrideAttrs (upstream: {
    # blueprint-compiler runs on the build machine, but tries to load gobject-introspection types meant for the host.
    # additionally, gsjpack has a shebang for the host gjs. patchShebangs --build doesn't fix that: just manually specify the build gjs
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace src/meson.build \
        --replace "find_program('gjs').full_path()" "'${gjs}/bin/gjs'" \
        --replace "gjspack," "'env', 'GI_TYPELIB_PATH=${buildPackages.gdk-pixbuf.out}/lib/girepository-1.0:${buildPackages.harfbuzz.out}/lib/girepository-1.0:${buildPackages.gtk4.out}/lib/girepository-1.0:${buildPackages.graphene}/lib/girepository-1.0:${buildPackages.libadwaita}/lib/girepository-1.0:${buildPackages.pango.out}/lib/girepository-1.0', '${buildPackages.gjs}/bin/gjs', '-m', gjspack,"

    '';
  });

  # fixes: "ar: command not found"
  # `ar` is provided by bintools
  # 2024/02/27: upstreaming is blocked on gnustep-base cross compilation
  unar = addNativeInputs [ bintools ] prev.unar;
  # unixODBCDrivers = prev.unixODBCDrivers // {
  #   # TODO: should this package be deduped with toplevel psqlodbc in upstream nixpkgs?
  #   psql = prev.unixODBCDrivers.psql.overrideAttrs (_upstream: {
  #     # XXX: these are both available as configureFlags, if we prefer that (we probably do, so as to make them available only during specific parts of the build).
  #     ODBC_CONFIG = buildPackages.writeShellScript "odbc_config" ''
  #       exec ${stdenv.hostPlatform.emulator buildPackages} ${unixODBC}/bin/odbc_config $@
  #     '';
  #     PG_CONFIG = buildPackages.writeShellScript "pg_config" ''
  #       exec ${stdenv.hostPlatform.emulator buildPackages} ${postgresql}/bin/pg_config $@
  #     '';
  #   });
  # };

  # fixes: "Run-time dependency scdoc found: NO (tried pkgconfig)"
  unl0kr = prev.unl0kr.overrideAttrs (upstream: {
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace meson.build \
        --replace "scdoc = dependency('scdoc')" "" \
        --replace "scdoc.get_pkgconfig_variable('scdoc')" "'scdoc'"
    '';
  });

  # visidata = prev.visidata.override {
  #   # hdf5 / h5py don't cross-compile, but i don't use that file format anyway.
  #   # setting this to null means visidata will work as normal but not be able to load hdf files.
  #   h5py = null;
  # };
  # vlc = prev.vlc.overrideAttrs (orig: {
  #   # 2023/11/21: upstreaming is blocked on qtsvg, qtx11extras
  #   # fixes: "configure: error: could not find the LUA byte compiler"
  #   # fixes: "configure: error: protoc compiler needed for chromecast was not found"
  #   nativeBuildInputs = orig.nativeBuildInputs ++ [ lua5 protobuf ];
  #   # fix that it can't find the c compiler
  #   # makeFlags = orig.makeFlags or [] ++ [ "CC=${prev.stdenv.cc.targetPrefix}cc" ];
  #   env = orig.env // {
  #     BUILDCC = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";
  #   };
  # });

  # fixes "perl: command not found"
  # 2023/07/30: upstreaming is unblocked, but requires alternative fix
  # - i think the build script tries to run the generated binary?
  # vpnc = mvToNativeInputs [ perl ] prev.vpnc;

  # 2023/11/21: upstreaming is blocked on flatpak
  xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (upstream: {
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      # fixes "meson.build:117:8: ERROR: Program 'bwrap' not found or not executable"
      bubblewrap
    ]; # ++ upstream.nativeCheckInputs;
    mesonFlags = (upstream.mesonFlags or []) ++ [
      # fixes "tests/meson.build:268:9: ERROR: Program 'pytest-3 pytest' not found or not executable"
      # nixpkgs should add this whenever doCheck == false, i think
      "-Dpytest=disabled"
    ];
  });
  # fixes "No package 'xdg-desktop-portal' found"
  # 2023/12/08: upstreaming is blocked on argyllcms, flatpak, qtsvg (via pipewire/ffado)
  xdg-desktop-portal-gtk = mvToBuildInputs [ xdg-desktop-portal ] prev.xdg-desktop-portal-gtk;
  # fixes: "data/meson.build:33:5: ERROR: Program 'msgfmt' not found or not executable"
  # fixes: "src/meson.build:25:0: ERROR: Program 'gdbus-codegen' not found or not executable"
  # 2023/07/27: upstreaming is blocked on p11-kit cross compilation
  xdg-desktop-portal-gnome = (
    addNativeInputs [ wayland-scanner ] (
      mvToNativeInputs [ gettext glib ] prev.xdg-desktop-portal-gnome
    )
  );

  # 2024/02/27: upstreaming is blocked on wlroots-hyprland (libei)
  #             out for PR: <https://github.com/NixOS/nixpkgs/pull/292415>
  # waybar = (prev.waybar.override {
  #   runTests = false;  #< upstream expects `catch2_3` as a runtime requirement
  #   hyprlandSupport = false;  # doesn't cross compile
  #   # fixes: "/nix/store/sc1pz0zaqwpai24zh7xx0brjinflmc6v-aarch64-unknown-linux-gnu-binutils-2.40/bin/aarch64-unknown-linux-gnu-ld: /nix/store/ghxl1zrfnvh69dmv7xa1swcbyx06va4y-wayland-1.22.0/lib/libwayland-client.so: error adding symbols: file in wrong format"
  #   wrapGAppsHook = wrapGAppsNoGuiHook;
  # }).overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     buildPackages.wayland-scanner
  #     (makeShellWrapper.overrideAttrs (_: {
  #       # else it tries to invoke the host CC compiler (??)
  #       shell = runtimeShell;
  #     }))
  #   ];
  #   # buildInputs = upstream.buildInputs ++ [ catch2_3 ];  #< either this or override `runTests = false`
  #   mesonFlags = upstream.mesonFlags ++ [
  #     # fixes "Dependency lookup for scdoc with method 'pkgconfig' failed: Pkg-config binary for machine 0 not found. Giving up."
  #     "-Dman-pages=disabled"
  #   ];
  # });
  # waybar = (prev.waybar.override { runTests = false; }).overrideAttrs (upstream: {
  #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
  #     wayland-scanner
  #   ];
  #   strictDeps = true;
  # });

  webkitgtk = prev.webkitgtk.overrideAttrs (upstream: {
    # fixes "wayland-scanner: line 5: syntax error: unterminated quoted string"
    # also: `/nix/store/nnnn-wayland-aarch64-unknown-linux-gnu-1.22.0-bin/bin/wayland-scanner: line 0: syntax error: unexpected word (expecting ")")`
    # verbose error:
    #   [6376/6819] Generating ../../WebKitGTK/DerivedSources/pointer-constraints-unstable-v1-protocol.c
    #   FAILED: WebKitGTK/DerivedSources/pointer-constraints-unstable-v1-protocol.c /build/webkitgtk-2.40.5/build/WebKitGTK/DerivedSources/pointer-constraints-unstable-v1-protocol.c 
    #   cd /build/webkitgtk-2.40.5/build/Source/WebKit && /nix/store/6xbpap00kkdgrayizbc61mzf19ygsp9j-wayland-aarch64-unknown-linux-gnu-1.22.0-bin/bin/wayland-scanner private-code //nix/store/26nypvflsc8ggbdkns0wjvh4mjrj>
    #   /nix/store/6xbpap00kkdgrayizbc61mzf19ygsp9j-wayland-aarch64-unknown-linux-gnu-1.22.0-bin/bin/wayland-scanner: line 5: syntax error: unterminated quoted string
    # with this i can maybe remove `wayland` from nativeBuildInputs, too?
    # note that `webkitgtk` != `webkitgtk_6_0`, so this patch here might be totally unnecessary.
    # 2023/11/06: hostPkgs.moby.webkitgtk_6_0 builds fine on servo; stock pkgsCross.aarch64-multiplatform.webkitgtk_6_0 does not.
    # 2023/11/06: out for PR: <https://github.com/NixOS/nixpkgs/pull/265968>
    cmakeFlags = upstream.cmakeFlags ++ [
      "-DWAYLAND_SCANNER=${buildPackages.wayland-scanner}/bin/wayland-scanner"
    ];
  });
  # webkitgtk = prev.webkitgtk.override { stdenv = ccacheStdenv; };

  # 2024/02/27: upstreaming is unblocked
  webp-pixbuf-loader = prev.webp-pixbuf-loader.overrideAttrs (upstream: {
    # fixes: "Builder called die: Cannot wrap '/nix/store/kpp8qhzdjqgvw73llka5gpnsj0l4jlg8-gdk-pixbuf-aarch64-unknown-linux-gnu-2.42.10/bin/gdk-pixbuf-thumbnailer' because it is not an executable file"
    # gdk-pixbuf doesn't create a `bin/` directory when cross-compiling, breaks some thumbnailing stuff.
    # - gnome's gdk-pixbuf *explicitly* doesn't build thumbnailer on cross builds
    # see `librsvg` for a more bullet-proof cross-compilation approach
    postInstall = "";
  });
  # XXX: aarch64 webp-pixbuf-loader wanted by gdk-pixbuf-loaders.cache.drv, wanted by aarch64 gnome-control-center

  # 2023/12/08: upstreaming is blocked by qtsvg (via pipewire)
  wike = prev.wike.overrideAttrs (upstream: {
    # error: "<wike> is not allowed to refer to the following paths: <build python>"
    # wike's meson build script sets host binaries to use build PYTHON
    # disallowedReferences = [];
    postFixup = (upstream.postFixup or "") + ''
      patchShebangs --update $out/share/wike/wike-sp
    '';
  });

  # 2024/02/29: upstreaming is blocked on libei (unless Xwayland config option is disabled in nixpkgs)
  #             out for PR: <https://github.com/NixOS/nixpkgs/pull/292415>
  wlroots = prev.wlroots.overrideAttrs (upstream: {
    nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
      # incorrectly specified as `buildInputs` in nixpkgs.
      hwdata
    ];
  });

  # wrapFirefox = prev.wrapFirefox.override {
  #   buildPackages = buildPackages // {
  #     # fixes "extract-binary-wrapper-cmd: line 2: strings: command not found"
  #     # ^- in the `nix log` output of cross-compiled `firefox` (it's non-fatal)
  #     makeBinaryWrapper = bpkgs.makeBinaryWrapper.overrideAttrs (upstream: {
  #       passthru.extractCmd = bpkgs.writeShellScript "extract-binary-wrapper-cmd" ''
  #         ${stdenv.cc.targetPrefix}strings -dw "$1" | sed -n '/^makeCWrapper/,/^$/ p'
  #       '';
  #     });
  #   };
  # };

  wrapNeovimUnstable = neovim: config: (prev.wrapNeovimUnstable neovim config).overrideAttrs (upstream: {
    # nvim wrapper has a sanity check that the plugins will load correctly.
    # this is effectively a check phase and should be rewritten as such
    postBuild = lib.replaceStrings
      [ "! $out/bin/nvim-wrapper" ]
      # [ "${stdenv.hostPlatform.emulator buildPackages} $out/bin/nvim-wrapper" ]
      [ "false && $out/bin/nvim-wrapper" ]
      upstream.postBuild;
  });

  # 2023/07/30: upstreaming is blocked on unar (gnustep), unless i also make that optional
  xarchiver = mvToNativeInputs [ libxslt ] prev.xarchiver;

  xdg-utils = let
    buildResholve = buildPackages.resholve.overrideAttrs (resholve': {
      meta = (resholve'.meta or { }) // { knownVulnerabilities = [ ]; };
    });
  in (prev.xdg-utils.override {
    resholve = buildResholve;
  }).overrideAttrs (xdg-utils': let
      patchedResholve = buildResholve.overrideAttrs (resholve': {
        # resholve tries to exec `sed` and `awk`. this triggers inscrutable python2.7-specific errors.
        postPatch = (resholve'.postPatch or "") + ''
          substituteInPlace  resholve \
            --replace-fail 'p = Popen(' 'return False; p = Popen('
        '';
      });
    in {
      # postPatch = (xdg-utils'.postPatch or "") + ''
      #   substituteInPlace scripts/xdg-screensaver.in \
      #     --replace-fail 'lockfile_command=`command -v lockfile`' 'lockfile_command='
      # '';

      # have to patch all `resholve` invocations AGAIN because even though `buildPackages.resholve` is the right architecture now,
      # the `resholve` passthru args refer to itself, in a way which `overrideAttrs` can't patch.
      # also, xdg-screensaver resholve fails because `perl -e` is treated differently on native v.s. cross,
      # so "fake" it as external and then manually patch it (resholve has a better way to do that, but not easily patchable from here).
      preFixup = (lib.replaceStrings
        [ "${buildResholve}/bin/resholve" "RESHOLVE_FAKE='external:" ]
        [ "${patchedResholve}/bin/resholve" "RESHOLVE_FAKE='external:perl;" ]
        xdg-utils'.preFixup) + ''
        substituteInPlace $out/bin/xdg-screensaver \
          --replace-fail '  perl -e' '  ${perl}/bin/perl -e'
      '';
    }
  );
}
