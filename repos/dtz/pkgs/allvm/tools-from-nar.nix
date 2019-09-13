{ lib }:

let info = rec {
  name = "${pname}-${version}";
  pname = "allvm-tools";
  version = "2019-04-09-0a4d2cf";

  meta = with lib; {
    description = "ALLVM Tools (multiplexed)";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.ncsa;
    homepage = https://github.com/allvm/allvm-tools;
  };
};
in info // lib.from-nar {
  inherit (info) name;
  narurl = "nar/e50213d3724f6fa21a35d5552b8a3461851a994f7e991ffe0ab1ad815d93b4f1.nar.xz";
  narHash = "sha256:1cyx5wiwgbil3fdzviqs8i8jyc4avqv1zgvx12ipmqwsx4axklyz";
}
