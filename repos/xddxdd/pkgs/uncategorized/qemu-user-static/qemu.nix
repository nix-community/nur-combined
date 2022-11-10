{ lib
, stdenv
, fetchpatch
, python3
, zlib
, pkg-config
, glib
, buildPackages
, perl
, pixman
, flex
, bison
, ninja
, meson
, qemu
}:

# https://github.com/NixOS/nixpkgs/pull/160802
stdenv.mkDerivation {
  inherit (qemu) pname version src meta;

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  nativeBuildInputs = [ pkg-config flex bison meson ninja perl python3 ];

  buildInputs = [ zlib glib pixman perl ];

  dontAddStaticConfigureFlags = true;
  dontUseMesonConfigure = true; # meson's configurePhase isn't compatible with qemu build

  patches = qemu.patches
    ++ [
    (fetchpatch {
      url = "https://salsa.debian.org/qemu-team/qemu/-/raw/f0f56fc77fb3737b5d9f1908d4c987008fe528b8/debian/patches/linux-user-binfmt-P.diff";
      sha256 = "sha256-IeoWtmGkZ3ZBw2wBBN/kW+SJzi4OBTns8Dgw0N/LVss=";
    })
  ]
    ++ lib.optional stdenv.hostPlatform.isStatic ./aio-find-static-library.patch
    ++ lib.optionals stdenv.hostPlatform.isMusl [
    (fetchpatch {
      url = "https://github.com/alpinelinux/aports/raw/01ad5fded5cd1ce1d4fb3bbb952fd4bb420bc674/community/qemu/0006-linux-user-signal.c-define-__SIGRTMIN-MAX-for-non-GN.patch";
      sha256 = "sha256-ATMvhSjpiGdGeIbpTCiXMeF/ZWPcZ99aoH4Xmv10+ps=";
    })
  ];

  postPatch = ''
    # Otherwise tries to ensure /var/run exists.
    sed -i "/install_subdir('run', install_dir: get_option('localstatedir'))/d" \
        qga/meson.build
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
    "--without-default-features"
    "--enable-user"
    "--disable-system"

    "--localstatedir=/var"
    "--sysconfdir=/etc"
    # Always use our Meson, not the bundled version, which doesn't
    # have our patches and will be subtly broken because of that.
    "--meson=meson"
    "--cross-prefix=${stdenv.cc.targetPrefix}"
    "--cpu=${stdenv.hostPlatform.uname.processor}"
  ] ++ lib.optional stdenv.hostPlatform.isStatic [
    "--static"
    "--extra-ldflags=-Wl,--allow-multiple-definition"
  ];

  dontWrapGApps = true;

  postFixup = ''
    rm -rf $out/nix-support
    rm -rf $out/share
  '';
  preBuild = "cd build";
}
