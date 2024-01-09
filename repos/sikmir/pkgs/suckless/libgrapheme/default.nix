{ lib, stdenv, fetchgit, buildPackages }:

stdenv.mkDerivation rec {
  pname = "libgrapheme";
  version = "2.0.2";

  src = fetchgit {
    url = "git://git.suckless.org/libgrapheme";
    rev = version;
    hash = "sha256-Or5Xs/Q/+CoEdKNpTHppzJ7ReABJ5+6v3tkTgjqTqAU=";
  };

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  makeFlags = [ "AR:=$(AR)" "CC:=$(CC)" "RANLIB:=$(RANLIB)" "BUILD_CC=$(CC_FOR_BUILD)" ];

  installFlags = [ "PREFIX=$(out)" "LDCONFIG=" ];

  meta = with lib; {
    description = "Unicode string library";
    homepage = "https://libs.suckless.org/libgrapheme/";
    license = licenses.isc;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
