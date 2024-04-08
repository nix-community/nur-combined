{
  stdenv,
  libsrs2,
  testers,
  cyrus-imapd,
  lib,
  unixtools,
  autoreconfHook,
  fetchFromGitHub,
  pkg-config,
  libcap,
  bison,
  cyrus_sasl,
  icu,
  jansson,
  flex,
  libbsd,
  libuuid,
  pcre2,
  openssl,
  cunit,
  coreutils,
  perl,
  # CalDAV, CardDAV
  withHttp ? true,
  brotli,
  libical,
  libxml2,
  nghttp2,
  shapelib,
  zlib,
  rsync,
  withJMAP ? true,
  libchardet,
  wslay,
  withXapian ? true,
  xapian,
  withCalalarmd ? true,
  withMySQL ? false,
  libmysqlclient,
  withPgSQL ? false,
  withNNTP ? false,
  postgresql,
  withSQLite ? true,
  sqlite,
  makeWrapper,
  valgrind,
  fig2dev,
  sources,
}:
stdenv.mkDerivation rec {
  pname = "cyrus-imapd";
  version = "3.8.2";
  inherit (sources.cyrus-imapd) src;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    autoreconfHook
  ];
  buildInputs =
    [
      unixtools.xxd
      pcre2
      flex
      valgrind
      fig2dev
      perl
      cyrus_sasl.dev
      icu
      jansson
      libbsd
      libuuid
      openssl
      zlib
      bison
      libsrs2
    ]
    ++ lib.optional stdenv.isLinux libcap
    ++ lib.optionals (withHttp || withCalalarmd || withJMAP) [
      brotli.dev
      libical.dev
      libxml2.dev
      nghttp2.dev
      shapelib
    ]
    ++ lib.optionals withJMAP [
      libchardet
      wslay
    ]
    ++ lib.optional withXapian [
      rsync
      xapian
    ]
    ++ lib.optional withMySQL libmysqlclient
    ++ lib.optional withPgSQL postgresql
    ++ lib.optional withSQLite sqlite;

  enableParallelBuilding = true;
  #strictDeps = true;

  # Copied from debian deb package
  patches = [
    ./patches/0002-Shutdown-and-close-sockets-cleanly.patch
    ./patches/0003-Fix-syslog-prefix.patch
    ./patches/0006-Fix-paths-on-NixOS-in-tools-rehash.patch
    ./patches/0009-Normalize-the-authentication-ID.patch
    ./patches/0018-increase-test-timeout.patch
    ./patches/0019-propagate-XXFLAGS.patch
  ];

  postPatch = ''
    patchShebangs cunit/*.pl
    patchShebangs imap/promdatagen
    patchShebangs tools/*

    echo ${version} > VERSION

    substituteInPlace cunit/command.testc \
      --replace-warn "/usr/bin/touch" "${coreutils}/bin/touch" \
      --replace-warn "/bin/echo" "${coreutils}/bin/echo" \
      --replace-warn "/usr/bin/tr" "${coreutils}/bin/tr" \
      --replace-warn "/bin/sh" "${stdenv.shell}"


    substituteInPlace perl/imap/Makefile.PL.in \
      --replace-fail  '"$LIB_SASL' '"-L${zlib}/lib -L${libuuid.lib}/lib -L${cyrus_sasl.out}/lib -L${pcre2.out}/lib -lpcre2-posix $LIB_SASL'
    substituteInPlace perl/sieve/managesieve/Makefile.PL.in \
      --replace-fail  '"$LIB_SASL' '"-L${zlib}/lib -L${libuuid.lib}/lib -L${cyrus_sasl.out}/lib $LIB_SASL'

    # failing test case in 3.4.3
    substituteInPlace cunit/conversations.testc \
      --replace-warn 'TESTCASE("re: no re: foobar", "nore:foobar");' ""
  '';

  postInstall = ''
    install -Dm755 ${./cyrus-cli} $out/bin/cyrus
  '';

  postFixup = ''
    substituteInPlace $out/bin/cyrus \
      --replace-fail 'PLACEHOLDER_BINPATH' "$out/bin"
    wrapProgram $out/bin/cyradm --set PERL5LIB $(find $out/lib/perl5 -type d | tr "\\n" ":")
  '';

  configureFlags =
    [
      "--with-openssl=yes"
      "--enable-autocreate"
      "--enable-srs"
      "--enable-idled"
      "--enable-murder"
      "--enable-backup"
      "--enable-replication"
      "--enable-unit-tests"
      "--with-pidfile=/run/cyrus/master.pid"
      "--with-zlib=${zlib}"
      "--with-libcap=${libcap}"
    ]
    ++ lib.optional (withHttp || withCalalarmd || withJMAP) "--enable-http"
    ++ lib.optional withJMAP "--enable-jmap"
    ++ lib.optional withNNTP "--enable-nntp"
    ++ lib.optional withXapian "--enable-xapian"
    ++ lib.optional withCalalarmd "--enable-calalarmd"
    ++ lib.optional withMySQL "--with-mysql"
    ++ lib.optional withPgSQL "--with-pgsql"
    ++ lib.optional withSQLite "--with-sqlite";

  checkInputs = [cunit];
  doCheck = true;

  passthru.tests = {
    version = testers.testVersion {
      package = cyrus-imapd;
      command = "${cyrus-imapd}/libexec/master -V";
    };
  };

  meta = with lib; {
    homepage = "https://www.cyrusimap.org";
    description = "Cyrus IMAP is an email, contacts and calendar server";
    license = with licenses; [bsdOriginal];
    mainProgram = "cyrus";
    #maintainers = with maintainers; [moraxyc];
    platforms = platforms.unix;
  };
}
