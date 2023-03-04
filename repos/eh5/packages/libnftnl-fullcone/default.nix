{ lib
, stdenv
, fetchurl
, autoreconfHook
, pkg-config
, libmnl
}:
stdenv.mkDerivation rec {
  version = "1.2.4";
  pname = "libnftnl";

  src = fetchurl {
    url = "https://netfilter.org/projects/${pname}/files/${pname}-${version}.tar.bz2";
    hash = "sha256-wP4jO+TN/XA+fVl37462P8vx0AUrYEThsj1HyjViR38=";
  };

  patches = [
    (fetchurl {
      url = "https://github.com/fullcone-nat-nftables/libnftnl-1.2.4-with-fullcone/commit/05fad33b15dba2a3be7e337470a5d1fb3cb260bf.diff";
      sha256 = "sha256-9GMNa3LBUNVLXGHgNRBJRtUWGlm5M3hM48mmaZddUcw=";
    })
  ];

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ libmnl ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A userspace library providing a low-level netlink API to the in-kernel nf_tables subsystem (with fullcone support)";
    homepage = "https://netfilter.org/projects/libnftnl/";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ fpletz ajs124 ];
  };
}
