{
  config,
  pkgs,
  ...
}:

{
  services.shairport-sync = {
    enable = true;
    package = pkgs.shairport-sync-airplay2;
    settings = {
      general = {
        name = "NixO6N";
        service_type = "airplay2";
        interpolation = "soxr";
        interface = "bond0";
        output_backend = "alsa";
        volume_range_db = 30;
        volume_control_profile = "dasl_tapered";
      };
      alsa = {
        output_device = "hw:CARD=edifier-m16-pro,DEV=0";
      };
    };
    openFirewall = false; # only for AirPlay 1
  };

  services.udev.extraRules = ''
    # Identify the USB speaker independently of card number and USB port.
    ACTION=="add|change", SUBSYSTEM=="sound", KERNEL=="card[0-9]*", ATTRS{idVendor}=="2d99", ATTRS{idProduct}=="a020", ATTR{id}="edifier-m16-pro"
  '';

  systemd.packages = [ pkgs.nqptp ];
  systemd.services.nqptp.wantedBy = [ "multi-user.target" ];
  systemd.services.shairport-sync.restartTriggers = [
    config.environment.etc."shairport-sync.conf".source
  ];
  systemd.services.shairport-sync.serviceConfig.LimitRTPRIO = 5;

  assertions = [
    {
      assertion = config.networking.firewall.backend == "iptables";
      message = "AirPlay 2 dynamic firewall rules require the iptables firewall backend";
    }
  ];

  networking.firewall.interfaces.bond0 = {
    allowedTCPPorts = [ 7000 ];
    allowedUDPPorts = [
      319 # PTP event messages for AirPlay 2
      320 # PTP general messages for AirPlay 2
    ];
  };
  networking.firewall.extraCommands = ''
    # AirPlay 2 chooses random event/control ports.
    # Temporarily authorise only clients that have
    # completed a TCP handshake with the main RTSP port.
    ip46tables -I nixos-fw 1 -i bond0 -p tcp --dport 7000 \
      -m conntrack --ctstate ESTABLISHED --ctstatus SEEN_REPLY \
      -m recent --name shairport2 --set -j nixos-fw-accept
    ip46tables -A nixos-fw -i bond0 -p tcp --dport 32768:60999 \
      -m recent --name shairport2 --update --seconds 300 --reap \
      -j nixos-fw-accept
    ip46tables -A nixos-fw -i bond0 -p udp --dport 32768:60999 \
      -m recent --name shairport2 --update --seconds 300 --reap \
      -j nixos-fw-accept
  '';
}
