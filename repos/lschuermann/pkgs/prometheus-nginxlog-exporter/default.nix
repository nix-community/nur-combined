{ buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "prometheus-nginxlog-exporter-${version}";
  version = "1.2.0";

  owner = "martin-helmich";
  repo = "prometheus-nginxlog-exporter";
  goPackagePath = "github.com/${owner}/${repo}";

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "v${version}";
    sha256 = "1g9lsxqqy97ss4gv0xynw7nf554pymrd1y756589f9hb49kp8h82";
  };
}
