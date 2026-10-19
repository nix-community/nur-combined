{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.vacu.pbx;
  amiDir = "/var/lib/pbx-ami";
in
{
  options.vacu.pbx.servicesPort = lib.mkOption {
    type = lib.types.port;
    default = 6972;
    description = ''
      Port the phone's XML services listen on: the Directories button's
      contacts and the Messages button's visual voicemail.
    '';
  };

  config = {
    users.users.phone-services = {
      isSystemUser = true;
      group = "phone-services";
    };
    users.groups.phone-services = { };

    # Kept out of the repo (friends' numbers), not because it is a credential.
    # Format is in packages/cisco-phone-services/contacts.py.
    sops.secrets.contacts.owner = "phone-services";

    # The services app reaches voicemail through AMI over asterisk's HTTP
    # server. Both ends only ever run on this VM, so the password is invented
    # here once rather than kept in sops.
    systemd.services.pbx-ami-secret = {
      before = [
        "asterisk.service"
        "cisco-phone-services.service"
      ];
      # Wants rather than Requires: a Requires would carry a restart of this
      # unit through to asterisk, dropping live calls on a rebuild.
      wantedBy = [
        "asterisk.service"
        "cisco-phone-services.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "pbx-ami";
        UMask = "0077";
      };
      path = [ pkgs.coreutils ];
      script = ''
        if [ ! -s ${amiDir}/secret ]; then
          tr -dc A-Za-z0-9 < /dev/urandom | head -c 32 > ${amiDir}/secret
        fi
        secret=$(cat ${amiDir}/secret)
        echo "secret=$secret" > ${amiDir}/manager-secret.conf
        chown asterisk ${amiDir}/manager-secret.conf
        printf '%s\n' \
          'manager-url: "http://127.0.0.1:8088/mxml"' \
          'manager-username: "phone-services"' \
          "manager-secret: \"$secret\"" > ${amiDir}/services.yml
        chown phone-services ${amiDir}/services.yml
      '';
    };

    services.asterisk.confFiles = {
      "http.conf" = ''
        [general]
        enabled=yes
        bindaddr=127.0.0.1
        bindport=8088
      '';
      "manager.conf" = ''
        [general]
        enabled=yes
        webenabled=yes
        bindaddr=127.0.0.1

        [phone-services]
        #include "${amiDir}/manager-secret.conf"
        deny=0.0.0.0/0.0.0.0
        permit=127.0.0.1/255.255.255.255
        ; VoicemailBoxSummary and SIPShowPeer are `reporting`; VoicemailMove,
        ; VoicemailRemove and VoicemailForward are `user`.
        read=reporting
        write=reporting,user
      '';
    };

    systemd.services.cisco-phone-services = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = {
        SERVICES_CONFIG = "${amiDir}/services.yml";
        CONTACTS_FILE = config.sops.secrets.contacts.path;
      };
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.cisco-phone-services} --bind 0.0.0.0:${toString cfg.servicesPort} --workers 2";
        User = "phone-services";
        Group = "phone-services";
        Restart = "on-failure";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.servicesPort ];
  };
}
