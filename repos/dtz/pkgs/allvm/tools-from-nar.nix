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
  narurl = "nar/5859db0fcd5ec0f9e514c6d46b0997faf0c0c4259e06ba6cb4b68199c6cc72d2.nar.xz";
  narHash = "sha256:0g7xx85ik3g18cv651cdc3mbckszbnrv291r1sa06dzlzq2v0pdi";
}
