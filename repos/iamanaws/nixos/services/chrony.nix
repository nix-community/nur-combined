{ lib, ... }:

{
  services.timesyncd.enable = lib.mkDefault false;

  # Adapted from GrapheneOS; review upstream sources and policy when updating.
  # https://github.com/GrapheneOS/infrastructure/blob/main/etc/chrony.conf
  # NixOS supplies clock/state defaults; other upstream tuning is omitted.
  services.chrony = {
    enable = lib.mkDefault true;
    enableNTS = lib.mkDefault true;

    # Restrict daemon system calls.
    extraFlags = lib.mkDefault [ "-F 1" ];

    # Declare sources below to keep them as individual servers.
    servers = lib.mkDefault [ ];
    extraConfig = ''
      server time.cloudflare.com iburst nts
      server ntppool1.time.nl iburst nts
      server nts.netnod.se iburst nts
      server ptbtime1.ptb.de iburst nts
      server time.dfm.dk iburst nts
      server time.cifelli.xyz iburst nts

      minsources 3
      authselectmode require
      cmdport 0
    '';
  };
}
