{ reIf, ... }:
reIf {
  services.smartdns = {
    enable = true;
    config = ''
      bind 127.0.0.1:53  

      server-quic 223.5.5.5 -bootstrap-dns -exclude-default-group
      server-quic 223.5.5.5
      server-quic 223.6.6.6
      server tls://dot.pub
      server tls://dns.google 
    '';
  };
}
