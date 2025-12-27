# Originally based on:
# https://github.com/NixOS/nixpkgs/blob/a5c345b6d5e2d7d0e0a8c336a2bd6a0a42ea7623/pkgs/applications/virtualization/qemu/default.nix
# Changes marked with 'SCREAMER:'.
# Also changed `--replace` to `--replace-fail`, but didn't mark individually.
# SCREAMER:
{ lib, stdenv, fetchurl, fetchpatch, python3Packages, zlib, pkg-config, glib, buildPackages # , overrideSDK
, pixman, vde2, alsa-lib, flex, pcre2
, bison, lzo, snappy, libaio, libtasn1, gnutls, nettle, curl, dtc, ninja, meson, perl
, sigtool
, makeWrapper, removeReferencesTo
, attr, libcap, libcap_ng, socat, libslirp
# SCREAMER: remove deprecated Darwin deps
# , CoreServices, Cocoa, Hypervisor, Kernel, rez, setfile, vmnet
, guestAgentSupport ? (with stdenv.hostPlatform; isLinux || isNetBSD || isOpenBSD || isSunOS || isWindows) && !minimal
, numaSupport ? stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isAarch32 && !minimal, numactl
, seccompSupport ? stdenv.hostPlatform.isLinux && !minimal, libseccomp
, alsaSupport ? lib.hasSuffix "linux" stdenv.hostPlatform.system && !nixosTestRunner && !minimal
, pulseSupport ? !stdenv.hostPlatform.isDarwin && !nixosTestRunner && !minimal, libpulseaudio
, pipewireSupport ? !stdenv.hostPlatform.isDarwin && !nixosTestRunner && !minimal, pipewire
, sdlSupport ? !stdenv.hostPlatform.isDarwin && !nixosTestRunner && !minimal, SDL2, SDL2_image
, jackSupport ? !stdenv.hostPlatform.isDarwin && !nixosTestRunner && !minimal, libjack2
, gtkSupport ? !stdenv.hostPlatform.isDarwin && !xenSupport && !nixosTestRunner && !minimal, gtk3, gettext, vte, wrapGAppsHook3
, vncSupport ? !nixosTestRunner && !minimal, libjpeg, libpng
, smartcardSupport ? !nixosTestRunner && !minimal, libcacard
, spiceSupport ? true && !nixosTestRunner && !minimal, spice, spice-protocol
, ncursesSupport ? !nixosTestRunner && !minimal, ncurses
, usbredirSupport ? spiceSupport, usbredir
, xenSupport ? false, xen
, cephSupport ? false, ceph
, glusterfsSupport ? false, glusterfs, libuuid
, openGLSupport ? sdlSupport, mesa, libepoxy, libdrm
, rutabagaSupport ? openGLSupport && !minimal && lib.meta.availableOn stdenv.hostPlatform rutabaga_gfx, rutabaga_gfx
, virglSupport ? openGLSupport, virglrenderer
, libiscsiSupport ? !minimal, libiscsi
, smbdSupport ? false, samba
, tpmSupport ? !minimal
, uringSupport ? stdenv.hostPlatform.isLinux && !userOnly, liburing
, canokeySupport ? !minimal, canokey-qemu
, capstoneSupport ? !minimal, capstone
, pluginsSupport ? !stdenv.hostPlatform.isStatic
, enableDocs ? !minimal || toolsOnly
, enableTools ? !minimal || toolsOnly
, enableBlobs ? !minimal || toolsOnly
, hostCpuOnly ? false
# SCREAMER: build ppc version by default
, hostCpuTargets ? (if toolsOnly
                    then [ ]
                    else [ "ppc-softmmu" ])
, nixosTestRunner ? false
, toolsOnly ? false
, userOnly ? false
, minimal ? toolsOnly || userOnly
# SCREAMER: don't auto-update for now
# , gitUpdater
# SCREAMER:
, nixpkgs-qemu9_1
, apple-sdk_12 ? null, darwinMinVersionHook
, fetchFromGitHub, fetchFromGitLab, fetchgit
, maintainers
, qemu
, qemu-utils # for tests attribute
}:

