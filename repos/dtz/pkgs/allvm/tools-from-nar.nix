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
  narurl = "nar/40168c210b6648ffb8276d0e37b2cd5c320414954c89b6dc78b8a71b2a19a13a.nar.xz";
  narHash = "sha256:0r22d7p57vzlp6vq6j391dv9ibcwzlhhcpf0a518c5mlq0hmdpk6";
}
