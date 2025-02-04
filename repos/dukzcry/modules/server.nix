{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.server;
in {
  options.services.server = {
    enable = mkEnableOption ''
      Support for my home server
    '';
    remote = mkEnableOption ''
      Support for remote use
    '';
  };

  config = mkMerge [
    (mkIf cfg.enable {
      system.fsPackages = with pkgs; [ sshfs ];
      systemd.mounts = [{
        type = "fuse.sshfs";
        what = "Artem@robocat:/data";
        where = "/data";
        options = "IdentityFile=/home/Artem/.ssh/id_rsa,allow_other,_netdev";
      }];
      systemd.automounts = [{
        wantedBy = [ "multi-user.target" ];
        automountConfig = {
          TimeoutIdleSec = "600";
        };
        where = "/data";
      }];
      environment = {
        systemPackages = with pkgs; with pkgs.nur.repos.dukzcry; [
          jellyfin-media-player
        ];
      };
      systemd.sockets.cups.wantedBy = mkForce [];
      systemd.services.cups.wantedBy = mkForce [];
      services.printing = {
        enable = true;
        clientConf = ''
          ServerName robocat
        '';
      };
      security.pki.certificates = [
''
-----BEGIN CERTIFICATE-----
MIIFUTCCAzmgAwIBAgIUJqIBA7MVe8CI4vI6ZG1Vti2yPT8wDQYJKoZIhvcNAQEL
BQAwHDEaMBgGA1UEAwwRcm9ib2NhdC5ob21lLmFycGEwIBcNMjUwMjAzMTcxODU2
WhgPMjEyNTAyMDQxNzE4NTZaMBwxGjAYBgNVBAMMEXJvYm9jYXQuaG9tZS5hcnBh
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA0QsXUyRSP891Ginyd7tS
MY4iIalg2BbIO6zL1Dgqlc7W5e8xN00+TsGeiokCHdHBpfk4rR/+UTaeWohwiwol
X7xKE2Jqh1LfLyTMwfBzLqxmbEIKUNgqNfD/VLu7Nyjqf2N1owc3SBt6erbbnzqD
11t9B4vI2ZWHvwZAQAh6TmU+G4Oowh4QlW/KUFl9Ye/zFE+BEvGYR+Q+NqHmkB40
hneoGeciP/QEqxvTgPC/qZdXE8vNIGCI+nbDGa5KgywJlE/Hzm4frAlfgObVD4MH
kFV8Sz5UsJuPjBPSwbYTUIK4PaZiKidYj5c/rXjgmaAOBRlPfb/oWq02sfed9Nsh
oMmVeL22NCDWCpiixT3by2K64fsqhQAnCO6cGo0S/jB1Iwo6NWCQqIFASqId/J8L
ZMv8GkQLcl7bj+vh915UGMtKrqSda9I2Th5hx7qcYMuATXi+9eIIUTB2Ws4uoPLF
TgtiG4QGNEv4HiXNtW2kMy0tx7lwOYfc+HQfIwLA6CHruiunevetpwzAca8W8l7q
LKC9pKkPtiha/B1v7Yuhfzc81YzOipSbrlpV+2fhjmzNA+XQV52tBuHvJt8DbTb3
vz7/TJJfd23um24GJ/qAVDAr5R64YANKk/NGYij4Z/PmontPuJaGVdr9txmEsu0e
OUA6ipr1LsRLYg9dp2kx9mECAwEAAaOBiDCBhTAdBgNVHQ4EFgQUIPJV/Dog3Fss
UUohPxXpyHlA0HAwHwYDVR0jBBgwFoAUIPJV/Dog3FssUUohPxXpyHlA0HAwDwYD
VR0TAQH/BAUwAwEB/zAyBgNVHREEKzApggdyb2JvY2F0ggkqLnJvYm9jYXSCEyou
cm9ib2NhdC5ob21lLmFycGEwDQYJKoZIhvcNAQELBQADggIBALis55kRkbT8eNkl
FqCoD9UKvugHQQMmwaVxT546uCABmuNkopPgx0WF6QnJxPGOkrejbho7EO5gZCnH
wnot6UEtOwf+72ePVxftmazkWD9ccR83gLRzU5kIwx/Lbn2s4H2J6TmGumBJ+Ihi
WqlxSMJBLiLQkXmKpE1ynDiYHtbJRkzxIbsrQuiP2UBgPAq2zFG9Sz+MEZbP0CdQ
vMLsMLNBY75uI4GqzV/Q9zo3JAmqJsL3xEM9xQc5zavUKPXMrAh0ircQu4xlQLhO
o/UWR4egt6JmeMBrTCYHyq4WpI3wGg9zaBWETWy01hXXH0WRo4lnXai0RFEkrQ9o
f3GLj3Ook0xCGQBa2j8y/h64bDTOOJovD2i7zza+Lyj5qFfKaiD3xZMnSUdP2twU
p2A/FegTslG8UlYwmtpgdCLjabbCNzuuBFOU2oamu51FogC1vM//UuPLlshz3HGn
puKn6hwRNEn9NPYRGJkteFWBneTUMl9eaoa76bnQXgritTxaPnFQLcs8TXbgCMYE
X52rlE6wY4ft9ypTp9ywnvbZADUOp+VebaCeLl9GzkdjXjdbJhwANUf6NRuMqQZK
DB3l/m8mfu++50DPokK7bW6sUL/7qeGO9t9XN/iyEnsjLAAr5xKCd2lWbEydlDNh
KPoAasAwIFKBYRKQu+wiRu55Zosm
-----END CERTIFICATE-----
''
      ];
    })
    (mkIf cfg.remote {
      environment.systemPackages = with pkgs; with pkgs.nur.repos.dukzcry; [
        moonlight-qt syncthing minicom
      ];
      services.yggdrasil = {
        enable = true;
        configFile = "/etc/yggdrasil.conf";
      };
      systemd.services.yggdrasil.wantedBy = mkForce [];
    })
  ];
}