assert lib.assertMsg (xenSupport -> hostCpuTargets == [ "i386-softmmu" ]) "Xen should not use any other QEMU architecture other than i386.";

let
  # SCREAMER:
  nixpkgsPatch = name: "${nixpkgs-qemu9_1}/pkgs/applications/virtualization/qemu/${name}";
  subprojectSrcs = {
    berkeley-softfloat-3 = fetchFromGitLab {
      owner = "qemu-project";
      repo = "berkeley-softfloat-3";
      rev = "b64af41c3276f97f0e181920400ee056b9c88037";
      hash = "sha256-Yflpx+mjU8mD5biClNpdmon24EHg4aWBZszbOur5VEA=";
    };
    berkeley-testfloat-3 = fetchFromGitLab {
      owner = "qemu-project";
      repo = "berkeley-testfloat-3";
      rev = "e7af9751d9f9fd3b47911f51a5cfd08af256a9ab";
      hash = "sha256-inQAeYlmuiRtZm37xK9ypBltCJ+ycyvIeIYZK8a+RYU=";
    };
    dtc = fetchFromGitLab {
      owner = "qemu-project";
      repo = "dtc";
      rev = "b6910bec11614980a21e46fbccc35934b671bd81";
      hash = "sha256-gx9LG3U9etWhPxm7Ox7rOu9X5272qGeHqZtOe68zFs4=";
    };
    keycodemapdb = fetchFromGitLab {
      owner = "qemu-project";
      repo = "keycodemapdb";
      rev = "f5772a62ec52591ff6870b7e8ef32482371f22c6";
      hash = "sha256-GbZ5mrUYLXMi0IX4IZzles0Oyc095ij2xAsiLNJwfKQ=";
    };
    libblkio = fetchFromGitLab {
      owner = "libblkio";
      repo = "libblkio";
      rev = "f84cc963a444e4cb34813b2dcfc5bf8526947dc0";
      hash = "sha256-suN0EvFzDi17HJSHUFRl8kVFicOxGaji8grlo1DoT8E=";
    };
    libvfio-user = fetchFromGitLab {
      owner = "qemu-project";
      repo = "libvfio-user";
      rev = "0b28d205572c80b568a1003db2c8f37ca333e4d7";
      hash = "sha256-V05nnJbz8Us28N7nXvQYbj66LO4WbVBm6EO+sCjhhG8=";
    };
    slirp = fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "slirp";
      repo = "libslirp";
      rev = "26be815b86e8d49add8c9a8b320239b9594ff03d";
      hash = "sha256-6LX3hupZQeg3tZdY1To5ZtkOXftwgboYul792mhUmds=";
    };
  };

  hexagonSupport = hostCpuTargets == null || lib.elem "hexagon" hostCpuTargets;

  buildPlatformStdenv =
    # SCREAMER:
    # if stdenv.buildPlatform.isDarwin then
    #   overrideSDK buildPackages.stdenv {
    #     # Keep these values in sync with `all-packages.nix`.
    #     darwinSdkVersion = "12.3";
    #     darwinMinVersion = "12.0";
    #   }
    # else
      buildPackages.stdenv;
in

