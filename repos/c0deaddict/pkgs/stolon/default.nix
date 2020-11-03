{ lib, fetchFromGitHub, buildGoModule, etcd, postgresql }:

buildGoModule rec {
  name = "stolon";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "sorintlab";
    repo = name;
    rev = "v${version}";
    sha256 = "0spp9vr3cp7qhmna6gci427xf6k6h6qwfb6xv69zz2i81ycw4qfs";
  };

  vendorSha256 = "0cw9xv8qzyzkywwalg6336l50kfkmd4j316l3kvxdh34q7w4vj82";
  modSha256 = vendorSha256;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  checkInputs = [ postgresql ];

  # Travis CI is too slow for the integration test.
  doCheck = false;

  preCheck = ''
    export STOLON_TEST_STORE_BACKEND=etcdv3
    export ETCD_BIN=${etcd}/bin/etcd
	  export STKEEPER_BIN=$GOPATH/bin/keeper
	  export STSENTINEL_BIN=$GOPATH/bin/sentinel
	  export STPROXY_BIN=$GOPATH/bin/proxy
	  export STCTL_BIN=$GOPATH/bin/stolonctl
  '';

  meta = with lib; {
    homepage = "https://github.com/sorintlab/stolon";
    description = "PostgreSQL cloud native High Availability and more";
    license = licenses.asl20;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
