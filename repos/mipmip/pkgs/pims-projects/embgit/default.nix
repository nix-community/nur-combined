{ lib, buildGoModule, fetchgit }:
buildGoModule rec {
  pname = "embgit";
  version = "0.6.0";

  src = fetchgit {
    url = "https://github.com/quiqr/embgit.git";
    rev = "${version}";
    #sha256 = "sha256:04i1ijch1crmgx49nnl1rbly15gwwwm3hic22v1hgsf0d3zhm0sn";
    sha256 = "sha256:0000000000000000000000000000000000000000000000000000";
  };

  vendorSha256 = "sha256:0000000000000000000000000000000000000000000000000000";

  meta = with lib; {
    description = ''
      Embedded Git for electron apps
    '';
    homepage = "https://github.com/quiqr/embgit";
    license = licenses.mit;
  };
}
