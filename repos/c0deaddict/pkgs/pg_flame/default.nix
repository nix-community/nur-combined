{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  name = "pg_flame";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "mgartner";
    repo = "pg_flame";
    rev = "v${version}";
    sha256 = "1a03vxqnga83mhjp7pkl0klhkyfaby7ncbwm45xbl8c7s6zwhnw2";
  };

  vendorSha256 = "0j7qpvji546z0cfjijdd66l0vsl0jmny6i1n9fsjqjgjpwg26naq";
  modSha256 = vendorSha256;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    homepage = "https://github.com/mgartner/pg_flame";
    description = "A flamegraph generator for Postgres EXPLAIN ANALYZE output";
    license = licenses.mit;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
