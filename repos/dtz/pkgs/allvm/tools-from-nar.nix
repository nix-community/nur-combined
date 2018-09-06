{ lib }:

let info = rec {
  name = "${pname}-${version}";
  pname = "allvm-tools";
  version = "2018-09-05-8d3f495";

  meta = with lib; {
    description = "ALLVM Tools (multiplexed)";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.ncsa;
    homepage = https://github.com/allvm/allvm-tools;
  };
};
in info // lib.from-nar {
  inherit (info) name;
  narurl = "nar/4f6d0613bbba3dcc3dc3710b5fce28717ff0edc5b5c14a850c77cbd080f5f1bb.nar.xz";
  narHash = "sha256:06w0hzjgn3n8z2b96fpg2f1gp0mplq91jci9h855q3sbj46wxmsa";
}
