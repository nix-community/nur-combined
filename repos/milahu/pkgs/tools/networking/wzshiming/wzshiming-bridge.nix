{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "wzshiming-bridge";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "wzshiming";
    repo = "bridge";
    rev = "v${version}";
    hash = "sha256-1QfqZqFFF24nrxYjmp8/XjF7wKfQ3K6C9ObU3+zgHIg=";
  };

  vendorHash = "sha256-b/HznQSZ8NdUFLbTFu+JO9UXc0kFskBZTGBqchM2tNw=";

  ldflags = [ "-s" "-w" ];

  # tests require network access
  /*
    running tests
    --- FAIL: TestPortForward (10.17s)
        bridge_test.go:172: Get "http://[::]:44281": read tcp [::1]:57110->[::1]:44281: read: connection reset by peer
    --- FAIL: TestPortForwardWithRemoteListen (10.02s)
        bridge_test.go:223: Get "http://[::]:40707": dial tcp [::]:40707: connect: connection refused
  */
  doCheck = false;

  meta = with lib; {
    description = "Birdge is a multi-level proxy that supports clients and servers with multiple protocols: SSHProxy, HTTPProxy, Socks4, Socks5, Shadowsocks";
    homepage = "https://github.com/wzshiming/bridge";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "bridge";
  };
}
