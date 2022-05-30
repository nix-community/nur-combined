{ lib, buildGoModule, fetchgit }:
buildGoModule rec {
  pname = "embgit";
  version = "0.3.6";

  src = fetchgit {
    url = "https://github.com/quiqr/embgit.git";
    rev = "${version}";
    #sha256 = "sha256:04i1ijch1crmgx49nnl1rbly15gwwwm3hic22v1hgsf0d3zhm0sn";
    sha256 = "sha256:1fr8p7p9czf3bw0k432kc2lcnv3kglkn5wnxw3gir935nn56iyk6";
  };

  vendorSha256 = "sha256:1298s8hyrw7v09hyc4ddkwxdwf0k294n95kv65467y0niw98j6sg";

  meta = with lib; {
    description = ''
      Embedded Git for electron apps
    '';
    homepage = "https://github.com/quiqr/embgit";
    license = licenses.mit;
  };
}
