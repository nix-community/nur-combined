# cross compiling
#
# terminology:
# - buildPlatform is the machine on which a compiler is run.
# - hostPlatform is the machine on which a built package is run.
# - targetPlatform is used only by compilers which aren't multi-output.
#   - specifies the platform for which a compiler will produce binaries after that compiler is built.
#
# - for edge-casey things, see in nixpkgs:
#   - `git show da9a9a440415b236f22f57ba67a24ab3fb53f595`
#     - e.g. `mesonEmulatorHook`, `depsBuildBuild`, `python3.pythonForBuild`
#   - <doc/stdenv/cross-compilation.chapter.md>
#     - e.g. `makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];`
#   - <nixpkgs:pkgs/development/libraries/gdk-pixbuf/default.nix>
#     - `${stdenv.hostPlatform.emulator buildPackages}   <command>`
#       - to run code compiled for host platform
#   - `override { foo = next.emptyDirectory; }`
#     - to populate some dep as a dummy, if you don't really need it
# - for optimizing, see:
#   - ccache
#   - disable LTO (e.g. webkitgtk)
#
# build a particular package as evaluated here with:
# - toplevel: `nix build '.#host-pkgs.moby-cross.xdg-utils'`
# - scoped:   `nix build '.#host-pkgs.moby-cross.gnome.mutter'`
# - python:   `nix build '.#host-pkgs.moby-cross.python310Packages.pandas'`
# - perl:     `nix build '.#host-pkgs.moby-cross.perl536Packages.ModuleBuild'`
# - qt:       `nix build '.#host-pkgs.moby-cross.qt5.qtbase'`
# - qt:       `nix build '.#host-pkgs.moby-cross.libsForQt5.phonon'`
# most of these can be built in a nixpkgs source root like:
# - `nix build '.#pkgsCross.aarch64-multiplatform.xdg-utils'`
# - `nix build '.#pkgsCross.gnu64.xdg-utils'`  # for x86_64-linux
#
# tracking issues, PRs:
# - libuv tests fail: <https://github.com/NixOS/nixpkgs/issues/190807>
#   - last checked: 2023-02-07
#   - opened: 2022-09-11
# - perl Module Build broken: <https://github.com/NixOS/nixpkgs/issues/66741>
#   - last checked: 2023-02-07
#   - opened: 2019-08
#   - ModuleBuild needs access to `Scalar/Utils.pm`, which doesn't *seem* to exist in the cross builds
#     - this can be fixed by adding `nativeBuildInputs = [ perl ]` to it
#     - alternatively, there's some "stubbing" method mentioned in <pkgs/development/interpreters/perl/default.nix>
#       - stubbing documented at bottom: <nixpkgs:doc/languages-frameworks/perl.section.md>
#
# - perl536Packages.Testutf8 fails to cross: <https://github.com/NixOS/nixpkgs/issues/198548>
#   - last checked: 2023-02-07
#   - opened: 2022-10
# - python310Packages.psycopg2: <https://github.com/NixOS/nixpkgs/issues/210265>
#   - last checked: 2023-02-06
#   - i have a potential fix:
#     """
#       i was able to just add `postgresql` to the `buildInputs`  (so that it's in both `buildInputs` and `nativeBuildInputs`):
#       it fixed the build for `pkgsCross.aarch64-multiplatform.python310Packages.psycopg2` but not for `armv7l-hf-multiplatform` that this issue description calls out.
#
#       also i haven't deployed it yet to make sure this doesn't cause anything funky at runtime though.
#     """

# TODO:
# - emulated `stdenv`:
#   - qchem overrides stdenv.mkDerivation:
#     <nur-combined:repos/qchem/default.nix>
# - fix(journalctl) "gnome-terminal-server[126562]: Installed schemas failed verification: Schema "org.gtk.Settings.Debug" is missing"
# - fix firefox build so that it doesn't invoke clang w/o the ccache
# - qt6.qtbase. cross compiling documented in upstream <qt6:qtbase/cmake/README.md>
#   - `nix build '.#host-pkgs.moby.qgnomeplatform-qt6'` FAILS
#   - `nix build '.#host-pkgs.moby.qt6Packages.qtwayland'` FAILS
#     - it uses qmake in nativeBuildInputs  (but `.#host-pkgs.moby.buildPackages.qt6.qmake` builds, same with native qtbase...)
#     - failed version build log truly doesn't have the `QT_HOST_PATH` flag.
#
# - `host-pkgs.cross-desko.stdenv` fails build:
#   - #cross-compiling:nixos.org says pkgsCross.gnu64 IS KNOWN TO NOT COMPILE. let this go for now:

# Nixpkgs PR tracker:
# - 2023/04/12 (gst_all_1): https://github.com/NixOS/nixpkgs/pull/225664
# - 2023/04/12 (subversion,serf,apr-util,pam_mount): https://github.com/NixOS/nixpkgs/pull/225977

{ config, lib, options, pkgs, ... }:

