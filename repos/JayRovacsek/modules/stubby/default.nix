let
  utilisedPort = 8053;
  libredns = {
    address_data = "116.202.176.26";
    tls_auth_name = "dot.libredns.gr";
    tls_port = 853;
  };
  ahaDnsAu = {
    address_data = "103.73.64.132";
    tls_auth_name = "dot.au.ahadns.net";
    tls_port = 853;
  };
  ahaDnsNo = {
    address_data = "185.175.56.133";
    tls_auth_name = "dot.no.ahadns.net";
    tls_port = 853;
  };
  ahaDnsNl = {
    address_data = "5.2.75.75";
    tls_auth_name = "dot.nl.ahadns.net";
    tls_port = 853;
  };
  ahaDnsNy = {
    address_data = "185.213.26.187";
    tls_auth_name = "dot.ny.ahadns.net";
    tls_port = 853;
  };
  jabberDe = {
    address_data = "94.16.114.254";
    tls_auth_name = "jabber-germany.de";
    tls_port = 853;
  };
in {
  services.stubby = {
    enable = true;
    settings = {
      upstream_recursive_servers =
        [ libredns ahaDnsAu ahaDnsNo ahaDnsNl ahaDnsNy jabberDe ];
      edns_client_subnet_private = 1;
      round_robin_upstreams = 1;
      idle_timeout = 10000;
      listen_addresses = [ "0.0.0.0@${builtins.toString utilisedPort}" ];
      tls_query_padding_blocksize = 128;
      tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
      dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
      resolution_type = "GETDNS_RESOLUTION_STUB";
    };
  };

  networking.firewall.allowedTCPPorts = [ utilisedPort ];
  networking.firewall.allowedUDPPorts = [ utilisedPort ];
}
