{ stdenv, fetchgit, json_c, libubox, ubus, uci, lua5_1, libnl }:

stdenv.mkDerivation rec {
  pname = "iwinfo";
  version = "2019-11-26";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "a6f6c053481fb5bb29fc8357fb107400100a0658";
    sha256 = "1hx8c7kcp9h7gnyim18xfarvm70a6yy4xs01gn5jxc7cvibbzka0";
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
