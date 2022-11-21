{ lib, stdenv, fetchFromGitHub, pkg-config, autoreconfHook, libpsm2, libuuid, numactl
, enablePsm2 ? (stdenv.isx86_64 && stdenv.isLinux) }:

stdenv.mkDerivation rec {
  pname = "libfabric";
  version = "opx-rc1";

  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "cornelisnetworks";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256:10l86nlz8xg3463bkawi2nw4rnxsfkyfrr8536phz9w6d3jvdvbg";
  };

  nativeBuildInputs = [ pkg-config autoreconfHook ];

  buildInputs = [ libuuid ] ++ lib.optional enablePsm2 [ libpsm2 numactl ] ;

  configureFlags = [ (if enablePsm2 then "--enable-psm2=${libpsm2}" else "--disable-psm2") "--enable-opx" ];

  meta = with lib; {
    homepage = "https://ofiwg.github.io/libfabric/";
    description = "Open Fabric Interfaces";
    license = with licenses; [ gpl2 bsd2 ];
    platforms = platforms.all;
    maintainers = [ maintainers.bzizou ];
  };
}
