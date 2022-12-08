{ lib
, stdenv
, fetchurl
, perl
, libiconv
, zlib
, popt
, enableACLs ? lib.meta.availableOn stdenv.hostPlatform acl
, acl
, enableLZ4 ? true
, lz4
, enableOpenSSL ? true
, openssl
, enableXXHash ? true
, xxHash
, enableZstd ? true
, zstd
, nixosTests
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "rsync-bpc";
  version = "7215af4f16b729098193d7dde5a8c3c8c4ae80de";
  date = "2021-07-24";

  src = fetchFromGitHub ({
    owner = "backuppc";
    repo = "rsync-bpc";
    rev = version;
    fetchSubmodules = false;
    sha256 = "sha256-CXGeSWZF0OOhwo+yndkd0ppYILHELBiZIDhHN7BqVYc=";
  });

  nativeBuildInputs = [ perl ];

  buildInputs = [ libiconv zlib popt ]
    ++ lib.optional enableACLs acl
    ++ lib.optional enableZstd zstd
    ++ lib.optional enableLZ4 lz4
    ++ lib.optional enableOpenSSL openssl
    ++ lib.optional enableXXHash xxHash;

  configureFlags = [
    "--with-nobody-group=nogroup"

    # disable the included zlib explicitly as it otherwise still compiles and
    # links them even.
    "--with-included-zlib=no"
  ];

  enableParallelBuilding = true;

  passthru.tests = { inherit (nixosTests) rsyncd; };

  meta = with lib; {
    description = "Fast incremental file transfer utility";
    homepage = "https://rsync.samba.org/";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with lib.maintainers; [ ehmry kampfschlaefer ivan ];
  };
}
