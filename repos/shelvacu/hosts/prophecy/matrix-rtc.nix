{
  config,
  lib,
  pkgs,
  ...
}:
let
  # MatrixRTC / Element Call backend: a LiveKit SFU plus lk-jwt-service (the
  # "MatrixRTC Authorization Service"). Both are fronted by caddy on a single
  # host, matrix-rtc.shelvacu.com, with path-based routing per the continuwuity
  # docs: https://continuwuity.org/calls/livekit
  rtcHost = "matrix-rtc.shelvacu.com";
  rtcUrl = "https://${rtcHost}";
  # Shared LiveKit API key/secret. Regenerated on each boot into tmpfs; only
  # needs to be consistent between livekit and lk-jwt-service, both of which
  # order after the generator and re-read it on start.
  keyFile = "/run/livekit.key";
  # Public IP that matrix-rtc.shelvacu.com resolves to. This host is NAT'd (its
  # interface holds both this address and the private LAN address), and LiveKit
  # by default would advertise the private one, so we pin the WebRTC ICE
  # candidate to the public IP. primaryIp is a structured IP value, hence the
  # toString when handing it to the JSON-typed livekit settings.
  publicIp = toString config.vacu.hosts.prophecy.primaryIp;
  livekitCfg = config.services.livekit;
in
{
  services.livekit = {
    enable = true;
    inherit keyFile;
    # We open only the UDP media range on the firewall below; the TCP
    # signalling port (7880) stays localhost-only behind caddy.
    openFirewall = false;
    settings.rtc.node_ip = publicIp;
    settings.rtc.use_external_ip = false;
    # Neither livekit nor lk-jwt-service can listen on a unix socket, so the
    # next best thing is to bind the HTTP/websocket signalling port to loopback
    # only (caddy proxies to it). This does not affect the WebRTC media, which
    # binds the UDP range on all interfaces independently.
    settings.bind_addresses = [ "127.0.0.1" ];
  };

  services.lk-jwt-service = {
    enable = true;
    inherit keyFile;
    # The public wss:// URL clients use to reach the SFU (caddy -> livekit:7880).
    livekitUrl = "wss://${rtcHost}";
    # port defaults to 8080
  };

  # Bind lk-jwt-service to loopback only (it can't use a unix socket); caddy
  # proxies to it. The module otherwise binds all interfaces.
  systemd.services.lk-jwt-service.environment.LIVEKIT_JWT_BIND =
    lib.mkForce "127.0.0.1:${toString config.services.lk-jwt-service.port}";

  # Generate a random LiveKit key/secret pair on boot if one isn't present.
  systemd.services.livekit-key = {
    description = "Generate shared LiveKit API key/secret";
    before = [
      "lk-jwt-service.service"
      "livekit.service"
    ];
    requiredBy = [
      "lk-jwt-service.service"
      "livekit.service"
    ];
    path = [
      pkgs.livekit
      pkgs.coreutils
      pkgs.gawk
    ];
    unitConfig.ConditionPathExists = "!${keyFile}";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      UMask = "077";
    };
    script = ''
      echo "lk-jwt-service: $(livekit-server generate-keys | tail -1 | awk '{print $3}')" > ${keyFile}
    '';
  };

  # Only the WebRTC media range needs to be reachable from the internet.
  networking.firewall.allowedUDPPortRanges = [
    {
      from = livekitCfg.settings.rtc.port_range_start;
      to = livekitCfg.settings.rtc.port_range_end;
    }
  ];

  services.caddy.virtualHosts.${rtcHost} = {
    vacu.hsts = false;
    extraConfig = ''
      # lk-jwt-service (MatrixRTC Authorization Service) endpoints.
      @jwt path /sfu/get /get_token /healthz
      handle @jwt {
        reverse_proxy 127.0.0.1:${toString config.services.lk-jwt-service.port}
      }
      # Everything else is the LiveKit SFU (incl. the wss:// signalling socket).
      handle {
        reverse_proxy 127.0.0.1:${toString livekitCfg.settings.port}
      }
    '';
  };

  # Advertise the focus to clients (via continuwuity's MSC4143 transports
  # endpoint) and to matrix-server-side callers.
  services.matrix-continuwuity.settings.global.matrix_rtc.foci = [
    {
      type = "livekit";
      livekit_service_url = rtcUrl;
    }
  ];
}
