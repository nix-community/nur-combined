{ stdenv, fetchgit, json_c, libubox, ubus, uci, lua5_1, libnl }:

stdenv.mkDerivation rec {
  pname = "iwinfo";
  version = "2019-11-01";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "31dcef3169d29dc9bb11c6901fa7b2894438dc78";
    sha256 = "0fhskvh0rkchwrzjvgg73dj967m479skca5jlnfnmd0xy5b7jhg4";
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
