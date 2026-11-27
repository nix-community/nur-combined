{
  lib,
  pkgsCross,
  fetchFromGitHub,
  cmake,
  ninja,
  gnu-efi,
  nix,
  nix-update-script,
  writeShellApplication,
}:

let
  version = "0-unstable-2026-10-29";
  rev = "8cdbd7b2c299159a9a03698e90c79b46c5ed267b";
  mingw = pkgsCross.mingw-msvcrt-x86_64;
  src = fetchFromGitHub {
    owner = "openzfsonwindows";
    repo = "zfs-efi";
    inherit rev;
    hash = "sha256-cIVAPcTldTdlbpDfdC496rk72aBbYQno+uxHyUraov8=";
  };
in
mingw.stdenv.mkDerivation {
  pname = "zfs-uefi";
  inherit version src;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  # Upstream's CMakeLists looks for gnu-efi under /usr/include/efi, which is not
  # available in the build sandbox.
  # GCC 14+ makes an implicit function declaration an error, which -w cannot
  # silence; the FreeBSD reader relies on the compat headers (and on the old
  # warning-only behaviour) for a few prototypes, so relax just that diagnostic.
  NIX_CFLAGS_COMPILE = ''
    -D_CRTIMP=
    -I${gnu-efi}/include/efi -I${gnu-efi}/include/efi/x86_64
    -Wno-error=implicit-function-declaration
    -Wno-error=implicit-int
    -Wno-error=int-conversion
  '';

  hardeningDisable = [ "all" ];

  # Upstream's mingw preset links the CRT, which gives the image imports that
  # firmware will not load; the patch drops the CRT and keeps libgcc.  The
  # second patch refuses encrypted blocks explicitly: the reader has no key
  # store and no AES, and without the check ciphertext just looks like a
  # corrupt block.
  patches = [
    ./nix.patch
    ./encrypted-dataset.patch
    ./key-store.patch
  ];

  # The AES-256-GCM and SHA-512 code lives next to this package, in crypto/,
  # and is compiled into the reader like its other engine sources.  It is plain
  # freestanding C with no libc, which is what the EFI image needs.
  postPatch = ''
    cp ${./crypto}/aesgcm.c ${./crypto}/aesgcm.h \
      ${./crypto}/sha512.c ${./crypto}/sha512.h ${./crypto}/sha512_consts.h \
      ${./crypto}/sha1.c ${./crypto}/sha1.h \
      src/engine/
    sed -i 's#    src/engine/nvlist.c#    src/engine/aesgcm.c src/engine/sha512.c src/engine/sha1.c src/engine/nvlist.c#' \
      CMakeLists.txt
  '';

  cmakeFlags = [
    "-DCMAKE_TOOLCHAIN_FILE=../mingw-amd64.cmake"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 zfs.efi $out/share/zfs-uefi/zfs.efi
    install -Dm644 ${src}/README.md $out/share/zfs-uefi/README.md
    install -Dm644 ${src}/LICENCE $out/share/zfs-uefi/LICENCE

    runHook postInstall
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-zfs-uefi";
    runtimeInputs = [ nix ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="zfs-uefi"
      ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [ "--version=branch" ];
        })
      } "$@"
    '';
  };

  meta = {
    description = "Read-only ZFS driver for UEFI, for use with Quibble";
    longDescription = ''
      A read-only ZFS driver, loaded from Quibble's `drivers/` directory, that
      puts an EFI simple file system on a pool so Windows can be booted from a
      dataset.

      The pool must stay inside FreeBSD's read-only feature set (create it with
      a `compatibility=` that keeps to it), and compression is limited to lz4,
      lzjb, zle and none.  Encrypted datasets are not readable yet.  The driver
      prompts on the firmware console for the passphrase (or a hex/raw key)
      while opening one, derives the wrapping key the way `zfs` does, and
      unwraps and MAC-verifies the dataset key; a wrong entry is re-prompted.
      Decrypting the dataset's blocks is not implemented, so the reader still
      reports that instead of failing the block's checksum.  `GetArcName` is not
      implemented, so `freeldr.ini` keeps the ordinary `multi(...)partition(N)`
      form, and `OpenZFS.sys` must be a boot-start driver in the guest.
    '';
    homepage = "https://github.com/openzfsonwindows/zfs-efi";
    license = lib.licenses.lgpl3Plus;
    # hostPlatform is Windows when cross-compiling; omit platforms so nixpkgs
    # does not reject this nested drv during the native package-set eval.
  };
}
