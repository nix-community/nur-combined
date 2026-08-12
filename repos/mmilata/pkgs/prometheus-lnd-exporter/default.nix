{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "lndmon-unstable";
  version = "2020-01-09";

  src = fetchFromGitHub {
    owner = "lightninglabs";
    repo = "lndmon";
    sha256 = "0d4z8yv2459wsi4c91qs5an13acn73fd8s321xya5vxxiyf51q24";
    rev = "2c7c5ce0fcb4e7eef4df60efe8a644587a309f6c";
  };

  modSha256 = "1hq9i5k40jr1873zw11ld9gn98ny67zpvjxnbwqap96sk27xg1yh";

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "Prometheus exporter for lnd (Lightning Network Daemon)";
    license = licenses.mit;
    maintainers = with maintainers; [ mmilata ];
  };
}
