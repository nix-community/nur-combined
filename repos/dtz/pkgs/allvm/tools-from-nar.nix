{ lib }:

let info = rec {
  name = "${pname}-${version}";
  pname = "allvm-tools";
  version = "2018-09-19-c1541b7";

  meta = with lib; {
    description = "ALLVM Tools (multiplexed)";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.ncsa;
    homepage = https://github.com/allvm/allvm-tools;
  };
};
in info // lib.from-nar {
  inherit (info) name;
  narurl = "nar/f9d27931d5882d9a6ac09140cc089ae50a05da24530a0b343ac0dbf5690068ed.nar.xz";
  narHash = "sha256:1kfj563g10qsh7f3z21zdd91d4arh4fdn4p0v6yj4mzk0vln52kg";
}