let
  inherit (lib) types mkIf mkOption;
  cfg = config.sane.cross;
  # "universal" overlay means it applies to all package sets:
  # - cross
  # - emulated
  # - any arch; etc
  # these are specified for the primary package set in flake.nix,
  # except for the "cross only" universal overlays which we avoid specifying for non-cross builds
  # because they don't affect the result -- only the build process -- so we can disable them as an optimization.
  crossOnlyUniversalOverlays = [
    (import ./../../../overlays/optimizations.nix)
  ];
  universalOverlays = [
    (import ./../../../overlays/disable-flakey-tests.nix)
    (import ./../../../overlays/pkgs.nix)
    (import ./../../../overlays/pins.nix)
  ] ++ crossOnlyUniversalOverlays;

  # from a cross-compiled package set, build a package set that builds from the host for the host.
  # this forces an emulated build, or for the build to be run on a host-like machine.
  # nix emulates using binfmt -- which is impure and has to be configured externally.
  mkEmulated = pkgs:
    import pkgs.path {
      # system = pkgs.stdenv.hostPlatform.system;
      localSystem = pkgs.stdenv.hostPlatform.system;
      inherit (config.nixpkgs) config;
      # config = builtins.removeAttrs config.nixpkgs.config [ "replaceStdenv" ];
      overlays = universalOverlays;
    };

  # attempts to build emulated package sets without binfmt, using userland qemu instead.
  # it fails, notably because bash running under qemu-aarch64 spawns x86_64 binaries when it shells out.
  # i.e. qemu doesn't wrap syscalls like `exec`.
  # mkEmulated = pkgs':
  #   import pkgs'.path {
  #     localSystem = pkgs'.stdenv.hostPlatform.system;
  #     overlays = universalOverlays;
  #     config = config.nixpkgs.config // {
  #       # doesn't work: `pkgs.stdenv` does not exist
  #       # replaceStdenv = pkgs: pkgs.stdenv.override (emuStdenvArgs: {
  #       #   name = emuStdenvArgs.name + "-pseudo_cross";
  #       #   inherit (pkgs'.stdenv) buildPlatform;
  #       #   shell =
  #       #     let
  #       #       qemu = pkgs'.stdenv.hostPlatform.emulator pkgs'.buildPackages;
  #       #       hostShell = emuStdenvArgs.shell;
  #       #     in pkgs'.buildPackages.writeShellScript "bash" ''
  #       #       ${qemu} ${hostShell}/bin/bash $@
  #       #     '';
  #       #   extraAttrs = {
  #       #     buildPlatform = emuStdenvArgs.buildPlatform;
  #       #   };
  #       # });
  #       replaceStdenv = pkgs: pkgs'.stdenv.override (crossStdenvArgs: {
  #         name = crossStdenvArgs.name + "-pseudo_cross";
  #         # buildPlatform = crossStdenvArgs.hostPlatform // {
  #         #   inherit (crossStdenvArgs.buildPlatform) system;
  #         # };
  #         shell =
  #           let
  #             qemu = pkgs'.stdenv.hostPlatform.emulator pkgs'.buildPackages;
  #             hostShell = pkgs.bash;
  #           in pkgs'.buildPackages.writeShellScript "bash" ''
  #             ${qemu} ${hostShell}/bin/bash $@
  #           '';
  #         extraAttrs = {
  #           buildPlatform = crossStdenvArgs.hostPlatform;
  #         };
  #       });
  #     };
  #   };

  # mkEmulated = pkgs': pkgs'.extend (final: pkgs:
  #   lib.optionalAttrs (pkgs.stdenv.buildPlatform != pkgs.stdenv.hostPlatform) {
  # XXX: this one works only if we assign stdenv via `//`, not as an overlay
  # mkEmulated = pkgs: pkgs // ({
  #   stdenv = pkgs.stdenv.override (crossStdenvArgs: {
  #     name = crossStdenvArgs.name + "-pseudo_cross";
  #     # buildPlatform = crossStdenvArgs.hostPlatform // {
  #     #   inherit (crossStdenvArgs.buildPlatform) system;
  #     # };
  #     shell =
  #       let
  #         qemu = pkgs'.stdenv.hostPlatform.emulator pkgs'.buildPackages;
  #         hostShell = pkgs'.bash;
  #       in pkgs.buildPackages.writeShellScript "bash" ''
  #         ${qemu} ${hostShell}/bin/bash $@
  #       '';
  #     extraAttrs = {
  #       # fake it for anyone who queries `stdenv.buildPlatform`,
  #       # particularly `stdenv.buildPlatform == stdenv.hostPlatform`
  #       # and `stdenv.buildPlatform.system`.
  #       # this tricks even `stdenv.mkDerivation` into thinking it's building on a different platform than it actually is.
  #       buildPlatform = crossStdenvArgs.hostPlatform;
  #     };
  #     # shell = "/dead" + crossStdenvArgs.shell;
  #     # extraAttrs = {
  #     #   system = crossStdenvArgs.buildPlatform;
  #     #   # buildPlatform = crossStdenvArgs.hostPlatform;
  #     # };
  #   });
  # });

  # mkEmulated = pkgs: pkgs.extend (final: crossPkgs: {
  #   stdenv = crossPkgs.stdenv.override (crossStdenvArgs: {
  #     buildPlatform = crossPkgs.stdenv.hostPlatform;
  #     # buildPlatform = crossStdenvArgs.hostPlatform;
  #     # shell = # TODO: set this to a qemu-emulated version of the old shell?

  #     # extraAttrs = {
  #     #   # trick nix into believing this package is still *buildable* by the real build system,
  #     #   # while hopefully not impacting anything higher level.
  #     #   system = crossStdenvArgs.buildPlatform.system;
  #     #   # inherit
  #     #   #   (
  #     #   #     crossPkgs.stdenv.override (crossStdenvArgs': {
  #     #   #       buildPlatform = crossStdenvArgs'.hostPlatform // {
  #     #   #         inherit (crossStdenvArgs'.buildPlatform) system;
  #     #   #       };
  #     #   #     })
  #     #   #   )
  #     #   #   mkDerivation;
  #     # };

  #     # mkDerivationFromStdenv = stdenvFromPkgs: crossStdenv.mkDerivationFromStdenv stdenvFromPkgs.override (nearlyStdenvFromPkgs: {
  #     #   # mkDerivation sets the `derivation`'s `system` attribute from `stdenv.buildPlatform.system`,
  #     #   # so we have no way to avoid providing it with a cross-like stdenv.
  #     #   # this stdenv changes a few behaviors of `mkDerivation` (most of which we can patch), but isn't
  #     #   # exposed to any code outside that `mkDerivation` function, so the impacted scope is limited.
  #     #   buildPlatform = nearlyStdenvFromPkgs.buildPlatform // {
  #     #     # TODO: can we inherit `nearlyStdenvFromPkgs.system` instead?
  #     #     inherit (crossStdenv.buildPlatform) system;
  #     #   };
  #     #   # shell = # TODO: set this to a qemu-emulated version of the old shell?
  #     # });

  #     # mkDerivationFromStdenv = stdenvFromPkgs: (
  #     #   stdenvFromPkgs.override (nearlyStdenvFromPkgs: {
  #     #     # mkDerivation sets the `derivation`'s `system` attribute from `stdenv.buildPlatform.system`,
  #     #     # so we have no way to avoid providing it with a cross-like stdenv.
  #     #     # this stdenv changes a few behaviors of `mkDerivation` (most of which we can patch), but isn't
  #     #     # exposed to any code outside that `mkDerivation` function, so the impacted scope is limited.
  #     #     buildPlatform = nearlyStdenvFromPkgs.buildPlatform // {
  #     #       # TODO: can we inherit `nearlyStdenvFromPkgs.system` instead?
  #     #       inherit (crossStdenv.buildPlatform) system;
  #     #     };
  #     #     # shell = # TODO: set this to a qemu-emulated version of the old shell?
  #     #   })
  #     # ).mkDerivation;

  #   });
  # });

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
  # move items from buildInputs into nativeBuildInputs, or vice-versa.
  # arguments represent the final location of specific inputs.
  mvInputs = { buildInputs ? [], nativeBuildInputs ? [] }: pkg:
    addInputs { buildInputs = buildInputs; nativeBuildInputs = nativeBuildInputs; }
    (
      rmInputs { buildInputs = nativeBuildInputs; nativeBuildInputs = buildInputs; }
      pkg
    );
