{
  config,
  lib,
  ...
}:
let
  service = "glance";
  hl = config.homelab;
  cfg = hl.services.${service};
  port = 8085;

  toBookmark = _: v: {
    title = v.glance.name;
    url = v.glance.url;
  };

  homelabBookmarks = lib.sort (a: b: a.title < b.title) (
    (lib.pipe hl.services [
      (lib.filterAttrs (
        _: v: lib.isAttrs v && (v.enable or false) && (v ? glance) && v.glance.url != null
      ))
      (lib.mapAttrsToList toBookmark)
    ])
    ++ (lib.pipe hl.services.cloudrun.services [
      (lib.filterAttrs (_: v: v.glance.url != null))
      (lib.mapAttrsToList toBookmark)
    ])
  );
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Enable ${service}";
    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where glance actually runs, if not this machine";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "glance.${hl.baseDomainName}";
      description = "Domain to serve Glance on";
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Glance";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.url}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.host == "127.0.0.1") {
        services.${service} = {
          enable = true;
          settings = {
            server.port = port;
            pages = [
              {
                name = "Home";
                columns = [
                  {
                    size = "small";
                    widgets = [
                      { type = "clock"; }
                      {
                        type = "weather";
                        hour-format = "24h";
                        location = "San Carlos, California";
                      }
                      {
                        type = "bookmarks";
                        groups = [
                          {
                            title = "Homelab";
                            links = homelabBookmarks;
                          }
                        ];
                      }
                    ];
                  }
                  {
                    size = "full";
                    widgets = [
                      { type = "search"; }
                      {
                        type = "monitor";
                        title = "Services";
                        sites = homelabBookmarks;
                      }
                      {
                        type = "group";
                        widgets = [
                          { type = "hacker-news"; }
                          { type = "lobsters"; }
                          {
                            type = "reddit";
                            subreddit = "selfhosted";
                          }
                          {
                            type = "reddit";
                            subreddit = "homelab";
                          }
                        ];
                      }
                      {
                        type = "releases";
                        repositories = [ "avycado13/nix" ];
                      }
                      {
                        type = "repository";
                        repository = "avycado13/nix";
                      }
                    ];
                  }
                ];
              }
              {
                name = "Markets";

                columns = [
                  {
                    size = "small";

                    widgets = [
                      {
                        type = "markets";
                        title = "Indices";

                        markets = [
                          {
                            symbol = "SPY";
                            name = "S&P 500";
                          }
                          {
                            symbol = "DX-Y.NYB";
                            name = "Dollar Index";
                          }
                        ];
                      }

                      {
                        type = "markets";
                        title = "Crypto";

                        markets = [
                          {
                            symbol = "BTC-USD";
                            name = "Bitcoin";
                          }
                          {
                            symbol = "ETH-USD";
                            name = "Ethereum";
                          }
                        ];
                      }

                      {
                        type = "markets";
                        title = "Stocks";
                        sort-by = "absolute-change";

                        markets = [
                          {
                            symbol = "NVDA";
                            name = "NVIDIA";
                          }
                          {
                            symbol = "AAPL";
                            name = "Apple";
                          }
                          {
                            symbol = "MSFT";
                            name = "Microsoft";
                          }
                          {
                            symbol = "GOOGL";
                            name = "Google";
                          }
                          {
                            symbol = "AMD";
                            name = "AMD";
                          }
                          {
                            symbol = "RDDT";
                            name = "Reddit";
                          }
                          {
                            symbol = "AMZN";
                            name = "Amazon";
                          }
                          {
                            symbol = "TSLA";
                            name = "Tesla";
                          }
                          {
                            symbol = "INTC";
                            name = "Intel";
                          }
                          {
                            symbol = "META";
                            name = "Meta";
                          }
                        ];
                      }
                    ];
                  }

                  {
                    size = "full";

                    widgets = [
                      {
                        type = "rss";
                        title = "News";
                        style = "horizontal-cards";

                        feeds = [
                          {
                            url = "https://feeds.bloomberg.com/markets/news.rss";
                            title = "Bloomberg";
                          }
                          {
                            url = "https://moxie.foxbusiness.com/google-publisher/markets.xml";
                            title = "Fox Business";
                          }
                          {
                            url = "https://moxie.foxbusiness.com/google-publisher/technology.xml";
                            title = "Fox Business";
                          }
                        ];
                      }

                      {
                        type = "group";

                        widgets = [
                          {
                            type = "reddit";
                            show-thumbnails = true;
                            subreddit = "technology";
                          }
                          {
                            type = "reddit";
                            show-thumbnails = true;
                            subreddit = "wallstreetbets";
                          }
                        ];
                      }

                      {
                        type = "videos";
                        style = "grid-cards";
                        collapse-after-rows = 3;

                        channels = [
                          "UCvSXMi2LebwJEM1s4bz5IBA" # New Money
                          "UCV6KDgJskWaEckne5aPA0aQ" # Graham Stephan
                          "UCAzhpt9DmG6PnHXjmJTvRGQ" # Federal Reserve
                        ];
                      }
                    ];
                  }

                  {
                    size = "small";

                    widgets = [
                      {
                        type = "rss";
                        title = "News";
                        limit = 30;
                        collapse-after = 13;

                        feeds = [
                          {
                            url = "https://www.ft.com/technology?format=rss";
                            title = "Financial Times";
                          }
                          {
                            url = "https://feeds.a.dj.com/rss/RSSMarketsMain.xml";
                            title = "Wall Street Journal";
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

        systemd.services.${service}.unitConfig.OnFailure = lib.mkIf (
          hl.notifications.ntfySecretsFile != null
        ) "notify-failure@%n.service";
      })
      {
        services.caddy.virtualHosts."${cfg.url}" = {
          useACMEHost = hl.baseDomainName;
          extraConfig = ''
            reverse_proxy http://${cfg.host}:${toString port}
          '';
        };
      }
    ]
  );
}
