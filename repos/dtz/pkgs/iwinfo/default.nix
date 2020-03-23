{ stdenv, lib, fetchgit, json_c, libubox, ubus, uci, lua5_1
, libnl, libnl-tiny, withTiny ? true }:

stdenv.mkDerivation rec {
  pname = "iwinfo";
  version = "2020-03-22";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "9f5a7c4f9b78cb2de8fe5dd7af55bf0221706402";
    sha256 = "12dkaffy0yhlryssg03mkwk36syhi3k63c5pmlaz0lp89550yc2f";
  };

  buildInputs = [
    json_c
    libubox ubus uci
    lua5_1
    (if withTiny then libnl-tiny else libnl)
  ];

  BACKENDS = [ "wl" "nl80211" ];

  NIX_CFLAGS_COMPILE = [
    "-D_GNU_SOURCE=1" # FNM_CASEFOLD
  ] ++ lib.optional (!withTiny) "-I${libnl.dev}/include/libnl3"
    ++ lib.optional withTiny "-I${libnl-tiny}/include/libnl-tiny";

  postPatch = ''
    # Fixup path used to find 'hardware.txt'
    substituteInPlace include/iwinfo.h --replace /usr/share $out/share
  '' + lib.optionalString (!withTiny) ''
    substituteInPlace Makefile --replace -lnl-tiny "-lnl-3 -lnl-genl-3"
  '';

  # TODO: install more bits:
  # * lua bindings
  # * headers
  installPhase = ''
    install -Dm755 iwinfo -t $out/bin
    install -Dm755 libiwinfo.so -t $out/lib
    install -D -t $out/share/libiwinfo hardware.txt
  '';
}
