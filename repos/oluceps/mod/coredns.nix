{
  flake.modules.nixos.coredns = {
    services.coredns = {
      enable = true;
      config = ''
        .:53 {
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
    };
  };
}
