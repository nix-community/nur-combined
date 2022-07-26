{ lib
, stdenv
, fetchgit
, autoconf
, automake
, gettext
, libtool
, pkg-config
, libkrb5
, linuxPackages
, which
, mpi
, keyutils
, gss
, openssl
, libnl
, libyaml
, zlib
, glib
, libuuid
, attr
, enableServer ? false
, enableClient ? true
}:

let
  pname = "lustre";
  version = "2.15.0";

  inherit (linuxPackages) kernel;
  inherit (kernel) modDirVersion;

  boolToVerb = b: if b then "enable" else "disable";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchgit {
    url = "git://git.whamcloud.com/fs/lustre-release.git";
    rev = "${version}";
    hash = "sha256-8VcUBvDph3xxqWtD/pDJMr3B2aHcGDa5co6y3VFEfIQ=";
  };

  nativeBuildInputs = [
    # Not using autoreconfHook because of custom autogen.sh
    autoconf
    automake
    gettext
    libtool
    pkg-config
    which
    mpi # mpicc
  ];

  buildInputs = [
    libkrb5
    keyutils
    gss
    openssl.dev
    libnl.dev
    attr.dev
    glib
    libuuid
    libyaml
    zlib
  ];

  preConfigure = ''
    bash autogen.sh
  '';

  configureFlags = [
    "--with-linux=${kernel.dev}/lib/modules/${modDirVersion}/source"
    "--with-linux-obj=${kernel.dev}/lib/modules/${modDirVersion}/build"
    "--${boolToVerb enableServer}-server"
    "--${boolToVerb enableClient}-client"
  ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
  ];

  NIX_CFLAGS_COMPILE = toString [
    "-Wno-incompatible-pointer-types"
  ];

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.gpl2;
    description = "A parallel file system for HPC clusters";
    homepage = "https://www.lustre.org/";
    platforms = lib.platforms.linux;
  };
}
