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
  narurl = "nar/1968b9e551d296b88917bfe6a3ef1d5abfb3c9d5d2a05d7c54a6e5296aa1c70d.nar.xz";
  narHash = "sha256:15vihm40gdc1d2bglm4z7xay8cpz9s8h1gmnchxy23qga2bdiz90";
}
