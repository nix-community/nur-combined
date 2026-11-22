{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gettext,
  shadow,
  util-linux,
  runtimeShell,
}:

# Vendored from nixpkgs' last fuse_2 (nixos-24.11): seadrive-fuse needs
# the libfuse2 API, which current nixpkgs no longer ships.
stdenv.mkDerivation rec {
  pname = "libfuse2";
  version = "2.9.9";

  src = fetchFromGitHub {
    owner = "libfuse";
    repo = "libfuse";
    rev = "fuse-${version}";
    hash = "sha256-dgjM6M7xk5MHi9xPyCyvF0vq0KM8UCsEYBcMhkrdvfs=";
  };

  preAutoreconf = "touch config.rpath";

  patches = [
    ./fuse2-Do-not-set-FUSERMOUNT_DIR.patch
    ./fuse-2.9.9-closefrom-glibc-2-34.patch
  ]
  ++ lib.optional (
    stdenv.hostPlatform.isAarch64 || stdenv.hostPlatform.isLoongArch64
  ) ./fuse2-aarch64.patch;

  nativeBuildInputs = [
    autoreconfHook
    gettext
  ];

  outputs = [
    "bin"
    "out"
    "dev"
    "man"
  ];

  # Ensure that FUSE calls the setuid wrapper, not
  # $out/bin/fusermount. It falls back to calling fusermount in
  # $PATH, so it should also work on non-NixOS systems.
  NIX_CFLAGS_COMPILE = ''-DFUSERMOUNT_DIR="/run/wrappers/bin"'';

  preConfigure = ''
    substituteInPlace lib/mount_util.c \
      --replace-fail "/bin/mount" "${lib.getBin util-linux}/bin/mount" \
      --replace-fail "/bin/umount" "${lib.getBin util-linux}/bin/umount"
    substituteInPlace util/mount.fuse.c \
      --replace-fail "/bin/sh" "${runtimeShell}"
    export MOUNT_FUSE_PATH=$bin/bin

    # Do not install these files for fuse2 which are not useful for NixOS.
    export INIT_D_PATH=$TMPDIR/etc/init.d
    export UDEV_RULES_PATH=$TMPDIR/etc/udev/rules.d

    # This is for `setuid=`, and needs root permission anyway.
    # No need to use the SUID wrapper.
    substituteInPlace util/mount.fuse.c \
      --replace-fail '"su"' '"${lib.getBin shadow.su}/bin/su"'
    # NB: upstream's makeconf.sh is deliberately not used — autoreconfHook covers it.
  '';

  # tests get skipped in a sandbox
  doCheck = false;

  propagatedBuildOutputs = [ "out" ];

  meta = {
    description = "Kernel module and library for FUSE 2.x user space filesystems";
    homepage = "https://github.com/libfuse/libfuse";
    changelog = "https://github.com/libfuse/libfuse/releases/tag/fuse-${version}";
    platforms = lib.platforms.linux;
    license = with lib.licenses; [
      gpl2Only
      lgpl21Only
    ];
    maintainers = [ lib.maintainers.ataraxiasjel ];
  };
}
