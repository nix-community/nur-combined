{ pkgs, ... }:
{
  enable = true;
  package = pkgs.coredns.override {
    externalPlugins = [
      {
        name = "alternate";
        repo = "github.com/coredns/alternate";
        version = "d2ebc97c57b7878dd269c9a8783c50622f23c6cf";
      }
    ];
    vendorHash = "sha256-hWmB7B3mdexfndUi5u/129PB/RqeHxMk+d2ExFPxOIQ=";
  };
  config = ''
    .:53 {
        forward . dns://223.5.5.5 dns://223.6.6.6 {
            force_tcp
            expire 20s
            max_fails 1
            policy sequential
            health_check 1s
        }
        alternate SERVFAIL REFUSED . dns://127.0.0.1:1053
        log
        cache
        prometheus localhost:9092
    }
    .:1053 {
        forward . tls://223.6.6.6 {
            tls_servername dns.alidns.com
            expire 20s
            max_fails 1
            policy sequential
            health_check 1s
        }
        forward . tls://8.8.8.8 tls://8.8.4.4 {
            tls_servername dns.google
            expire 20s
            max_fails 1
            policy sequential
            health_check 1s
        }
        forward . tls://1.1.1.1 tls://1.0.0.1 {
            expire 20s
            max_fails 1
            policy sequential
            health_check 1s
        }
    }
  '';
}
