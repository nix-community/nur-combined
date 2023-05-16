{ pkgs, lib, config, ... }: {
  services.tailscale.enable = lib.mkDefault true;

  networking.firewall = lib.mkIf config.services.tailscale.enable {
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = lib.mkIf config.services.tailscale.enable {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      # PLEASE DON'T USE A PREAUTHORIZED KEY HERE. Reusable is nice :thumbs_up:
      ${tailscale}/bin/tailscale up -authkey tskey-auth-kpZwrW6CNTRL-wJ3iRCC6hyAxF37jwZu3vAzY3CsFtQdp9
    '';
  };
}
