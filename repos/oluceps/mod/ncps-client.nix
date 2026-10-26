{
  flake.modules.nixos.ncps-client = {
    # Nix stays host infrastructure; Envoy exposes a loopback read-only cache adapter.
    realm.workloads.nix-cache = {
      unit = "envoy.service";
      user = "envoy";
      group = "envoy";
      runtime = "external";
      isolation.privateNetwork = false;
      egress.ncps = {
        service = "ncps";
      };
    };
    services.envoy.settings.static_resources = {
      listeners = [
        {
          name = "ncps_client";
          address.socket_address = {
            address = "127.0.0.1";
            port_value = 18502;
          };
          filter_chains = [
            {
              filters = [
                {
                  name = "envoy.filters.network.http_connection_manager";
                  typed_config = {
                    "@type" =
                      "type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager";
                    stat_prefix = "ncps_client";
                    normalize_path = true;
                    merge_slashes = true;
                    path_with_escaped_slashes_action = "REJECT_REQUEST";
                    max_request_headers_kb = 16;
                    route_config = {
                      name = "ncps_client";
                      virtual_hosts = [
                        {
                          name = "ncps_client";
                          domains = [ "*" ];
                          routes = [
                            {
                              match.prefix = "/metrics";
                              direct_response.status = 403;
                            }
                            {
                              match.prefix = "/debug";
                              direct_response.status = 403;
                            }
                            {
                              match = {
                                prefix = "/";
                                headers = [
                                  {
                                    name = ":method";
                                    string_match.safe_regex.regex = "GET|HEAD";
                                  }
                                ];
                              };
                              route = {
                                cluster = "ncps_client";
                                timeout = "0s";
                              };
                            }
                            {
                              match.prefix = "/";
                              direct_response.status = 403;
                            }
                          ];
                        }
                      ];
                    };
                    http_filters = [
                      {
                        name = "envoy.filters.http.router";
                        typed_config."@type" = "type.googleapis.com/envoy.extensions.filters.http.router.v3.Router";
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
          name = "ncps_client";
          type = "STATIC";
          connect_timeout = "5s";
          load_assignment = {
            cluster_name = "ncps_client";
            endpoints = [
              {
                lb_endpoints = [
                  {
                    endpoint.address.pipe.path = "/run/realm/nix-cache/egress/ncps.sock";
                  }
                ];
              }
            ];
          };
        }
      ];
    };
  };
}
