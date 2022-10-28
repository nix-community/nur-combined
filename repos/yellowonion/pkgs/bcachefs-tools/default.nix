{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, docutils
, libuuid
, libscrypt
, libsodium
, keyutils
, liburcu
, zlib
, libaio
, zstd
, lz4
, python3Packages
, udev
, valgrind
, nixosTests
, fuse3
, fuseSupport ? false
}:

let info = lib.importJSON ./version.json;
    shorthash = lib.strings.substring 0 7 info.rev;
in
stdenv.mkDerivation {
  pname = "bcachefs-tools";
  version = "${shorthash}-git";

  src = fetchFromGitHub {inherit (info) owner repo rev sha256;};

  postPatch = ''
    substituteInPlace Makefile \
      --replace "pytest-3" "pytest --verbose" \
      --replace "INITRAMFS_DIR=/etc/initramfs-tools" \
                "INITRAMFS_DIR=${placeholder "out"}/etc/initramfs-tools" \
      --replace "doc/macro2rst.py" "python3 doc/macro2rst.py"
      sed -i 's/v0.1-nogit/${shorthash}-git/' Makefile
 '';

  nativeBuildInputs = [ pkg-config docutils ];

  buildInputs = [
    libuuid libscrypt libsodium keyutils liburcu zlib libaio
    zstd lz4 python3Packages.pytest udev valgrind
  ] ++ lib.optional fuseSupport fuse3;

  doCheck = false; # needs bcachefs module loaded on builder
  checkFlags = [ "BCACHEFS_TEST_USE_VALGRIND=no" ];
  checkInputs = [ valgrind ];

  preCheck = lib.optionalString fuseSupport ''
    rm tests/test_fuse.py
  '';

  buildFlags = [ "EXTRA_CFLAGS=-Wno-error=format-security"  ];
  installFlags = [ "PREFIX=${placeholder "out"}" ];

  passthru.tests = {
    smoke-test = nixosTests.bcachefs;
  };

  meta = with lib; {
    description = "Tool for managing bcachefs filesystems";
    homepage = "https://bcachefs.org/";
    license = licenses.gpl2;
    platforms = [ "x86_64-linux" ]; # does not build on aarch64, see https://github.com/koverstreet/bcachefs-tools/issues/39
  };
}
