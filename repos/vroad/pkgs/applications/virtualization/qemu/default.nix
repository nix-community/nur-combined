{ lib
, stdenv
, fetchurl
, fetchpatch
, python3
, python3Packages
, zlib
, pkg-config
, glib
, buildPackages
, perl
, pixman
, vde2
, alsa-lib
, texinfo
, flex
, bison
, lzo
, snappy
, libaio
, libtasn1
, gnutls
, nettle
, curl
, ninja
, meson
, sigtool
, makeWrapper
, runtimeShell
, removeReferencesTo
, attr
, libcap
, libcap_ng
, socat
, CoreServices
, Cocoa
, Hypervisor
, rez
, setfile
, guestAgentSupport ? with stdenv.hostPlatform; isLinux || isSunOS || isWindows
, numaSupport ? stdenv.isLinux && !stdenv.isAarch32
, numactl
, seccompSupport ? stdenv.isLinux
, libseccomp
, alsaSupport ? lib.hasSuffix "linux" stdenv.hostPlatform.system && !nixosTestRunner
, pulseSupport ? !stdenv.isDarwin && !nixosTestRunner
, libpulseaudio
, sdlSupport ? !stdenv.isDarwin && !nixosTestRunner
, SDL2
, SDL2_image
, jackSupport ? !stdenv.isDarwin && !nixosTestRunner
, libjack2
, gtkSupport ? !stdenv.isDarwin && !xenSupport && !nixosTestRunner
, gtk3
, gettext
, vte
, wrapGAppsHook
, vncSupport ? !nixosTestRunner
, libjpeg
, libpng
, smartcardSupport ? !nixosTestRunner
, libcacard
, spiceSupport ? !stdenv.isDarwin && !nixosTestRunner
, spice
, spice-protocol
, ncursesSupport ? !nixosTestRunner
, ncurses
, usbredirSupport ? spiceSupport
, usbredir
, xenSupport ? false
, xen
, cephSupport ? false
, ceph
, glusterfsSupport ? false
, glusterfs
, libuuid
, openGLSupport ? sdlSupport
, mesa
, libepoxy
, libdrm
, virglSupport ? openGLSupport
, virglrenderer
, libiscsiSupport ? true
, libiscsi
, smbdSupport ? false
, samba
, tpmSupport ? true
, uringSupport ? stdenv.isLinux
, liburing
, hostCpuOnly ? false
, hostCpuTargets ? (if hostCpuOnly
  then
    (lib.optional stdenv.isx86_64 "i386-softmmu"
      ++ [ "${stdenv.hostPlatform.qemuArch}-softmmu" ])
  else null)
, nixosTestRunner ? false
, doCheck ? false
, qemu  # for passthru.tests
, pipewire
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "qemu"
    + lib.optionalString xenSupport "-xen"
    + lib.optionalString hostCpuOnly "-host-cpu-only"
    + lib.optionalString nixosTestRunner "-for-vm-tests";
  version = "6.2.0";

  src = fetchurl {
    url = "https://download.qemu.org/qemu-${version}.tar.xz";
    sha256 = "sha256-aOFdjkWsVjJuC5pK+otJo9/oq6NIgiHQmMhGmLymW0U=";
  };

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  nativeBuildInputs = [ makeWrapper removeReferencesTo pkg-config flex bison meson ninja perl python3 python3Packages.sphinx python3Packages.sphinx_rtd_theme autoPatchelfHook ]
    ++ lib.optionals gtkSupport [ wrapGAppsHook ]
    ++ lib.optionals stdenv.isDarwin [ sigtool ];

  buildInputs = [
    zlib
    glib
    perl
    pixman
    vde2
    texinfo
    lzo
    snappy
    libtasn1
    gnutls
    nettle
    curl
  ]
  ++ lib.optionals ncursesSupport [ ncurses ]
  ++ lib.optionals stdenv.isDarwin [ CoreServices Cocoa Hypervisor rez setfile ]
  ++ lib.optionals seccompSupport [ libseccomp ]
  ++ lib.optionals numaSupport [ numactl ]
  ++ lib.optionals alsaSupport [ alsa-lib ]
  ++ lib.optionals pulseSupport [ libpulseaudio ]
  ++ lib.optionals sdlSupport [ SDL2 SDL2_image ]
  ++ lib.optionals jackSupport [ libjack2 ]
  ++ lib.optionals gtkSupport [ gtk3 gettext vte ]
  ++ lib.optionals vncSupport [ libjpeg libpng ]
  ++ lib.optionals smartcardSupport [ libcacard ]
  ++ lib.optionals spiceSupport [ spice-protocol spice ]
  ++ lib.optionals usbredirSupport [ usbredir ]
  ++ lib.optionals stdenv.isLinux [ libaio libcap_ng libcap attr ]
  ++ lib.optionals xenSupport [ xen ]
  ++ lib.optionals cephSupport [ ceph ]
  ++ lib.optionals glusterfsSupport [ glusterfs libuuid ]
  ++ lib.optionals openGLSupport [ mesa libepoxy libdrm ]
  ++ lib.optionals virglSupport [ virglrenderer ]
  ++ lib.optionals libiscsiSupport [ libiscsi ]
  ++ lib.optionals smbdSupport [ samba ]
  ++ lib.optionals uringSupport [ liburing ];

  dontUseMesonConfigure = true; # meson's configurePhase isn't compatible with qemu build

  outputs = [ "out" ] ++ lib.optional guestAgentSupport "ga";
  # On aarch64-linux we would shoot over the Hydra's 2G output limit.
  separateDebugInfo = !(stdenv.isAarch64 && stdenv.isLinux);

  patches = [
    ./fix-qemu-ga.patch
    ./9p-ignore-noatime.patch
    # Cocoa clipboard support only works on macOS 10.14+
    (fetchpatch {
      url = "https://gitlab.com/qemu-project/qemu/-/commit/7e3e20d89129614f4a7b2451fe321cc6ccca3b76.diff";
      sha256 = "09xz06g57wxbacic617pq9c0qb7nly42gif0raplldn5lw964xl2";
      revert = true;
    })
    # (fetchpatch {
    #   name = "CVE-2021-4145.patch";
    #   url = "https://gitlab.com/qemu-project/qemu/-/commit/66fed30c9cd11854fc878a4eceb507e915d7c9cd.patch";
    #   sha256 = "10za2nag51y4fhc8z7fzw3dfhj37zx8rwg0xcmw5kzmb0gyvvz70";
    # })
    (fetchpatch {
      name = "CVE-2022-26353.patch";
      url = "https://gitlab.com/qemu-project/qemu/-/commit/abe300d9d894f7138e1af7c8e9c88c04bfe98b37.patch";
      sha256 = "17s6968qbccsfljqb85wy4zvilwbbyjyb18nqwp3g40a6g4ajnbw";
    })
    (fetchpatch {
      name = "CVE-2022-26354.patch";
      url = "https://gitlab.com/qemu-project/qemu/-/commit/8d1b247f3748ac4078524130c6d7ae42b6140aaf.patch";
      sha256 = "021d6pk0kh7fxn7rnq8g7cs34qac9qy6an858fxxs31gg9yqcfkl";
    })
    (fetchpatch {
      name = "CVE-2021-4206.patch";
      url = "https://gitlab.com/qemu-project/qemu/-/commit/fa892e9abb728e76afcf27323ab29c57fb0fe7aa.patch";
      sha256 = "1mlfiz488h83qrmbq7zmcw92rdh82za7jz3mw5xrhhvxw9d6rr01";
    })
    (fetchpatch {
      name = "CVE-2021-4207.patch";
      url = "https://gitlab.com/qemu-project/qemu/-/commit/9569f5cb5b4bffa9d3ebc8ba7da1e03830a9a895.patch";
      sha256 = "14ph53pwdcgzzizmigrz444h8a46dsilnwkv0g224qz74rwxhgxz";
    })
  ] ++ lib.optional nixosTestRunner ./force-uid0-on-9p.patch
  ++ lib.optionals stdenv.hostPlatform.isMusl [
    ./sigrtminmax.patch
    (fetchpatch {
      url = "https://raw.githubusercontent.com/alpinelinux/aports/2bb133986e8fa90e2e76d53369f03861a87a74ef/main/qemu/fix-sigevent-and-sigval_t.patch";
      sha256 = "0wk0rrcqywhrw9hygy6ap0lfg314m9z1wr2hn8338r5gfcw75mav";
    })
  ] ++ lib.optionals stdenv.isDarwin [
    # The Hypervisor.framework support patch converted something that can be applied:
    # * https://patchwork.kernel.org/project/qemu-devel/list/?series=548227
    # The base revision is whatever commit there is before the series starts:
    # * https://github.com/patchew-project/qemu/commits/patchew/20210916155404.86958-1-agraf%40csgraf.de
    # The target revision is what patchew has as the series tag from patchwork:
    # * https://github.com/patchew-project/qemu/releases/tag/patchew%2F20210916155404.86958-1-agraf%40csgraf.de
    (fetchpatch {
      url = "https://github.com/patchew-project/qemu/compare/7adb961995a3744f51396502b33ad04a56a317c3..d2603c06d9c4a28e714b9b70fe5a9d0c7b0f934d.diff";
      sha256 = "sha256-nSi5pFf9+EefUmyJzSEKeuxOt39ztgkXQyUB8fTHlcY=";
    })
  ];

  postPatch = ''
    # Otherwise tries to ensure /var/run exists.
    sed -i "/install_subdir('run', install_dir: get_option('localstatedir'))/d" \
        qga/meson.build

    # glibc 2.33 compat fix: if `has_statx = true` is set, `tools/virtiofsd/passthrough_ll.c` will
    # rely on `stx_mnt_id`[1] which is not part of glibc's `statx`-struct definition.
    #
    # `has_statx` will be set to `true` if a simple C program which uses a few `statx`
    # consts & struct fields successfully compiles. It seems as this only builds on glibc-2.33
    # since most likely[2] and because of that, the problematic code-path will be used.
    #
    # [1] https://github.com/torvalds/linux/commit/fa2fcf4f1df1559a0a4ee0f46915b496cc2ebf60#diff-64bab5a0a3fcb55e1a6ad77b1dfab89d2c9c71a770a07ecf44e6b82aae76a03a
    # [2] https://sourceware.org/git/?p=glibc.git;a=blobdiff;f=io/bits/statx-generic.h;h=c34697e3c1fd79cddd60db294302e461ed8db6e2;hp=7a09e94be2abb92d2df612090c132e686a24d764;hb=88a2cf6c4bab6e94a65e9c0db8813709372e9180;hpb=c4e4b2e149705559d28b16a9b47ba2f6142d6a6c
    substituteInPlace meson.build \
      --replace 'has_statx = cc.links(statx_test)' 'has_statx = false'
  '';

  preConfigure = ''
    unset CPP # intereferes with dependency calculation
    # this script isn't marked as executable b/c it's indirectly used by meson. Needed to patch its shebang
    chmod +x ./scripts/shaderinclude.pl
    patchShebangs .
    # avoid conflicts with libc++ include for <version>
    mv VERSION QEMU_VERSION
    substituteInPlace configure \
      --replace '$source_path/VERSION' '$source_path/QEMU_VERSION'
    substituteInPlace meson.build \
      --replace "'VERSION'" "'QEMU_VERSION'"
  '';

  configureFlags = [
    "--disable-strip" # We'll strip ourselves after separating debug info.
    "--enable-docs"
    "--enable-tools"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    # Always use our Meson, not the bundled version, which doesn't
    # have our patches and will be subtly broken because of that.
    "--meson=meson"
    "--cross-prefix=${stdenv.cc.targetPrefix}"
    "--cpu=${stdenv.hostPlatform.uname.processor}"
    (lib.enableFeature guestAgentSupport "guest-agent")
  ] ++ lib.optional numaSupport "--enable-numa"
  ++ lib.optional seccompSupport "--enable-seccomp"
  ++ lib.optional smartcardSupport "--enable-smartcard"
  ++ lib.optional spiceSupport "--enable-spice"
  ++ lib.optional usbredirSupport "--enable-usb-redir"
  ++ lib.optional (hostCpuTargets != null) "--target-list=${lib.concatStringsSep "," hostCpuTargets}"
  ++ lib.optional stdenv.isDarwin "--enable-cocoa"
  ++ lib.optional stdenv.isDarwin "--enable-hvf"
  ++ lib.optional stdenv.isLinux "--enable-linux-aio"
  ++ lib.optional gtkSupport "--enable-gtk"
  ++ lib.optional xenSupport "--enable-xen"
  ++ lib.optional cephSupport "--enable-rbd"
  ++ lib.optional glusterfsSupport "--enable-glusterfs"
  ++ lib.optional openGLSupport "--enable-opengl"
  ++ lib.optional virglSupport "--enable-virglrenderer"
  ++ lib.optional tpmSupport "--enable-tpm"
  ++ lib.optional libiscsiSupport "--enable-libiscsi"
  ++ lib.optional smbdSupport "--smbd=${samba}/bin/smbd"
  ++ lib.optional uringSupport "--enable-linux-io-uring";

  dontWrapGApps = true;

  # QEMU attaches entitlements with codesign and strip removes those,
  # voiding the entitlements and making it non-operational.
  # The alternative is to re-sign with entitlements after stripping:
  # * https://github.com/qemu/qemu/blob/v6.1.0/scripts/entitlement.sh#L25
  dontStrip = stdenv.isDarwin;

  dontAutoPatchelf = true;

  postFixup = ''
    autoPatchelfLibs=(${lib.makeLibraryPath [ pipewire.jack ]} "''${autoPatchelfLibs[@]}")
    autoPatchelf $out

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
  '';
  preBuild = "cd build";

  # tests can still timeout on slower systems
  inherit doCheck;
  checkInputs = [ socat ];
  preCheck = ''
    # time limits are a little meagre for a build machine that's
    # potentially under load.
    substituteInPlace ../tests/unit/meson.build \
      --replace 'timeout: slow_tests' 'timeout: 50 * slow_tests'
    substituteInPlace ../tests/qtest/meson.build \
      --replace 'timeout: slow_qtests' 'timeout: 50 * slow_qtests'
    substituteInPlace ../tests/fp/meson.build \
      --replace 'timeout: 90)' 'timeout: 300)'

    # point tests towards correct binaries
    substituteInPlace ../tests/unit/test-qga.c \
      --replace '/bin/echo' "$(type -P echo)"
    substituteInPlace ../tests/unit/test-io-channel-command.c \
      --replace '/bin/socat' "$(type -P socat)"

    # combined with a long package name, some temp socket paths
    # can end up exceeding max socket name len
    substituteInPlace ../tests/qtest/bios-tables-test.c \
      --replace 'qemu-test_acpi_%s_tcg_%s' '%s_%s'

    # get-fsinfo attempts to access block devices, disallowed by sandbox
    sed -i -e '/\/qga\/get-fsinfo/d' -e '/\/qga\/blacklist/d' \
      ../tests/unit/test-qga.c
  '' + lib.optionalString stdenv.isDarwin ''
    # skip test that stalls on darwin, perhaps due to subtle differences
    # in fifo behaviour
    substituteInPlace ../tests/unit/meson.build \
      --replace "'test-io-channel-command'" "#'test-io-channel-command'"
  '';

  # Add a ‘qemu-kvm’ wrapper for compatibility/convenience.
  postInstall = ''
    ln -s $out/libexec/virtiofsd $out/bin
    ln -s $out/bin/qemu-system-${stdenv.hostPlatform.qemuArch} $out/bin/qemu-kvm
  '';

  passthru = {
    qemu-system-i386 = "bin/qemu-system-i386";
    tests = {
      qemu-tests = qemu.override { doCheck = true; };
    };
  };

  # Builds in ~3h with 2 cores, and ~20m with a big-parallel builder.
  requiredSystemFeatures = [ "big-parallel" ];

  preferLocalBuild = true;

  meta = with lib; {
    homepage = "http://www.qemu.org/";
    description = "A generic and open source machine emulator and virtualizer";
    license = licenses.gpl2Plus;
    mainProgram = "qemu-kvm";
    maintainers = with maintainers; [ eelco qyliss ];
    platforms = platforms.unix;
    priority = 10; # Prefer virtiofsd from the virtiofsd package.
  };
}
