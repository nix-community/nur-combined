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
        name = "Qisheng";
        service_type = "airplay2";
        interpolation = "soxr";
        interface = "end0";
        output_backend = "alsa";
        volume_max_db = 0.0;
        volume_range_db = 30;
        volume_control_profile = "dasl_tapered";
      };
      alsa = {
        output_device = "hw:CARD=rockchipes8388,DEV=0";
        mixer_device = "hw:CARD=rockchipes8388";
        mixer_control_name = "PCM";
      };
    };
    openFirewall = false; # only for AirPlay 1
  };

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

  networking.firewall.interfaces.${config.services.shairport-sync.settings.general.interface} = {
    allowedTCPPorts = [ 7000 ];
    allowedUDPPorts = [
      319 # PTP event messages for AirPlay 2
      320 # PTP general messages for AirPlay 2
    ];
  };
  networking.firewall.extraCommands =
    let
      interface = config.services.shairport-sync.settings.general.interface;
    in
    ''
      # AirPlay 2 chooses random event/control ports.
      # Temporarily authorise only clients that have
      # completed a TCP handshake with the main RTSP port.
      ip46tables -I nixos-fw 1 -i ${interface} -p tcp --dport 7000 \
        -m conntrack --ctstate ESTABLISHED --ctstatus SEEN_REPLY \
        -m recent --name shairport2 --set -j nixos-fw-accept
      ip46tables -A nixos-fw -i ${interface} -p tcp --dport 32768:60999 \
        -m recent --name shairport2 --update --seconds 300 --reap \
        -j nixos-fw-accept
      ip46tables -A nixos-fw -i ${interface} -p udp --dport 32768:60999 \
        -m recent --name shairport2 --update --seconds 300 --reap \
        -j nixos-fw-accept
    '';
}
