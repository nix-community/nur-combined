{ stdenv
, fetchFromGitHub
, bashInteractive
, libbsd
, linuxHeaders
, makeself
, musl
} :

stdenv.mkDerivation rec {
  pname = "enroot";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = pname;
    rev = "v${version}";
    sha256 = "1qm2pv4nd3ljcc88c644g9kr4zi2pmx1hpijyi01bbzagclf7p88";
  };

  enroot_makeself = "bin/enroot-makeself";
  prePatch = ''
    cp ${makeself}/bin/makeself ${enroot_makeself}
  '';

  patches = [ ./Makefile.patch ];

  inherit libbsd;
  musl_dev = "${musl.dev}";

  postPatch = ''
    substituteAllInPlace Makefile
    # needed for compgen
    substituteInPlace enroot.in \
      --replace "/usr/bin/env bash" "${bashInteractive}/bin/bash"
  '';

  buildInputs = [ linuxHeaders libbsd musl ];
  nativeBuildInputs = [ makeself ];

  makeFlags = [ "DESTDIR=" "prefix=$(out)" ];

  meta = with stdenv.lib; {
    description = "A simple, yet powerful tool to turn traditional container/OS images into unprivileged sandboxes.";
    homepage = "https://github.com/NVIDIA/enroot";
    license = licenses.asl20;
    platforms = platforms.linux;
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
