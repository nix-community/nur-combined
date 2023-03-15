{ lib, ... }:
let
  inherit (lib) version;
  utilisedPort = 8053;

  libredns = {
    address_data = "116.202.176.26";
    tls_auth_name = "dot.libredns.gr";
    tls_port = 853;
  };

  ahaDnsNl = {
    address_data = "5.2.75.75";
    tls_auth_name = "dot.nl.ahadns.net";
    tls_port = 853;
  };

  ahaDnsLa = {
    address_data = "45.67.219.208";
    tls_auth_name = "dot.la.ahadns.net";
    tls_port = 853;
  };

  quadNine = {
    address_data = "9.9.9.9";
    tls_auth_name = "dns.quad9.net";
    tls_port = 853;
  };

  appliedPrivacy = {
    address_data = "146.255.56.98";
    tls_auth_name = "dot1.applied-privacy.net";
    tls_port = 853;
  };

  loggingOptions = if version < "22.11" then
    { }
  else if version < "23.05" then {
    debugLogging = true;
  } else {
    logLevel = "info";
  };
in {
  services.stubby = {
    enable = true;
    settings = {
      upstream_recursive_servers =
        [ libredns ahaDnsLa ahaDnsNl quadNine appliedPrivacy ];
      edns_client_subnet_private = 1;
      round_robin_upstreams = 1;
      idle_timeout = 10000;
      listen_addresses = [ "0.0.0.0@${builtins.toString utilisedPort}" ];
      tls_query_padding_blocksize = 128;
      tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
      dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
      resolution_type = "GETDNS_RESOLUTION_STUB";
    };
  } // loggingOptions;

  networking.firewall.allowedTCPPorts = [ utilisedPort ];
  networking.firewall.allowedUDPPorts = [ utilisedPort ];
}
