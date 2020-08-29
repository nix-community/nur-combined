{ lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "rds_exporter";
  version = "0.7.0";
  goPackagePath = "github.com/percona/rds_exporter";

  src = fetchFromGitHub {
    owner = "percona";
    repo = pname;
    rev = "v${version}";
    sha256 = "02h4n487wsrfcsfa8829zr5gchs3ay590i3h2gg9nxz32j78y00v";
  };

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "AWS RDS exporter for Prometheus ";
    homepage = "https://github.com/percona/rds_exporter";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
