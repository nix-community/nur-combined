{ lib, buildGoModule, fetchgit }:
buildGoModule rec {
  pname = "embgit";
  version = "0.3.2";

  src = fetchgit {
    url = "https://github.com/poppygo/embgit.git";
    rev = "${version}";
    sha256 = "sha256:04i1ijch1crmgx49nnl1rbly15gwwwm3hic22v1hgsf0d3zhm0sn";
  };

  vendorSha256 = "sha256:1298s8hyrw7v09hyc4ddkwxdwf0k294n95kv65467y0niw98j6sg";

  meta = with lib; {
    description = ''
      Embedded Git for electron apps
    '';
    homepage = "https://github.com/poppygo/embgit";
    license = licenses.mit;
  };
}
