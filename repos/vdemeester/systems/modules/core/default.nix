{ config, lib, pkgs, ... }:

let
  common = {
    sopsFile = ../../../secrets/secrets.yaml;
    mode = "444";
    owner = "root";
    group = "root";
  };
in
{
  imports = [
    ./binfmt.nix
    ./boot.nix
    ./config.nix
    ./i18n.nix
    ./nix.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    cachix
    file
    htop
    iotop
    lsof
    netcat
    psmisc
    pv
    tree
    vim
    wget
  ];
  # FIXME fix tmpOnTmpfs
  # systemd.additionalUpstreamSystemUnits = [ "tmp.mount" ];

  security.sudo = {
    extraConfig = ''
      Defaults env_keep += SSH_AUTH_SOCK
    '';
  };

  sops.secrets."minica.pem" = {
    inherit (common) mode owner group sopsFile;
    path = "/etc/ssl/certs/minica.pem";
  };
  sops.secrets."redhat.pem" = {
    inherit (common) mode owner group sopsFile;
    path = "/etc/ssl/certs/redhat.pem";
  };
  # security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" "/etc/ssl/certs/minica.pem" ]; 

  # Only keep the last 500MiB of systemd journal.
  services.journald.extraConfig = "SystemMaxUse=500M";

  # Clear out /tmp after a fortnight and give all normal users a ~/tmp
  # cleaned out weekly.
  systemd.tmpfiles.rules = [ "d /tmp 1777 root root 14d" ] ++
    (
      let mkTmpDir = n: u: "d ${u.home}/tmp 0700 ${n} ${u.group} 7d";
      in lib.mapAttrsToList mkTmpDir (lib.filterAttrs (_: u: u.isNormalUser) config.users.extraUsers)
    );

  systemd.services."status-email-root@" = {
    description = "status email for %i to vincent";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.my.systemd-email}/bin/systemd-email vincent@demeester.fr %i
      '';
      User = "root";
      Environment = "PATH=/run/current-system/sw/bin";
    };
  };
}
