{ lib, stdenv, fetchurl, zlib, readline, ncurses
, tcl

# for tests
, python3Packages, sqldiff, sqlite-analyzer, tracker

# uses readline & ncurses for a better interactive experience if set to true
, interactive ? false

# https://sqlite.org/cgi/src/doc/reuse-schema/doc/shared_schema.md
# The shared-schema patch allows databases to share in-memory schema objects
# with other databases in the same process in order to save memory.
#, sqliteBranch ? "reuse-schema"

, sqliteBranch ? null

, gitUpdater
}:

let
  archiveVersion = import ./archive-version.nix lib;
in

let
  fetchSqliteTarball = { rev, hash }: fetchurl {
    name = "SQLite.tar.gz";
    url = "https://sqlite.org/cgi/src/tarball/${rev}/SQLite.tar.gz";
    inherit hash;
    # the download can hang, so make it verbose
    curlOpts = "--verbose";
  };
in

let
  versionAttrs = (
    if sqliteBranch == null then
      rec {
        # nixpkgs-update: no auto update
        # NB! Make sure to update ./tools.nix src (in the same directory).
        version = "3.45.1";
        hash = "sha256-lP2afdRDHXIEwfdv4eXs0tZ+R6suSzWJFbN0u1jPNn4=";
        rev = "version-${version}";
      }
    else if sqliteBranch == "reuse-schema" then
      rec {
        #rev = "reuse-schema-3.45"; # not constant
        # https://sqlite.org/cgi/src/timeline?r=reuse-schema
        # 2024-01-30
        version = "3.45-${builtins.substring 0 16 rev}";
        rev = "f98a99fce5dc0aa5dd90e53f764e1b19b71c3a80632817b566dd241ce584beff";
        hash = "sha256-UwytcxfVS4tHyod/VyIGyolY82j/1T9+kElrWUIw7L8=";
      }
    else throw "unknown sqliteBranch ${sqliteBranch}"
  );

  pnameSuffix = if sqliteBranch == null then "" else "-${sqliteBranch}";
in

