{ config, ... }:
{
  sane.services.wg-home.enable = true;
  sane.services.wg-home.visibleToWan = true;
  sane.services.wg-home.forwardToWan = true;
  sane.services.wg-home.routeThroughServo = false;
  sane.services.wg-home.ip = config.sane.hosts.by-name."servo".wg-home.ip;
  services.unbound.settings.server.interface = [
    # provide DNS to my wireguard clients
    config.sane.hosts.by-name."servo".wg-home.ip
  ];
  services.unbound.settings.server.access-control = [
    "${config.sane.hosts.by-name."servo".wg-home.ip}/24 allow"
  ];
}
