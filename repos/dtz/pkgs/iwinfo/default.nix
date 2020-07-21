{ stdenv, lib, fetchgit, json_c, libubox, ubus, uci, lua5_1
, libnl, libnl-tiny, withTiny ? true }:

stdenv.mkDerivation rec {
  pname = "iwinfo";
  version = "2020-06-03";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "2faa20e5e9d107b97e393a4eb458370e80b4d720";
    sha256 = "0aq48cw8ipwidcbi9n0b9yb8v10hnqyjsz6yiizq86agjrsr046f";
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
