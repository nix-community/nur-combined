{ lib }:

let info = rec {
  name = "${pname}-${version}";
  pname = "allvm-tools";
  version = "2018-05-22-bf6536b";

  meta = with lib; {
    description = "ALLVM Tools (multiplexed)";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.ncsa;
    homepage = https://github.com/allvm/allvm-tools;
  };
};
in info // lib.from-nar {
  inherit (info) name;
  narurl = "nar/0f77fc768873b0a53b40ca034404a814085650ab74fd687067effda9198fdd58.nar.xz";
  narHash = "sha256:0hnr7awn64a9kjninnbkcav9cl3k2bwkxk25qk0z9dk1f69qf36r";
}