stdenv.mkDerivation (finalAttrs: {
  # SCREAMER:
  pname = "qemu-screamer"
    + lib.optionalString xenSupport "-xen"
    + lib.optionalString hostCpuOnly "-host-cpu-only"
    + lib.optionalString nixosTestRunner "-for-vm-tests"
    + lib.optionalString toolsOnly "-utils"
    + lib.optionalString userOnly "-user";
  version = "9.1.0-unstable-2024-09-23";

  # SCREAMER:
  src = fetchFromGitHub {
    owner = "mcayland";
    repo = "qemu";
    rev = "1c47688ed6557fae9e5bfe4f4b4082d570c94a70";
    fetchSubmodules = true;
    # Zeex/subhook is gone, see <https://github.com/tianocore/edk2/issues/6398>
    preFetch = ''
      newGitConfig="$(mktemp -d)/gitconfig"
      if [ -n "$gitConfigFile" ]; then
        cp "$gitConfigFile" "$newGitConfig"
      else
        touch "$newGitConfig"
      fi
      git config -f "$newGitConfig" 'url.https://github.com/tianocore/edk2-subhook.git.insteadOf' 'https://github.com/Zeex/subhook.git'
      gitConfigFile="$newGitConfig"
    '' + lib.optionalString (!((lib.functionArgs fetchgit)?gitConfigFile)) ''
      export GIT_CONFIG_GLOBAL="$gitConfigFile"
    '';
    hash = "sha256-7c+PxNHxbWnV3X5FHens3mAuka1nXItmaCH6aH6X2rQ=";
  };
  postUnpack = lib.pipe subprojectSrcs [
    (lib.mapAttrsToList (name: src: ''
      cp -R --no-preserve=mode,ownership ${src} "$sourceRoot/subprojects/${name}"
      if [[ -d "$sourceRoot/subprojects/packagefiles/${name}" ]]; then
        cp -R "$sourceRoot/subprojects/packagefiles/${name}"/* "$sourceRoot/subprojects/${name}/"
      fi
    ''))
    (builtins.concatStringsSep "\n")
  ];

  depsBuildBuild = [ buildPlatformStdenv.cc ]
    ++ lib.optionals hexagonSupport [ pkg-config ];

  nativeBuildInputs = [
    makeWrapper removeReferencesTo
    pkg-config flex bison meson ninja perl

    # Don't change this to python3 and python3.pkgs.*, breaks cross-compilation
    python3Packages.python
  ]
    ++ lib.optionals gtkSupport [ wrapGAppsHook3 ]
    ++ lib.optionals enableDocs [ python3Packages.sphinx python3Packages.sphinx-rtd-theme ]
    ++ lib.optionals hexagonSupport [ glib ]
    # SCREAMER:
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ sigtool ] # rez setfile ]
    ++ lib.optionals (!userOnly) [ dtc ]
    ++ lib.optionals (
      stdenv.hostPlatform.isDarwin &&
      lib.versionOlder stdenv.hostPlatform.darwinMinVersion "12"
    ) [
      apple-sdk_12
      (darwinMinVersionHook "12.0")
    ];

  buildInputs = [ glib zlib ]
    ++ lib.optionals (!minimal) [ dtc pixman vde2 lzo snappy libtasn1 gnutls nettle libslirp ]
    ++ lib.optionals (!userOnly) [ curl ]
    ++ lib.optionals ncursesSupport [ ncurses ]
    # SCREAMER:
    # ++ lib.optionals stdenv.hostPlatform.isDarwin [ CoreServices Cocoa Hypervisor Kernel vmnet ]
    ++ lib.optionals seccompSupport [ libseccomp ]
    ++ lib.optionals numaSupport [ numactl ]
    ++ lib.optionals alsaSupport [ alsa-lib ]
    ++ lib.optionals pulseSupport [ libpulseaudio ]
    ++ lib.optionals pipewireSupport [ pipewire ]
    ++ lib.optionals sdlSupport [ SDL2 SDL2_image ]
    ++ lib.optionals jackSupport [ libjack2 ]
    ++ lib.optionals gtkSupport [ gtk3 gettext vte ]
    ++ lib.optionals vncSupport [ libjpeg libpng ]
    ++ lib.optionals smartcardSupport [ libcacard ]
    ++ lib.optionals spiceSupport [ spice-protocol spice ]
    ++ lib.optionals usbredirSupport [ usbredir ]
    ++ lib.optionals (stdenv.hostPlatform.isLinux && !userOnly) [ libcap_ng libcap attr libaio ]
    ++ lib.optionals xenSupport [ xen ]
    ++ lib.optionals cephSupport [ ceph ]
    ++ lib.optionals glusterfsSupport [ glusterfs libuuid ]
    ++ lib.optionals openGLSupport [ mesa libepoxy libdrm ]
    ++ lib.optionals rutabagaSupport [ rutabaga_gfx ]
    ++ lib.optionals virglSupport [ virglrenderer ]
    ++ lib.optionals libiscsiSupport [ libiscsi ]
    ++ lib.optionals smbdSupport [ samba ]
    ++ lib.optionals uringSupport [ liburing ]
    ++ lib.optionals canokeySupport [ canokey-qemu ]
    ++ lib.optionals capstoneSupport [ capstone ];

  dontUseMesonConfigure = true; # meson's configurePhase isn't compatible with qemu build
  dontAddStaticConfigureFlags = true;

  outputs = [ "out" ] ++ lib.optional enableDocs "doc" ++ lib.optional guestAgentSupport "ga";
  # On aarch64-linux we would shoot over the Hydra's 2G output limit.
  separateDebugInfo = !(stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isLinux);

  patches = [
    # SCREAMER:
    (nixpkgsPatch "fix-qemu-ga.patch")

    # Workaround for upstream issue with nested virtualisation: https://gitlab.com/qemu-project/qemu/-/issues/1008
    (fetchpatch {
      url = "https://gitlab.com/qemu-project/qemu/-/commit/3e4546d5bd38a1e98d4bd2de48631abf0398a3a2.diff";
      sha256 = "sha256-oC+bRjEHixv1QEFO9XAm4HHOwoiT+NkhknKGPydnZ5E=";
      revert = true;
    })

    # musl changes https://gitlab.com/qemu-project/qemu/-/issues/2215
    (fetchpatch {
      url = "https://gitlab.com/qemu-project/qemu/-/commit/ac1bbe8ca46c550b3ad99c85744119a3ace7b4f4.diff";
      sha256 = "sha256-wSlf8+7WHk2Z4I5cLFa37MRroQucPIuFzzyWnG9IpeY=";
    })
    (fetchpatch {
      url = "https://gitlab.com/qemu-project/qemu/-/commit/99174ce39e86ec6aea7bb7ce326b16e3eed9e3da.diff";
      sha256 = "sha256-Cpt01d1ARoCTuJuC66no4doPgL+4/ZqnJTWwjU2MxnY=";
    })
    
    # SCREAMER:
    # On macOS, QEMU uses `Rez(1)` and `SetFile(1)` to attach its icon
    # to the binary. Unfortunately, those commands are proprietary,
    # deprecated since Xcode 6, and operate on resource forks, which
    # these days are stored in extended attributes, which aren’t
    # supported in the Nix store. So we patch out the calls.
    (fetchpatch {
      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/ed8925fc509a703a5799c97dbdd89ce0c8ac86b8/pkgs/applications/virtualization/qemu/skip-macos-icon.patch";
      hash = "sha256-MMyv5cRstt+aYvDb7T65tnx9iux4Uvoy/hthz02VqjY=";
    })
    # *** Ouch! *** found no usable distlib, please install it
    (fetchpatch {
      url = "https://gitlab.com/-/project/11167699/uploads/0bc3ef428137940e7cdc31beae0d7594/qemu-10.0.3-pip-25.2-compat.patch";
      hash = "sha256-D3dv6OgQCQj2R9GXkDodH8lziuh4oz+eui1JCwN6AM0=";
    })
  ]
  # SCREAMER:
  ++ lib.optional nixosTestRunner (nixpkgsPatch "force-uid0-on-9p.patch");

  postPatch = ''
    # Otherwise tries to ensure /var/run exists.
    sed -i "/install_emptydir(get_option('localstatedir') \/ 'run')/d" \
        qga/meson.build
  '';

  preConfigure = ''
    unset CPP # intereferes with dependency calculation
    # this script isn't marked as executable b/c it's indirectly used by meson. Needed to patch its shebang
    chmod +x ./scripts/shaderinclude.py
    patchShebangs .
    # avoid conflicts with libc++ include for <version>
    mv VERSION QEMU_VERSION
    substituteInPlace configure \
      --replace-fail '$source_path/VERSION' '$source_path/QEMU_VERSION'
    substituteInPlace meson.build \
      --replace-fail "'VERSION'" "'QEMU_VERSION'"
  '';

  configureFlags = [
    "--disable-strip" # We'll strip ourselves after separating debug info.
    (lib.enableFeature enableDocs "docs")
    (lib.enableFeature enableTools "tools")
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--cross-prefix=${stdenv.cc.targetPrefix}"
    (lib.enableFeature guestAgentSupport "guest-agent")
  ] ++ lib.optional numaSupport "--enable-numa"
    ++ lib.optional seccompSupport "--enable-seccomp"
    ++ lib.optional smartcardSupport "--enable-smartcard"
    ++ lib.optional spiceSupport "--enable-spice"
    ++ lib.optional usbredirSupport "--enable-usb-redir"
    ++ lib.optional (hostCpuTargets != null) "--target-list=${lib.concatStringsSep "," hostCpuTargets}"
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ "--enable-cocoa" "--enable-hvf" ]
    ++ lib.optional (stdenv.hostPlatform.isLinux && !userOnly) "--enable-linux-aio"
    ++ lib.optional gtkSupport "--enable-gtk"
    ++ lib.optional xenSupport "--enable-xen"
    ++ lib.optional cephSupport "--enable-rbd"
    ++ lib.optional glusterfsSupport "--enable-glusterfs"
    ++ lib.optional openGLSupport "--enable-opengl"
    ++ lib.optional virglSupport "--enable-virglrenderer"
    ++ lib.optional tpmSupport "--enable-tpm"
    ++ lib.optional libiscsiSupport "--enable-libiscsi"
    ++ lib.optional smbdSupport "--smbd=${samba}/bin/smbd"
    ++ lib.optional uringSupport "--enable-linux-io-uring"
    ++ lib.optional canokeySupport "--enable-canokey"
    ++ lib.optional capstoneSupport "--enable-capstone"
    ++ lib.optional (!pluginsSupport) "--disable-plugins"
    ++ lib.optional (!enableBlobs) "--disable-install-blobs"
    ++ lib.optional userOnly "--disable-system"
    ++ lib.optional stdenv.hostPlatform.isStatic "--static";

  dontWrapGApps = true;

  # QEMU attaches entitlements with codesign and strip removes those,
  # voiding the entitlements and making it non-operational.
  # The alternative is to re-sign with entitlements after stripping:
  # * https://github.com/qemu/qemu/blob/v6.1.0/scripts/entitlement.sh#L25
  dontStrip = stdenv.hostPlatform.isDarwin;

  postFixup = ''
    # the .desktop is both invalid and pointless
    rm -f $out/share/applications/qemu.desktop
  '' + lib.optionalString guestAgentSupport ''
    # move qemu-ga (guest agent) to separate output
    mkdir -p $ga/bin
    mv $out/bin/qemu-ga $ga/bin/
    ln -s $ga/bin/qemu-ga $out/bin
    remove-references-to -t $out $ga/bin/qemu-ga
  '' + lib.optionalString gtkSupport ''
    # wrap GTK Binaries
    for f in $out/bin/qemu-system-*; do
      wrapGApp $f
    done
  '' + lib.optionalString stdenv.hostPlatform.isStatic ''
    # HACK: Otherwise the result will have the entire buildInputs closure
    # injected by the pkgsStatic stdenv
    # <https://github.com/NixOS/nixpkgs/issues/83667>
    rm -f $out/nix-support/propagated-build-inputs
  '';
  preBuild = "cd build";

  # tests can still timeout on slower systems
  doCheck = false;
  nativeCheckInputs = [ socat ];
  preCheck = ''
    # time limits are a little meagre for a build machine that's
    # potentially under load.
    substituteInPlace ../tests/unit/meson.build \
      --replace-fail 'timeout: slow_tests' 'timeout: 50 * slow_tests'
    substituteInPlace ../tests/qtest/meson.build \
      --replace-fail 'timeout: slow_qtests' 'timeout: 50 * slow_qtests'
    substituteInPlace ../tests/fp/meson.build \
      --replace-fail 'timeout: 90)' 'timeout: 300)'

    # point tests towards correct binaries
    substituteInPlace ../tests/unit/test-qga.c \
      --replace-fail '/bin/bash' "$(type -P bash)" \
      --replace-fail '/bin/echo' "$(type -P echo)"
    substituteInPlace ../tests/unit/test-io-channel-command.c \
      --replace-fail '/bin/socat' "$(type -P socat)"

    # combined with a long package name, some temp socket paths
    # can end up exceeding max socket name len
    substituteInPlace ../tests/qtest/bios-tables-test.c \
      --replace-fail 'qemu-test_acpi_%s_tcg_%s' '%s_%s'

    # get-fsinfo attempts to access block devices, disallowed by sandbox
    sed -i -e '/\/qga\/get-fsinfo/d' -e '/\/qga\/blacklist/d' \
      ../tests/unit/test-qga.c

    # xattrs are not allowed in the sandbox
    substituteInPlace ../tests/qtest/virtio-9p-test.c \
      --replace-fail mapped-xattr mapped-file
  '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # skip test that stalls on darwin, perhaps due to subtle differences
    # in fifo behaviour
    substituteInPlace ../tests/unit/meson.build \
      --replace-fail "'test-io-channel-command'" "#'test-io-channel-command'"
  '';

  # Add a ‘qemu-kvm’ wrapper for compatibility/convenience.
  # SCREAMER: don't make a broken symlink if host platform isn't built
  # SCREAMER: link to `-screamer` name for easier use alongside upstream QEMU
  postInstall = lib.optionalString (!minimal) ''
    if [[ -e $out/bin/qemu-system-${stdenv.hostPlatform.qemuArch} ]]; then
      ln -s $out/bin/qemu-system-${stdenv.hostPlatform.qemuArch} $out/bin/qemu-kvm
    fi
    if [[ -e $out/bin/qemu-system-ppc ]]; then
      ln -s "$out/bin/qemu-system-ppc" "$out/bin/qemu-system-ppc-screamer"
    fi
  '';

  passthru = {
    qemu-system-i386 = "bin/qemu-system-i386";
    tests = lib.optionalAttrs (!toolsOnly) {
      qemu-tests = finalAttrs.finalPackage.overrideAttrs (_: { doCheck = true; });
      qemu-utils-builds = qemu-utils;
    };
    # updateScript = gitUpdater {
    #   # No nicer place to find latest release.
    #   url = "https://gitlab.com/qemu-project/qemu.git";
    #   rev-prefix = "v";
    #   ignoredVersions = "(alpha|beta|rc).*";
    # };
  };

  # Builds in ~3h with 2 cores, and ~20m with a big-parallel builder.
  requiredSystemFeatures = [ "big-parallel" ];

  meta = with lib; {
    # SCREAMER:
    homepage = "https://github.com/mcayland/qemu/tree/screamer-v9.1.0";
    description = "Generic and open source machine emulator and virtualizer (mcayland's 'screamer' fork)";
    longDescription = ''
      This is mcayland's 'screamer' fork of QEMU, with flaky-but-functional support 
      for the Screamer audio chip used in PowerPC Macintoshes. By default it will 
      only build the `ppc-softmmu` target for qemu.
    '';
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ Rhys-T ];
    platforms = platforms.unix;
    # SCREAMER: Can't seem to get this working. Oh well, 25.05 is going away soon-ish anyway.
    broken = (
      stdenv.hostPlatform.isDarwin &&
      lib.versionOlder stdenv.hostPlatform.darwinMinVersion "12"
    );
  }
  # toolsOnly: Does not have qemu-kvm and there's no main support tool
  # userOnly: There's one qemu-<arch> for every architecture
  // lib.optionalAttrs (!toolsOnly && !userOnly) {
    # SCREAMER:
    mainProgram = "qemu-system-ppc-screamer";
    priority = (qemu.meta.priority or lib.meta.defaultPriority) + 5; # Prefer upstream qemu
  }
  # userOnly: https://qemu.readthedocs.io/en/v9.0.2/user/main.html
  // lib.optionalAttrs userOnly {
    platforms = with platforms; (linux ++ freebsd ++ openbsd ++ netbsd);
    # SCREAMER:
    description = "QEMU User space emulator - launch executables compiled for one CPU on another CPU (mcayland's 'screamer' fork)";
  };
})
