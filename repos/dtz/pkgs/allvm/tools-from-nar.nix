{ lib }:

let info = rec {
  name = "${pname}-${version}";
  pname = "allvm-tools";
  version = "2018-09-25-7e710b4";

  meta = with lib; {
    description = "ALLVM Tools (multiplexed)";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.ncsa;
    homepage = https://github.com/allvm/allvm-tools;
  };
};
in info // lib.from-nar {
  inherit (info) name;
  narurl = "nar/cce5118f82202a270925d1e4ca0c9b72335435ba1b331cd26089e285914fcb84.nar.xz";
  narHash = "sha256:0kgax9ix49wx444pf4qjhxk4kln1pnk657hqpxnm8iv9k53729z9";
}
