{ stdenv, fetchgit, json_c, libubox, ubus, uci, lua5_1, libnl }:

stdenv.mkDerivation rec {
  pname = "iwinfo";
  version = "2020-01-05";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "bf2c1069a7f14d1af1e02c8edd2b7338f0355ac8";
    sha256 = "0r80mn1bpw50pf4s2w38bksdhm83inf3rwvhal2gw3ivx04bn1hn";
  };

  buildInputs = [ json_c libubox ubus uci lua5_1 libnl ];

  BACKENDS = [ "wl" "nl80211" ];

  NIX_CFLAGS_COMPILE = [
    "-D_GNU_SOURCE=1" # FNM_CASEFOLD
    "-I${libnl.dev}/include/libnl3"
  ];

  postPatch = ''
    substituteInPlace Makefile --replace -lnl-tiny "-lnl-3 -lnl-genl-3"
    substituteInPlace include/iwinfo.h --replace /usr/share $out/share
  '';

  installPhase = ''
    install -Dm755 iwinfo -t $out/bin
    install -Dm755 libiwinfo.so -t $out/lib
    install -D -t $out/share/libiwinfo hardware.txt
  '';
}