in
{
  options = {
    sane.cross.enablePatches = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enablePatches {
    # the configuration of which specific package set `pkgs.cross` refers to happens elsewhere;
    # here we just define them all.

    # nixpkgs.config.perlPackageOverrides = pkgs': (with pkgs'; with pkgs'.perlPackages; {
    #   # these are the upstream nixpkgs perl modules, but with `nativeBuildInputs = [ perl ]`
    #   # to fix cross compilation errors
    #   # see <nixpkgs:pkgs/top-level/perl-packages.nix>
    #   # TODO: try this PR: https://github.com/NixOS/nixpkgs/pull/225640
    #   ModuleBuild = buildPerlPackage {
    #     pname = "Module-Build";
    #     version = "0.4231";
    #     src = pkgs.fetchurl {
    #       url = "mirror://cpan/authors/id/L/LE/LEONT/Module-Build-0.4231.tar.gz";
    #       hash = "sha256-fg9MaSwXQMGshOoU1+o9i8eYsvsmwJh3Ip4E9DCytxc=";
    #     };
    #     # support cross-compilation by removing unnecessary File::Temp version check
    #     # postPatch = lib.optionalString (pkgs.stdenv.hostPlatform != pkgs.stdenv.buildPlatform) ''
    #     #   sed -i '/File::Temp/d' Build.PL
    #     # '';
    #     nativeBuildInputs = [ perl ];
    #     meta = {
    #       description = "Build and install Perl modules";
    #       license = with lib.licenses; [ artistic1 gpl1Plus ];
    #       mainProgram = "config_data";
    #     };
    #   };
    #   FileBaseDir = buildPerlModule {
    #     version = "0.08";
    #     pname = "File-BaseDir";
    #     src = pkgs.fetchurl {
    #       url = "mirror://cpan/authors/id/K/KI/KIMRYAN/File-BaseDir-0.08.tar.gz";
    #       hash = "sha256-wGX80+LyKudpk3vMlxuR+AKU1QCfrBQL+6g799NTBeM=";
    #     };
    #     configurePhase = ''
    #       runHook preConfigure
    #       perl Build.PL PREFIX="$out" prefix="$out"
    #     '';
    #     nativeBuildInputs = [ perl ];
    #     propagatedBuildInputs = [ IPCSystemSimple ];
    #     buildInputs = [ FileWhich ];
    #     meta = {
    #       description = "Use the Freedesktop.org base directory specification";
    #       license = with lib.licenses; [ artistic1 gpl1Plus ];
    #     };
    #   };
    #   # fixes: "FAILED IPython/terminal/tests/test_debug_magic.py::test_debug_magic_passes_through_generators - pexpect.exceptions.TIMEOUT: Timeout exceeded."
    #   Testutf8 = buildPerlPackage {
    #     pname = "Test-utf8";
    #     version = "1.02";
    #     src = pkgs.fetchurl {
    #       url = "mirror://cpan/authors/id/M/MA/MARKF/Test-utf8-1.02.tar.gz";
    #       hash = "sha256-34LwnFlAgwslpJ8cgWL6JNNx5gKIDt742aTUv9Zri9c=";
    #     };
    #     nativeBuildInputs = [ perl ];
    #     meta = {
    #       description = "Handy utf8 tests";
    #       homepage = "https://github.com/2shortplanks/Test-utf8/tree";
    #       license = with lib.licenses; [ artistic1 gpl1Plus ];
    #     };
    #   };
    #   # inherit (pkgs.emulated.perl.pkgs)
    #   #   Testutf8
    #   # ;
    # });
    # XXX: replaceStdenv only affects non-cross stages
    # nixpkgs.config.replaceStdenv = { pkgs }: pkgs.ccacheStdenv;
    nixpkgs.overlays = crossOnlyUniversalOverlays ++ [
      (next: prev: {
        emulated = if (prev.stdenv.hostPlatform != prev.stdenv.buildPlatform) then
          mkEmulated prev
        else
          prev
        ;
      })

      # (next: prev: lib.optionalAttrs (
      #   # we want to affect only the final bootstrap stage, identified by:
      #   # - buildPlatform = local,
      #   # - targetPlatform = cross,
      #   # - hostPlatform = cross
      #   # and specifically in the event of `pkgsCross` sets -- e.g. the `pkgsCross.wasi32` used by firefox
      #   # -- we want to *not* override the stdenv. it's theoretically possible, but doing so breaks firefox.
      #   prev.stdenv.buildPlatform != prev.stdenv.hostPlatform &&
      #   prev.stdenv.hostPlatform == prev.stdenv.targetPlatform &&
      #   prev.stdenv.hostPlatform == config.nixpkgs.hostPlatform
      # ) {
      #   # XXX: stdenv.cc is the cc-wrapper, from <nixpkgs:pkgs/build-support/cc-wrapper/default.nix>.
      #   #      always the same.
      #   # stdenv.cc.cc is either the real gcc (for buildPackages.stdenv), or the ccache (for normal stdenv).
      #   stdenv = prev.stdenv.override {
      #     cc = prev.stdenv.cc.override {
      #       # cc = prev.buildPackages.ccacheWrapper;
      #       cc = (prev.buildPackages.ccacheWrapper.override {
      #         cc = prev.stdenv.cc;
      #        }).overrideAttrs (_orig: {
      #          # some things query stdenv.cc.cc.version, etc (rarely), so pass those through
      #          passthru = prev.stdenv.cc.cc;
      #       });
      #     };
      #   };
      #   # stdenv = prev.buildPackages.ccacheStdenv;
      #   # stdenv = prev.ccacheStdenv.override { inherit (prev) stdenv; };
      # })

      (nativeSelf: nativeSuper: {
        pkgsi686Linux = nativeSuper.pkgsi686Linux.extend (i686Self: i686Super: {
          # fixes eval-time error: "Unsupported cross architecture"
          #   it happens even on a x86_64 -> x86_64 build:
          #   - defining `config.nixpkgs.buildPlatform` to the non-default causes that setting to be inherited by pkgsi686.
          #   - hence, `pkgsi686` on a non-cross build is ordinarily *emulated*:
          #     defining a cross build causes it to also be cross (but to the right hostPlatform)
          # this has no inputs other than stdenv, and fetchurl, so emulating it is fine.
          tbb = nativeSuper.emulated.pkgsi686Linux.tbb;
          # tbb = i686Super.tbb.overrideAttrs (orig: (with i686Self; {
          #   makeFlags = lib.optionals stdenv.cc.isClang [
          #     "compiler=clang"
          #   ] ++ (lib.optional (stdenv.buildPlatform != stdenv.hostPlatform)
          #     (if stdenv.hostPlatform.isAarch64 then "arch=arm64"
          #     else if stdenv.hostPlatform.isx86_64 then "arch=intel64"
          #     else throw "Unsupported cross architecture: ${stdenv.buildPlatform.system} -> ${stdenv.hostPlatform.system}"));
          # }));
        });
      })
      (next: prev:
        let
          emulated = prev.emulated;
          # emulated = if prev.stdenv.buildPlatform.system == prev.stdenv.hostPlatform.system then
          #   prev
          # else
          #   prev.emulated;
          useEmulatedStdenv = p: p.override {
            inherit (emulated) stdenv;
          };
        in {
          # packages which don't cross compile
          inherit (emulated)
            # adwaita-qt6  # although qtbase cross-compiles with minor change, qtModule's qtbase can't
            # duplicity  # python3.10-s3transfer
            # gdk-pixbuf  # cross-compiled version doesn't output bin/gdk-pixbuf-thumbnailer  (used by webp-pixbuf-loader
            # gnome-tour
            # XXX: gnustep members aren't individually overridable, because the "scope" uses `rec` such that members don't see overrides
            # gnustep is going to need a *lot* of work/domain-specific knowledge to truly cross-compile,
            # though if we make the members overridable maybe we can get away with emulating only stdenv.
            gnustep  # gnustep.base: "configure: error: Your compiler does not appear to implement the -fconstant-string-class option needed for support of strings."
            # grpc
            # nixpkgs hdf5 is at commit 3e847e003632bdd5fdc189ccbffe25ad2661e16f
            # hdf5  # configure: error: cannot run test program while cross compiling
            # http2
            ibus
            jellyfin-web  # in node-dependencies-jellyfin-web: "node: command not found"  (nodePackages don't cross compile)
            # libgccjit  # "../../gcc-9.5.0/gcc/jit/jit-result.c:52:3: error: 'dlclose' was not declared in this scope"  (needed by emacs!)
            # libsForQt5  # qtbase  # make: g++: No such file or directory
            perlInterpreters  # perl5.36.0-Module-Build perl5.36.0-Test-utf8 (see tracking issues ^)
            # qgnomeplatform
            # qtbase
            qt5  # qt5.qtx11extras fails, but we can't selectively emulate it
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
          #   inherit (next.qt6) qtbase qtwayland;
          # };
          # qt6 doesn't cross compile. the only thing that wants it is phosh/gnome, in order to
          # configure qt6 apps to look stylistically like gtk apps.
          # adwaita-qt6 isn't an input into any other packages we build -- it's just placed on the systemPackages.
          # so... just set it to null and that's Good Enough (TM).
          # adwaita-qt6 = derivation { name = "null-derivation"; builder = "/dev/null"; }; # null;
          # adwaita-qt6 = next.stdenv.mkDerivation { name = "null-derivation"; };
          # adwaita-qt6 = next.emptyDirectory;
          # same story as qdwaita-qt6
          # qgnomeplatform-qt6 = next.emptyDirectory;

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
              sed -i 's:/replace/with/path/to/perl/interpreter:${next.buildPackages.perl}/bin/perl:' $dev/bin/apxs
            '';
          });

          # apacheHttpd_2_4 = (prev.apacheHttpd_2_4.override {
          #   # fixes `configure: error: Size of "void *" is less than size of "long"`
          #   inherit (emulated) stdenv;
          # }).overrideAttrs (upstream: {
          #   # nativeBuildInputs = upstream.nativeBuildInputs ++ [ next.bintools ];
          #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
          #     next.buildPackages.stdenv.cc  # fixes: "/nix/store/czvaa9y9ch56z53c0b0f5bsjlgh14ra6-apr-aarch64-unknown-linux-gnu-1.7.0-dev/share/build/libtool: line 1890: aarch64-unknown-linux-gnu-ar: command not found"
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

          # TODO(REMOVE AFTER MERGE): https://github.com/NixOS/nixpkgs/pull/225977
          aprutil = prev.aprutil.overrideAttrs (upstream: {
            # nixpkgs patches the ldb version only for the package itself, but derivative packages (serf -> subversion) inherit the wrong -ldb-6.9 flag.
            postConfigure = upstream.postConfigure + lib.optionalString (next.stdenv.buildPlatform != next.stdenv.hostPlatform) ''
              substituteInPlace apu-1-config \
                --replace "-ldb-6.9" "-ldb"
            '';
          });

          blueman = prev.blueman.overrideAttrs (orig: {
            # configure: error: ifconfig or ip not found, install net-tools or iproute2
            nativeBuildInputs = orig.nativeBuildInputs ++ [ next.iproute2 ];
          });
          brltty = prev.brltty.override {
            # configure: error: no acceptable C compiler found in $PATH
            inherit (emulated) stdenv;
          };
          cantarell-fonts = prev.cantarell-fonts.override {
            # fixes error where python3.10-skia-pathops dependency isn't available for the build platform
            inherit (emulated) stdenv;
          };
          # fixes "FileNotFoundError: [Errno 2] No such file or directory: 'gtk4-update-icon-cache'"
          # - only required because of my wrapGAppsHook4 change
          celluloid = addNativeInputs [ next.gtk4 ] prev.celluloid;
          cdrtools = prev.cdrtools.override {
            # "configure: error: installation or configuration problem: C compiler cc not found."
            inherit (emulated) stdenv;
          };
          # cdrtools = prev.cdrtools.overrideAttrs (upstream: {
          #   # can't get it to actually use our CC, even when specifying these explicitly
          #   # CC = "${next.stdenv.cc}/bin/${next.stdenv.cc.targetPrefix}cc";
          #   makeFlags = upstream.makeFlags ++ [
          #     "CC=${next.stdenv.cc}/bin/${next.stdenv.cc.targetPrefix}cc"
          #   ];
          # });

          # colord = prev.colord.override {
          #   # doesn't fix: "ld: error adding symbols: file in wrong format"
          #   inherit (emulated) stdenv;
          # };
          colord = prev.colord.overrideAttrs (upstream: {
            # fixes: (meson) ERROR: An exe_wrapper is needed but was not found. Please define one in cross file and check the command and/or add it to PATH.
            nativeBuildInputs = upstream.nativeBuildInputs ++ lib.optionals (!prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform) [
              next.mesonEmulatorHook
            ];
          });

          dante = prev.dante.override {
            # fixes: "configure: error: error: getaddrinfo() error value count too low"
            inherit (emulated) stdenv;
          };

          # dconf = (prev.dconf.override {
          #   # we need dconf to build with vala, because dconf-editor requires that.
          #   # this only happens if dconf *isn't* cross-compiled
          #   inherit (emulated) stdenv;
          # }).overrideAttrs (upstream: {
          #   nativeBuildInputs = lib.remove next.glib upstream.nativeBuildInputs;
          # });
          dconf = prev.dconf.overrideAttrs (upstream: {
            # we need dconf to build with vala, because dconf-editor requires that.
            # upstream nixpkgs explicitly disables that on cross compilation, but in fact, it works.
            # so just undo upstream's mods.
            buildInputs = upstream.buildInputs ++ [ next.vala ];
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

          flatpak = prev.flatpak.overrideAttrs (upstream: {
            # fixes "No package 'libxml-2.0' found"
            buildInputs = upstream.buildInputs ++ [ next.libxml2 ];
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
          #   #   next.mesonEmulatorHook
          #   # ];
          # });
          # solves (meson) "Run-time dependency libgcab-1.0 found: NO (tried pkgconfig and cmake)", and others.
          fwupd = (addBuildInputs
            [ next.gcab ]
            (mvToBuildInputs [ next.gnutls ] prev.fwupd)
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

          # fixes (meson): "ERROR: Program 'gpg2 gpg' not found or not executable"
          gcr_4 = mvInputs { nativeBuildInputs = [ next.gnupg next.openssh ]; } prev.gcr_4;
          gthumb = mvInputs { nativeBuildInputs = [ next.glib ]; } prev.gthumb;

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
            dconf-editor = addNativeInputs [ next.dconf ] super.dconf-editor;
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
                "-DCMAKE_CROSSCOMPILING_EMULATOR=${next.stdenv.hostPlatform.emulator next.buildPackages}"
              ];
              # N.B.: the deps are funky even without cross compiling.
              # upstream probably wants to replace pcre with pcre2, and maybe provide perl
              # nativeBuildInputs = upstream.nativeBuildInputs ++ [
              #   next.perl  # fixes "The 'perl' not found, not installing csv2vcard"
              #   # next.glib
              #   # next.libiconv
              #   # next.iconv
              # ];
              # buildInputs = upstream.buildInputs ++ [
              #   next.pcre2  # fixes: "Package 'libpcre2-8', required by 'glib-2.0', not found"
              #   next.mount  # fails to fix: "Package 'mount', required by 'gio-2.0', not found"
              # ];
            });

            # file-roller = super.file-roller.override {
            #   # fixes "src/meson.build:106:0: ERROR: Program 'glib-compile-resources' not found or not executable"
            #   inherit (emulated) stdenv;
            # };
            # fixes: "src/meson.build:106:0: ERROR: Program 'glib-compile-resources' not found or not executable"
            file-roller = mvToNativeInputs [ next.glib ] super.file-roller;
            # fixes: "meson.build:75:6: ERROR: Program 'gtk-update-icon-cache' not found or not executable"
            gnome-clocks = addNativeInputs [ next.gtk4 ] super.gnome-clocks;
            # fixes: "src/meson.build:3:0: ERROR: Program 'glib-compile-resources' not found or not executable"
            gnome-color-manager = mvToNativeInputs [ next.glib ] super.gnome-color-manager;
            # fixes "subprojects/gvc/meson.build:30:0: ERROR: Program 'glib-mkenums mkenums' not found or not executable"
            gnome-control-center = mvToNativeInputs [ next.glib ] super.gnome-control-center;
            # gnome-control-center = super.gnome-control-center.override {
            #   inherit (next) stdenv;
            # };
            # gnome-keyring = super.gnome-keyring.override {
            #   # does not fix original error
            #   inherit (next) stdenv;
            # };
            gnome-keyring = super.gnome-keyring.overrideAttrs (orig: {
              # fixes "configure.ac:374: error: possibly undefined macro: AM_PATH_LIBGCRYPT"
              nativeBuildInputs = orig.nativeBuildInputs ++ [ next.libgcrypt next.openssh next.glib ];
            });
            # fixes: "Program gdbus-codegen found: NO"
            gnome-remote-desktop = mvToNativeInputs [ next.glib ] super.gnome-remote-desktop;
            # gnome-shell = super.gnome-shell.overrideAttrs (orig: {
            #   # fixes "meson.build:128:0: ERROR: Program 'gjs' not found or not executable"
            #   # does not fix "_giscanner.cpython-310-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory"  (python import failure)
            #   nativeBuildInputs = orig.nativeBuildInputs ++ [ next.gjs next.gobject-introspection ];
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
                next.gjs  # fixes "meson.build:128:0: ERROR: Program 'gjs' not found or not executable"
                next.buildPackages.gobject-introspection  # fixes "shew| Build-time dependency gobject-introspection-1.0 found: NO"
              ];
              buildInputs = lib.remove next.gobject-introspection upstream.buildInputs;
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
            #   nativeBuildInputs = orig.nativeBuildInputs ++ [ next.mesonEmulatorHook ];
            # });
            gnome-settings-daemon = super.gnome-settings-daemon.overrideAttrs (orig: {
              # glib solves: "Program 'glib-mkenums mkenums' not found or not executable"
              nativeBuildInputs = orig.nativeBuildInputs ++ [ next.glib ];
              # pkg-config solves: "plugins/power/meson.build:22:0: ERROR: Dependency lookup for glib-2.0 with method 'pkgconfig' failed: Pkg-config binary for machine 0 not found."
              # stdenv.cc fixes: "plugins/power/meson.build:60:0: ERROR: No build machine compiler for 'plugins/power/gsd-power-enums-update.c'"
              # but then it fails with a link-time error.
              # depsBuildBuild = orig.depsBuildBuild or [] ++ [ next.glib next.pkg-config next.buildPackages.stdenv.cc ];
              # hack to just not build the power plugin (panel?), to avoid cross compilation errors
              postPatch = orig.postPatch + ''
                sed -i "s/disabled_plugins = \[\]/disabled_plugins = ['power']/" plugins/meson.build
              '';
            });
            # fixes: "gdbus-codegen not found or executable"
            gnome-session = mvToNativeInputs [ next.glib ] super.gnome-session;
            # gnome-terminal = super.gnome-terminal.override {
            #   # fixes: "meson.build:343:0: ERROR: Dependency "libpcre2-8" not found, tried pkgconfig"
            #   # new failure mode: "/nix/store/grqh2wygy9f9wp5bgvqn4im76v82zmcx-binutils-2.39/bin/ld: /nix/store/f7yr5z123d162p5457jh3wzkqm7x8yah-glib-2.74.3/lib/libglib-2.0.so: error adding symbols: file in wrong format"
            #   inherit (emulated) stdenv;
            # };
            gnome-terminal = super.gnome-terminal.overrideAttrs (orig: {
              # fixes "meson.build:343:0: ERROR: Dependency "libpcre2-8" not found, tried pkgconfig"
              buildInputs = orig.buildInputs ++ [ next.pcre2 ];
            });
            # fixes: meson.build:111:6: ERROR: Program 'glib-compile-schemas' not found or not executable
            gnome-user-share = addNativeInputs [ next.glib ] super.gnome-user-share;
            # fixes: "FileNotFoundError: [Errno 2] No such file or directory: 'gtk4-update-icon-cache'"
            gnome-weather = addNativeInputs [ next.gtk4 ] super.gnome-weather;
            mutter = super.mutter.overrideAttrs (orig: {
              nativeBuildInputs = orig.nativeBuildInputs ++ [
                next.glib  # fixes "clutter/clutter/meson.build:281:0: ERROR: Program 'glib-mkenums mkenums' not found or not executable"
                next.buildPackages.gobject-introspection  # allows to build without forcing `introspection=false` (which would break gnome-shell)
                next.wayland-scanner
              ];
              buildInputs = orig.buildInputs ++ [
                next.mesa  # fixes "meson.build:237:2: ERROR: Dependency "gbm" not found, tried pkgconfig"
              ];
              mesonFlags = lib.remove "-Ddocs=true" orig.mesonFlags;
              outputs = lib.remove "devdoc" orig.outputs;
            });
            # nautilus = super.nautilus.override {
            #   # fixes: "meson.build:123:0: ERROR: Dependency "libxml-2.0" not found, tried pkgconfig"
            #   # new failure mode: "/nix/store/grqh2wygy9f9wp5bgvqn4im76v82zmcx-binutils-2.39/bin/ld: /nix/store/f7yr5z123d162p5457jh3wzkqm7x8yah-glib-2.74.3/lib/libglib-2.0.so: error adding symbols: file in wrong format"
            #   inherit (emulated) stdenv;
            # };
            nautilus = addInputs {
              # fixes: "meson.build:123:0: ERROR: Dependency "libxml-2.0" not found, tried pkgconfig"
              buildInputs = [ next.libxml2 ];
              # fixes: "meson.build:226:6: ERROR: Program 'gtk-update-icon-cache' not found or not executable"
              nativeBuildInputs = [ next.gtk4 ];
            } super.nautilus;
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
            #     [ next.glib.dev ]
            #     (mvToNativeInputs [ next.python3 ] super.GConf);
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

          gocryptfs = prev.gocryptfs.override {
            # fixes "error: hash mismatch in fixed-output derivation" (vendorSha256)
            inherit (emulated) buildGoModule;  # equivalent to stdenv
          };
          # gocryptfs = prev.gocryptfs.override {
          #   # fixes "error: hash mismatch in fixed-output derivation" (vendorSha256)
          #   # new error: "go: inconsistent vendoring in /build/source:"
          #   # - "github.com/hanwen/go-fuse/v2@v2.1.1-0.20211219085202-934a183ed914: is explicitly required in go.mod, but not marked as explicit in vendor/modules.txt"
          #   # - ...
          #   buildGoModule = args: next.buildGoModule (args // {
          #     vendorSha256 = {
          #       x86_64-linux = args.vendorSha256;
          #       aarch64-linux = "sha256-9famtUjkeAtzxfXzmWVum/pyaNp89Aqnfd+mWE7KjaI=";
          #     }."${next.stdenv.system}";
          #   });
          # };
          gpodder = prev.gpodder.overridePythonAttrs (upstream: {
            # fix gobject-introspection overrides import that otherwise fails on launch
            nativeBuildInputs = upstream.nativeBuildInputs ++ [
              next.buildPackages.gobject-introspection
            ];
            buildInputs = lib.remove next.gobject-introspection upstream.buildInputs;
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
              nativeBuildInputs = lib.remove next.qt5.qtbase upstream.nativeBuildInputs;
              # TODO: swap in this line instead?
              # buildInputs = lib.remove next.qt5.qtbase upstream.buildInputs;
            });
          };
          gvfs = prev.gvfs.overrideAttrs (upstream: {
            nativeBuildInputs = upstream.nativeBuildInputs ++ [
              next.openssh
              next.glib  # fixes "gdbus-codegen: command not found"
            ];
            # fixes "meson.build:312:2: ERROR: Assert failed: http required but libxml-2.0 not found"
            buildInputs = upstream.buildInputs ++ [ next.libxml2 ];
          });

          # hdf5 = prev.hdf5.override {
          #   inherit (emulated) stdenv;
          # };

          # "setup: line 1595: ant: command not found"
          i2p = mvToNativeInputs [ next.ant next.gettext ] prev.i2p;

          # ibus = (prev.ibus.override {
          #   inherit (emulated)
          #     stdenv # fixes: "configure: error: cannot run test program while cross compiling"
          #     gobject-introspection # "cannot open shared object ..."
          #   ;
          # });
          # .overrideAttrs (upstream: {
          #   nativeBuildInputs = upstream.nativeBuildInputs or [] ++ [
          #     next.glib  # fixes: ImportError: /nix/store/fi1rsalr11xg00dqwgzbf91jpl3zwygi-gobject-introspection-aarch64-unknown-linux-gnu-1.74.0/lib/gobject-introspection/giscanner/_giscanner.cpython-310-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory
          #     next.buildPackages.gobject-introspection  # fixes "_giscanner.cpython-310-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory"
          #   ];
          #   buildInputs = lib.remove next.gobject-introspection upstream.buildInputs ++ [
          #     next.vala  # fixes: "Package `ibus-1.0' not found in specified Vala API directories or GObject-Introspection GIR directories"
          #   ];
          # });

          # fixes "./autogen.sh: line 26: gtkdocize: not found"
          iio-sensor-proxy = mvToNativeInputs [ next.glib next.gtk-doc ] prev.iio-sensor-proxy;

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
              #     [ next.zip ]
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

          jellyfin-media-player = prev.jellyfin-media-player.overrideAttrs (upstream: {
            meta = upstream.meta // {
              platforms = upstream.meta.platforms ++ [
                "aarch64-linux"
              ];
            };
          });
          # jellyfin-web = prev.jellyfin-web.override {
          #   # in node-dependencies-jellyfin-web: "node: command not found"
          #   inherit (emulated) stdenv;
          # };

          kitty = prev.kitty.overrideAttrs (upstream: {
            # fixes: "FileNotFoundError: [Errno 2] No such file or directory: 'pkg-config'"
            PKGCONFIG_EXE = "${next.buildPackages.pkg-config}/bin/${next.buildPackages.pkg-config.targetPrefix}pkg-config";

            # when building docs, kitty's setup.py invokes `sphinx`, which tries to load a .so for the host.
            # on cross compilation, that fails
            KITTY_NO_DOCS = true;
            patches = upstream.patches ++ [
              ./kitty-no-docs.patch
            ];
          });
          libgweather = (prev.libgweather.override {
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
          #   nativeBuildInputs = (lib.remove next.gobject-introspection upstream.nativeBuildInputs) ++ [
          #     next.buildPackages.gobject-introspection  # fails to fix "gi._error.GError: g-invoke-error-quark: Could not locate g_option_error_quark: /nix/store/dsx6kqmyg7f3dz9hwhz7m3jrac4vn3pc-glib-aarch64-unknown-linux-gnu-2.74.3/lib/libglib-2.0.so.0"
          #   ];
          #   # fixes "Run-time dependency vapigen found: NO (tried pkgconfig)"
          #   buildInputs = upstream.buildInputs ++ [ next.vala ];
          # });

          # TODO(REMOVE AFTER MERGE): https://github.com/NixOS/nixpkgs/pull/225977
          libqmi = prev.libqmi.overrideAttrs (upstream: {
            # fixes "failed to produce output devdoc"; nixpkgs only builds that output conditionally
            outputs = [ "out" "dev" ] ++ lib.optionals (prev.stdenv.buildPlatform == prev.stdenv.hostPlatform) [
              "devdoc"
            ];
          });

          libsForQt5 = prev.libsForQt5.overrideScope' (self: super: {
            qgpgme = super.qgpgme.overrideAttrs (orig: {
              # fix so it can find the MOC compiler
              # it looks like it might not *need* to propagate qtbase, but so far unclear
              nativeBuildInputs = orig.nativeBuildInputs ++ [ self.qtbase ];
              propagatedBuildInputs = lib.remove self.qtbase orig.propagatedBuildInputs;
            });
            phonon = super.phonon.overrideAttrs (orig: {
              # fixes "ECM (required version >= 5.60), Extra CMake Modules"
              buildInputs = orig.buildInputs ++ [ next.extra-cmake-modules ];
            });
          });

          # fixes: "ar: command not found"
          # `ar` is provided by bintools
          ncftp = addNativeInputs [ next.bintools ] prev.ncftp;
          # fixes "gdbus-codegen: command not found"
          networkmanager-fortisslvpn = mvToNativeInputs [ next.glib ] prev.networkmanager-fortisslvpn;
          # networkmanager-iodine = prev.networkmanager-iodine.overrideAttrs (orig: {
          #   # fails to fix "configure.ac:58: error: possibly undefined macro: AM_GLIB_GNU_GETTEXT"
          #   nativeBuildInputs = orig.nativeBuildInputs ++ [ next.gettext ];
          # });
          networkmanager-iodine = prev.networkmanager-iodine.override {
            # fixes "configure.ac:58: error: possibly undefined macro: AM_GLIB_GNU_GETTEXT"
            inherit (emulated) stdenv;
          };
          # networkmanager-iodine = prev.networkmanager-iodine.overrideAttrs (upstream: {
          #   # buildInputs = upstream.buildInputs ++ [ next.intltool next.gettext ];
          #   # nativeBuildInputs = lib.remove next.intltool upstream.nativeBuildInputs;
          #   # nativeBuildInputs = upstream.nativeBuildInputs ++ [ next.gettext ];
          #   postPatch = upstream.postPatch or "" + ''
          #     sed -i s/AM_GLIB_GNU_GETTEXT/AM_GNU_GETTEXT/ configure.ac
          #   '';
          # });

          # fixes "gdbus-codegen: command not found"
          # fixes "gtk4-builder-tool: command not found"
          networkmanager-l2tp = addNativeInputs [ next.gtk4 ]
            (mvToNativeInputs [ next.glib ] prev.networkmanager-l2tp);
          # fixes "properties/gresource.xml: Permission denied"
          #   - by providing glib-compile-resources
          networkmanager-openconnect = mvToNativeInputs [ next.glib ] prev.networkmanager-openconnect;
          # fixes "properties/gresource.xml: Permission denied"
          #   - by providing glib-compile-resources
          networkmanager-openvpn = mvToNativeInputs [ next.glib ] prev.networkmanager-openvpn;
          # fixes "gdbus-codegen: command not found"
          networkmanager-sstp = mvToNativeInputs [ next.glib ] prev.networkmanager-sstp;
          networkmanager-vpnc = mvToNativeInputs [ next.glib ] prev.networkmanager-vpnc;
          # fixes "properties/gresource.xml: Permission denied"
          #   - by providing glib-compile-resources
          nheko = prev.nheko.overrideAttrs (orig: {
            # fixes "fatal error: lmdb++.h: No such file or directory
            buildInputs = orig.buildInputs ++ [ next.lmdbxx ];
          });
          notmuch = prev.notmuch.overrideAttrs (upstream: {
            # fixes "Error: The dependencies of notmuch could not be satisfied"  (xapian, gmime, glib, talloc)
            # when cross-compiling, we only have a triple-prefixed pkg-config which notmuch's configure script doesn't know how to find.
            # so just replace these with the nix-supplied env-var which resolves to the relevant pkg-config.
            postPatch = upstream.postPatch or "" + ''
              sed -i 's/pkg-config/\$PKG_CONFIG/g' configure
            '';
            XAPIAN_CONFIG = next.buildPackages.writeShellScript "xapian-config" ''
              exec ${lib.getBin next.xapian}/bin/xapian-config $@
            '';
            # depsBuildBuild = [ next.gnupg ];
            nativeBuildInputs = upstream.nativeBuildInputs ++ [
              next.gnupg  # nixpkgs specifies gpg as a buildInput instead of a nativeBuildInput
              next.perl  # used to build manpages
              # next.pythonPackages.python
              # next.shared-mime-info
            ];
            buildInputs = with next; [
              xapian gmime3 talloc zlib  # dependencies described in INSTALL
              # perl
              # pythonPackages.python
              ruby  # notmuch links against ruby.so
            ];
            # buildInputs =
            #   (lib.remove
            #     next.perl
            #     (lib.remove
            #       next.gmime
            #       (lib.remove next.gnupg upstream.buildInputs)
            #     )
            #   ) ++ [ next.gmime ];
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
          #     next.gnupg
          #     next.perl
          #   ];
          #   buildInputs = lib.remove next.gnupg upstream.buildInputs;
          # });
          # notmuch = prev.notmuch.overrideAttrs (upstream: {
          #   # fixes "Error: The dependencies of notmuch could not be satisfied"  (xapian, gmime, glib, talloc)
          #   # when cross-compiling, we only have a triple-prefixed pkg-config which notmuch's configure script doesn't know how to find.
          #   # so just replace these with the nix-supplied env-var which resolves to the relevant pkg-config.
          #   postPatch = upstream.postPatch or "" + ''
          #     sed -i 's/pkg-config/\$PKG_CONFIG/g' configure
          #     sed -i 's: gpg : ${next.buildPackages.gnupg}/bin/gpg :' configure
          #   '';
          #   XAPIAN_CONFIG = next.buildPackages.writeShellScript "xapian-config" ''
          #     exec ${lib.getBin next.xapian}/bin/xapian-config $@
          #   '';
          #   # depsBuildBuild = upstream.depsBuildBuild or [] ++ [
          #   #   next.buildPackages.stdenv.cc
          #   # ];
          #   nativeBuildInputs = upstream.nativeBuildInputs ++ [
          #     # next.gnupg
          #     next.perl
          #   ];
          #   # buildInputs = lib.remove next.gnupg upstream.buildInputs;
          # });

          # fixes "/nix/store/0wk6nr1mryvylf5g5frckjam7g7p9gpi-bash-5.2-p15/bin/bash: line 2: --prefix=ods_manager: command not found"
          # - dbus-glib should maybe be removed from buildInputs, too? but doing so breaks upstream configure
          obex_data_server = addNativeInputs [ next.dbus-glib ] prev.obex_data_server;
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
          #   # buildInputs = lib.remove next.gpgme upstream.buildInputs;
          #   nativeBuildInputs = upstream.nativeBuildInputs ++ [ next.gpgme ];
          # });

          # TODO(REMOVE AFTER MERGE): https://github.com/NixOS/nixpkgs/pull/225977
          # fixes: "perl: command not found"
          pam_mount = mvToNativeInputs [ next.perl ] prev.pam_mount;

          # phoc = prev.phoc.override {
          #   # fixes "Program wayland-scanner found: NO"
          #   inherit (emulated) stdenv;
          # };
          # fixes (meson) "Program 'glib-mkenums mkenums' not found or not executable"
          phoc = mvToNativeInputs [ next.wayland-scanner next.glib ] prev.phoc;
          phosh = prev.phosh.overrideAttrs (upstream: {
            buildInputs = upstream.buildInputs ++ [
              next.libadwaita  # "plugins/meson.build:41:2: ERROR: Dependency "libadwaita-1" not found, tried pkgconfig"
            ];
            mesonFlags = upstream.mesonFlags ++ [
              "-Dphoc_tests=disabled"  # "tests/meson.build:20:0: ERROR: Program 'phoc' not found or not executable"
            ];
            # postPatch = upstream.postPatch or "" + ''
            #   sed -i 's:gio_querymodules = :gio_querymodules = "${next.buildPackages.glib.dev}/bin/gio-querymodules" if True else :' build-aux/post_install.py
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
            buildInputs = [ next.phosh ];
            nativeBuildInputs = [
              next.gettext  # fixes "data/meson.build:1:0: ERROR: Program 'msgfmt' not found or not executable"
              next.wayland-scanner  # fixes "protocols/meson.build:7:0: ERROR: Program 'wayland-scanner' not found or not executable"
              next.glib  # fixes "src/meson.build:1:0: ERROR: Program 'glib-mkenums mkenums' not found or not executable"
              next.desktop-file-utils  # fixes "meson.build:116:8: ERROR: Program 'update-desktop-database' not found or not executable"
            ];
          } prev.phosh-mobile-settings;
          # psqlodbc = prev.psqlodbc.override {
          #   # fixes "configure: error: odbc_config not found (required for unixODBC build)"
          #   inherit (emulated) stdenv;
          # };

          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (py-next: py-prev: {

              aiohttp = py-prev.aiohttp.overridePythonAttrs (orig: {
                # fixes "ModuleNotFoundError: No module named 'setuptools'"
                propagatedBuildInputs = orig.propagatedBuildInputs ++ [
                  py-next.setuptools
                ];
              });

              cryptography = py-prev.cryptography.override {
                inherit (emulated) rustPlatform;  # "cargo:warning=aarch64-unknown-linux-gnu-gcc: error: unrecognized command-line option ‘-m64’"
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
                GSSAPI_MAIN_LIB = "${next.buildPackages.krb5}/lib/libgssapi_krb5.so";
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
                # nativeBuildInputs = orig.nativeBuildInputs ++ [ py-next.numpy ];
                nativeBuildInputs = orig.nativeBuildInputs ++ orig.propagatedBuildInputs;
              });
              psycopg2 = py-prev.psycopg2.overridePythonAttrs (orig: {
                # TODO: upstream  (see tracking issue)
                #
                # psycopg2 *links* against libpg, so we need the host postgres available at build time!
                # present-day nixpkgs only includes it in nativeBuildInputs
                buildInputs = orig.buildInputs ++ [ next.postgresql ];
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
              #   nativeBuildInputs = lib.remove py-next.pythran orig.nativeBuildInputs;
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
          # qt6 = prev.qt6.overrideScope' (self: super: {
          #   # inherit (emulated.qt6) qtModule;
          #   qtbase = super.qtbase.overrideAttrs (upstream: {
          #     # cmakeFlags = upstream.cmakeFlags ++ lib.optionals (next.stdenv.buildPlatform != next.stdenv.hostPlatform) [
          #     cmakeFlags = upstream.cmakeFlags ++ lib.optionals (next.stdenv.buildPlatform != next.stdenv.hostPlatform) [
          #       # "-DCMAKE_CROSSCOMPILING=True" # fails to solve QT_HOST_PATH error
          #       "-DQT_HOST_PATH=${next.buildPackages.qt6.full}"
          #     ];
          #   });
          #   qtModule = args: (super.qtModule args).overrideAttrs (upstream: {
          #     # the nixpkgs comment about libexec seems to be outdated:
          #     # it's just that cross-compiled syncqt.pl doesn't get its #!/usr/bin/env shebang replaced.
          #     preConfigure = lib.replaceStrings
          #       ["${lib.getDev self.qtbase}/libexec/syncqt.pl"]
          #       ["perl ${lib.getDev self.qtbase}/libexec/syncqt.pl"]
          #       upstream.preConfigure;
          #   });
          #   # qtwayland = super.qtwayland.overrideAttrs (upstream: {
          #   #   preConfigure = "fixQtBuiltinPaths . '*.pr?'";
          #   # });
          #   # qtwayland = super.qtwayland.override {
          #   #   inherit (self) qtbase;
          #   # };
          #   # qtbase = super.qtbase.override {
          #   #   # fixes: "You need to set QT_HOST_PATH to cross compile Qt."
          #   #   inherit (emulated) stdenv;
          #   # };
          # });

          rmlint = prev.rmlint.override {
            # fixes "Checking whether the C compiler works... no"
            # rmlint is scons; it reads the CC environment variable, though, so *may* be cross compilable
            inherit (emulated) stdenv;
          };
          samba = prev.samba.overrideAttrs (_upstream: {
            # we get "cannot find C preprocessor: aarch64-unknown-linux-gnu-cpp", but ONLY when building with the ccache stdenv.
            # this solves that, but `CPP` must be a *single* path -- not an expression.
            # i do not understand how the original error arises, as my ccacheStdenv should match the API of the base stdenv (except for cpp being a symlink??).
            # but oh well, this fixes it.
            CPP = next.buildPackages.writeShellScript "cpp" ''
              exec ${lib.getBin next.stdenv.cc}/bin/${next.stdenv.cc.targetPrefix}cc -E $@;
            '';
          });
          # sequoia = prev.sequoia.override {
          #   # fails to fix original error
          #   inherit (emulated) stdenv;
          # };

          # TODO(REMOVE AFTER MERGE): https://github.com/NixOS/nixpkgs/pull/225977
          # fixes "sh: line 1: ar: command not found"
          serf = addNativeInputs [ next.bintools ] prev.serf;

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
          #       crossFile = next.writeText "cross-file.conf" ''
          #         [binaries]
          #         rust = [ 'rustc', '--target', '${next.rust.toRustTargetSpec next.stdenv.hostPlatform}' ]
          #       '';
          #     in
          #       # upstream.mesonFlags or [] ++
          #       [
          #         "-Dtests=false"
          #         "-Dnewer=false"
          #         "-Donline=false"
          #       ]
          #       ++ lib.optional
          #         (next.stdenv.hostPlatform != next.stdenv.buildPlatform)
          #         "--cross-file=${crossFile}"
          #       ;

          #   cargoDeps = null;
          #   cargoVendorDir = "vendor";

          #   depsBuildBuild = upstream.depsBuildBuild or [] ++ [
          #     next.pkg-config
          #   ];
          #   nativeBuildInputs = with next; [
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
              stdenv  # fixes "gcc: error: unrecognized command line option '-m64'"
              glib  # fixes error when linking src/squeekboard: "/nix/store/3c0dqm093ylw8ks7myzxdaif0m16rgcl-binutils-2.40/bin/ld: /nix/store/jzh15bi6zablx3d9s928w3lgqy6and91-glib-2.74.3/lib/libgio-2.0.so"
              wayland  # fixes error when linking src/squeekboard: "/nix/store/3c0dqm093ylw8ks7myzxdaif0m16rgcl-binutils-2.40/bin/ld: /nix/store/ni0vb1pnaznx85378i3h9xhw9cay68g5-wayland-1.21.0/lib/libwayland-client.so: error adding symbols: file in wrong format"
              # gtk3  # fails to fix: "/nix/store/acl3fg3z4i96d6lha2cbr16k7bl1zjs5-binutils-2.40/bin/ld: /nix/store/k2jd14yl5qcl3kwifhhs271607fjafbx-gtk+3-3.24.36/lib/libgtk-3.so: error adding symbols: file in wrong format"
              wrapGAppsHook  # introduces a competing gtk3 at link-time, unless emulated
            ;
          };
          # TODO(REMOVE AFTER MERGE): https://github.com/NixOS/nixpkgs/pull/225977
          subversion = prev.subversion.overrideAttrs (upstream: {
            configureFlags = upstream.configureFlags ++ [
              # configure can't find APR and APR-util, unclear why (are they not placed on PATH?)
              "--with-apr=${next.apr.dev}/bin/apr-1-config"
              "--with-apr-util=${next.aprutil.dev}/bin/apu-1-config"
            ];
          });

          # fixes: "src/meson.build:12:2: ERROR: Program 'gdbus-codegen' not found or not executable"
          sysprof = mvToNativeInputs [ next.glib ] (
            addNativeInputs [ next.wrapGAppsHook ] (
              # addDepsBuildBuild [ next.pkg-config ] prev.sysprof
              rmInputs { nativeBuildInputs = [ next.wrapGAppsHook4 ]; } prev.sysprof
            )
          );
          tracker-miners = prev.tracker-miners.override {
            # fixes "meson.build:183:0: ERROR: Can not run test applications in this cross environment."
            inherit (emulated) stdenv;
          };
          # twitter-color-emoji = prev.twitter-color-emoji.override {
          #   # fails to fix original error
          #   inherit (emulated) stdenv;
          # };

          # fixes: "ar: command not found"
          # `ar` is provided by bintools
          unar = addNativeInputs [ next.bintools ] prev.unar;
          unixODBCDrivers = prev.unixODBCDrivers // {
            # TODO: should this package be deduped with toplevel psqlodbc in upstream nixpkgs?
            psql = prev.unixODBCDrivers.psql.overrideAttrs (_upstream: {
              # XXX: these are both available as configureFlags, if we prefer that (we probably do, so as to make them available only during specific parts of the build).
              ODBC_CONFIG = next.buildPackages.writeShellScript "odbc_config" ''
                exec ${next.stdenv.hostPlatform.emulator next.buildPackages} ${next.unixODBC}/bin/odbc_config $@
              '';
              PG_CONFIG = next.buildPackages.writeShellScript "pg_config" ''
                exec ${next.stdenv.hostPlatform.emulator next.buildPackages} ${next.postgresql}/bin/pg_config $@
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
            nativeBuildInputs = orig.nativeBuildInputs ++ [ next.lua5 next.protobuf ];
            # fix that it can't find the c compiler
            # makeFlags = orig.makeFlags or [] ++ [ "CC=${prev.stdenv.cc.targetPrefix}cc" ];
            BUILDCC = "${prev.stdenv.cc}/bin/${prev.stdenv.cc.targetPrefix}cc";
          });
          # fixes "perl: command not found"
          vpnc = mvToNativeInputs [ next.perl ] prev.vpnc;
          wrapGAppsHook4 = prev.wrapGAppsHook4.override {
            gtk3 = next.emptyDirectory;
          };
          xapian = prev.xapian.overrideAttrs (upstream: {
            # the output has #!/bin/sh scripts.
            # - shebangs get re-written on native build, but not cross build
            buildInputs = upstream.buildInputs ++ [ next.bash ];
          });
          # fixes "No package 'xdg-desktop-portal' found"
          xdg-desktop-portal-gtk = mvToBuildInputs [ next.xdg-desktop-portal ] prev.xdg-desktop-portal-gtk;
          # fixes: "data/meson.build:33:5: ERROR: Program 'msgfmt' not found or not executable"
          # fixes: "src/meson.build:25:0: ERROR: Program 'gdbus-codegen' not found or not executable"
          xdg-desktop-portal-gnome = (
            addNativeInputs [ next.wayland-scanner ] (
              mvToNativeInputs [ next.gettext next.glib ] prev.xdg-desktop-portal-gnome
            )
          );
          # webkitgtk = prev.webkitgtk.override { stdenv = next.ccacheStdenv; };
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
      })
    ];
  };
}
