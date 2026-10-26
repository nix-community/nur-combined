{
  lib,
  nodeID,
  address,
  port,
  adminPort ? 19329,
  spiffeID,
  allowedIDs,
  trustDomain,
  spireSocket,
  extraConnectPorts ? { },
  extraConnectPolicies ? { },
}:
let
  sds = name: {
    inherit name;
    sds_config = {
      resource_api_version = "V3";
      api_config_source = {
        api_type = "GRPC";
        transport_api_version = "V3";
        grpc_services = [ { envoy_grpc.cluster_name = "spire_agent"; } ];
      };
    };
  };
  privateDestinations = [
    "0.0.0.0/8"
    "10.0.0.0/8"
    "100.64.0.0/10"
    "127.0.0.0/8"
    "169.254.0.0/16"
    "172.16.0.0/12"
    "192.0.0.0/24"
    "192.168.0.0/16"
    "198.18.0.0/15"
    "224.0.0.0/4"
    "240.0.0.0/4"
    "::/128"
    "::1/128"
    "::ffff:0:0/96"
    "200::/7"
    "fc00::/7"
    "fe80::/10"
    "fec0::/10"
    "ff00::/8"
  ];
  cidrRange =
    cidr:
    let
      parts = lib.splitString "/" cidr;
    in
    {
      address_prefix = builtins.head parts;
      prefix_len = lib.toInt (builtins.elemAt parts 1);
    };
  dnsCache = {
    name = "internet_dns";
    dns_lookup_family = "ALL";
    max_hosts = 4096;
    dns_query_timeout = "5s";
    # Remove private answers before selecting a destination. RBAC also
    # checks literals and the selected address before requests proceed.
    resolved_address_filter.ranges = map cidrRange privateDestinations;
  };
  ipPermission = cidr: {
    matcher = {
      name = "envoy.rbac.matchers.upstream_ip_port";
      typed_config = {
        "@type" =
          "type.googleapis.com/envoy.extensions.rbac.matchers.upstream_ip_port.v3.UpstreamIpPortMatcher";
        upstream_ip = cidrRange cidr;
      };
    };
  };
  portPermission = port: {
    matcher = {
      name = "envoy.rbac.matchers.upstream_ip_port";
      typed_config = {
        "@type" =
          "type.googleapis.com/envoy.extensions.rbac.matchers.upstream_ip_port.v3.UpstreamIpPortMatcher";
        upstream_port_range = {
          start = port;
          end = port + 1;
        };
      };
    };
  };
  connect = {
    header = {
      name = ":method";
      string_match.exact = "CONNECT";
    };
  };
  publicAddress = {
    not_rule.or_rules.rules = map ipPermission privateDestinations;
  };
  rules = {
    action = "ALLOW";
    policies =
      lib.mapAttrs
        (_: policy: {
          principals = map (id: { authenticated.principal_name.exact = id; }) policy.identities;
          permissions = [
            {
              and_rules.rules = [
                publicAddress
                connect
                (
                  if builtins.length policy.ports == 1 then
                    portPermission (builtins.head policy.ports)
                  else
                    { or_rules.rules = map portPermission policy.ports; }
                )
              ];
            }
          ];
        })
        (
          extraConnectPolicies
          // lib.mapAttrs' (
            id: ports:
            lib.nameValuePair "connect-${id}" {
              identities = [ id ];
              inherit ports;
            }
          ) extraConnectPorts
        )
      // {
        public-internet = {
          principals = [ { any = true; } ];
          permissions = [
            {
              and_rules.rules = [
                publicAddress
                {
                  or_rules.rules = [
                    {
                      and_rules.rules = [
                        connect
                        (portPermission 443)
                      ];
                    }
                    {
                      and_rules.rules = [
                        { not_rule = connect; }
                        {
                          or_rules.rules = map portPermission [
                            80
                            443
                          ];
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
  };
  rbac = name: {
    inherit name;
    typed_config = {
      "@type" = "type.googleapis.com/envoy.extensions.filters.http.rbac.v3.RBAC";
      inherit rules;
    };
  };
  settings = {
    admin = {
      address.socket_address = {
        address = "127.0.0.1";
        port_value = adminPort;
      };
    };
    node = {
      id = nodeID;
      cluster = "realm-internet";
    };
    static_resources = {
      listeners = [
        {
          name = "internet_mtls";
          address.socket_address = {
            address = address;
            port_value = port;
          };
          filter_chains = [
            {
              transport_socket = {
                name = "envoy.transport_sockets.tls";
                typed_config = {
                  "@type" = "type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext";
                  require_client_certificate = true;
                  common_tls_context = {
                    tls_params.tls_minimum_protocol_version = "TLSv1_3";
                    tls_certificate_sds_secret_configs = [ (sds spiffeID) ];
                    combined_validation_context = {
                      default_validation_context.match_typed_subject_alt_names = map (id: {
                        san_type = "URI";
                        matcher.exact = id;
                      }) allowedIDs;
                      validation_context_sds_secret_config = sds "spiffe://${trustDomain}";
                    };
                  };
                };
              };
              filters = [
                {
                  name = "envoy.filters.network.http_connection_manager";
                  typed_config = {
                    "@type" =
                      "type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager";
                    stat_prefix = "internet";
                    access_log = [
                      {
                        name = "envoy.access_loggers.stdout";
                        typed_config = {
                          "@type" = "type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog";
                          log_format = {
                            json_format = {
                              start_time = "%START_TIME%";
                              protocol = "%PROTOCOL%";
                              method = "%REQ(:METHOD)%";
                              authority = "%REQ(:AUTHORITY)%";
                              path = "%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%";
                              response_code = "%RESPONSE_CODE%";
                              response_flags = "%RESPONSE_FLAGS%";
                              duration_ms = "%DURATION%";
                              upstream_host = "%UPSTREAM_HOST%";
                              upstream_cluster = "%UPSTREAM_CLUSTER%";
                              caller_spiffe_id = "%DOWNSTREAM_PEER_URI_SAN%";
                              bytes_received = "%BYTES_RECEIVED%";
                              bytes_sent = "%BYTES_SENT%";
                            };
                          };
                        };
                      }
                    ];
                    # Twisted HTTPClient sends CONNECT as HTTP/1.0. Without this,
                    # Envoy answers 426 and Synapse cannot fetch server keys.
                    http_protocol_options.accept_http_10 = true;
                    http_protocol_options.allow_absolute_url = true;
                    upgrade_configs = [ { upgrade_type = "CONNECT"; } ];
                    route_config = {
                      name = "internet";
                      virtual_hosts = [
                        {
                          name = "public";
                          domains = [ "*" ];
                          routes = [
                            {
                              match.connect_matcher = { };
                              route = {
                                cluster = "internet";
                                timeout = "0s";
                                upgrade_configs = [
                                  {
                                    upgrade_type = "CONNECT";
                                    connect_config = { };
                                  }
                                ];
                              };
                            }
                            {
                              match.prefix = "/";
                              route = {
                                cluster = "internet";
                                timeout = "0s";
                              };
                            }
                          ];
                        }
                      ];
                    };
                    http_filters = [
                      {
                        name = "envoy.filters.http.dynamic_forward_proxy";
                        typed_config = {
                          "@type" = "type.googleapis.com/envoy.extensions.filters.http.dynamic_forward_proxy.v3.FilterConfig";
                          dns_cache_config = dnsCache;
                          save_upstream_address = true;
                        };
                      }
                      # Check CONNECT and normal HTTP before forwarding, including IP literals.
                      (rbac "envoy.filters.http.rbac")
                      {
                        name = "envoy.filters.http.router";
                        typed_config = {
                          "@type" = "type.googleapis.com/envoy.extensions.filters.http.router.v3.Router";
                          # Recheck the selected address before sending request headers.
                          # The DNS filter and downstream RBAC reject blocked destinations
                          # before the router opens an upstream connection.
                          upstream_http_filters = [
                            (rbac "envoy.filters.http.upstream_rbac")
                            {
                              name = "envoy.filters.http.upstream_codec";
                              typed_config."@type" =
                                "type.googleapis.com/envoy.extensions.filters.http.upstream_codec.v3.UpstreamCodec";
                            }
                          ];
                        };
                      }
                    ];
                  };
                }
              ];
            }
          ];
        }
      ];
      clusters = [
        {
          name = "spire_agent";
          connect_timeout = "1s";
          type = "STATIC";
          typed_extension_protocol_options."envoy.extensions.upstreams.http.v3.HttpProtocolOptions" = {
            "@type" = "type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions";
            explicit_http_config.http2_protocol_options = { };
          };
          load_assignment = {
            cluster_name = "spire_agent";
            endpoints = [ { lb_endpoints = [ { endpoint.address.pipe.path = spireSocket; } ]; } ];
          };
        }
        {
          name = "internet";
          connect_timeout = "10s";
          lb_policy = "CLUSTER_PROVIDED";
          cluster_type = {
            name = "envoy.clusters.dynamic_forward_proxy";
            typed_config = {
              "@type" = "type.googleapis.com/envoy.extensions.clusters.dynamic_forward_proxy.v3.ClusterConfig";
              dns_cache_config = dnsCache;
            };
          };
          circuit_breakers.thresholds = [
            {
              max_connections = 1024;
              max_pending_requests = 1024;
              max_requests = 4096;
            }
          ];
        }
      ];
    };
  };
in
settings