stdenv.mkDerivation rec {
  pname = "sqlite${lib.optionalString interactive "-interactive"}${pnameSuffix}";

  inherit (versionAttrs) version;

  src = fetchSqliteTarball {
    inherit (versionAttrs) rev hash;
  };

  # fossil rev 087b8b41c6ed76b55c11315e7e95679d67590be20ae21108b593d00bb7d1c57a
  # git rev b419452c7e5718d4151ed845d5b2ddd0e6ac0d05
  # # define utf8_printf fprintf
  # # define raw_printf fprintf

  postPatch = ''
    sed -i 's|/usr/bin/file|file|' configure
    # fix: implicit declaration of function raw_printf
    # fix: implicit declaration of function utf8_printf
    substituteInPlace src/shell.c.in \
      --replace-warn raw_printf fprintf \
      --replace-warn utf8_printf fprintf
    # dont install to $tcl/lib/tcl8.6/sqlite3
    substituteInPlace Makefile.in \
      --replace-warn "\''${HAVE_TCL:1=tcl_install}" ""
  '';

  outputs = [ "bin" "dev" "out" ];
  separateDebugInfo = stdenv.isLinux;

  buildInputs = [ zlib ] ++ lib.optionals interactive [ readline ncurses ];

  nativeBuildInputs = [
    tcl
  ];

  # required for aarch64 but applied for all arches for simplicity
  preConfigure = ''
    patchShebangs configure
  '';

  configureFlags = [ "--enable-threadsafe" ] ++ lib.optional interactive "--enable-readline";

  env.NIX_CFLAGS_COMPILE = toString ([
    "-DSQLITE_ENABLE_COLUMN_METADATA"
    "-DSQLITE_ENABLE_DBSTAT_VTAB"
    "-DSQLITE_ENABLE_JSON1"
    "-DSQLITE_ENABLE_FTS3"
    "-DSQLITE_ENABLE_FTS3_PARENTHESIS"
    "-DSQLITE_ENABLE_FTS3_TOKENIZER"
    "-DSQLITE_ENABLE_FTS4"
    "-DSQLITE_ENABLE_FTS5"
    "-DSQLITE_ENABLE_RTREE"
    "-DSQLITE_ENABLE_STMT_SCANSTATUS"
    "-DSQLITE_ENABLE_UNLOCK_NOTIFY"
    "-DSQLITE_SOUNDEX"
    "-DSQLITE_SECURE_DELETE"
    "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    "-DSQLITE_MAX_EXPR_DEPTH=10000"
  ] ++ lib.optionals (sqliteBranch == "reuse-schema") [
    "-DSQLITE_ENABLE_SHARED_SCHEMA"
  ]);

  # Test for features which may not be available at compile time
  preBuild = ''
    # Use pread(), pread64(), pwrite(), pwrite64() functions for better performance if they are available.
    if cc -Werror=implicit-function-declaration -x c - -o "$TMPDIR/pread_pwrite_test" <<< \
      ''$'#include <unistd.h>\nint main()\n{\n  pread(0, NULL, 0, 0);\n  pwrite(0, NULL, 0, 0);\n  return 0;\n}' 2>/dev/null; then
      echo "preBuild: using pread and pwrite"
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -DUSE_PREAD"
    fi
    if cc -Werror=implicit-function-declaration -x c - -o "$TMPDIR/pread64_pwrite64_test" <<< \
      ''$'#include <unistd.h>\nint main()\n{\n  pread64(0, NULL, 0, 0);\n  pwrite64(0, NULL, 0, 0);\n  return 0;\n}' 2>/dev/null; then
      echo "preBuild: using pread64 and pwrite64"
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -DUSE_PREAD64"
    elif cc -D_LARGEFILE64_SOURCE -Werror=implicit-function-declaration -x c - -o "$TMPDIR/pread64_pwrite64_test" <<< \
      ''$'#include <unistd.h>\nint main()\n{\n  pread64(0, NULL, 0, 0);\n  pwrite64(0, NULL, 0, 0);\n  return 0;\n}' 2>/dev/null; then
      echo "preBuild: using pread64 and pwrite64 with _LARGEFILE64_SOURCE"
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -DUSE_PREAD64 -D_LARGEFILE64_SOURCE"
    fi

    # Necessary for FTS5 on Linux
    export NIX_LDFLAGS="$NIX_LDFLAGS -lm"

    echo ""
    echo "NIX_CFLAGS_COMPILE = $NIX_CFLAGS_COMPILE"
    echo ""
  '';

  postInstall = ''
    # Do not contaminate dependent libtool-based projects with sqlite dependencies.
    sed -i $out/lib/libsqlite3.la -e "s/dependency_libs=.*/dependency_libs='''/"
  '';

  doCheck = false; # fails to link against tcl

  passthru = {
    tests = {
      inherit (python3Packages) sqlalchemy;
      inherit sqldiff sqlite-analyzer tracker;
    };

    updateScript = gitUpdater {
      # No nicer place to look for latest version.
      url = "https://github.com/sqlite/sqlite.git";
      # Expect tags like "version-3.43.0".
      rev-prefix = "version-";
    };
  };

  meta = with lib; {
    changelog = "https://www.sqlite.org/releaselog/${lib.replaceStrings [ "." ] [ "_" ] version}.html";
    description = "A self-contained, serverless, zero-configuration, transactional SQL database engine";
    downloadPage = "https://sqlite.org/download.html";
    homepage = "https://www.sqlite.org/";
    license = licenses.publicDomain;
    mainProgram = "sqlite3";
    maintainers = with maintainers; [ eelco np ];
    platforms = platforms.unix ++ platforms.windows;
    pkgConfigModules = [ "sqlite3" ];
  };
}
