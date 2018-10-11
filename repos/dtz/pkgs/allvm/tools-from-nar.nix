{ lib }:

let info = rec {
  name = "${pname}-${version}";
  pname = "allvm-tools";
  version = "2018-10-10-49fddb9";

  meta = with lib; {
    description = "ALLVM Tools (multiplexed)";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.ncsa;
    homepage = https://github.com/allvm/allvm-tools;
  };
};
in info // lib.from-nar {
  inherit (info) name;
  narurl = "nar/9ae340db7f677677ae11a8182218fb4b8b87d1c30cfade9bbff1538891ad8548.nar.xz";
  narHash = "sha256:0j5wd5v47lmdqcrcjksjyl0gp2avvp8by9s08ic9541m0hhwwa2a";
}
