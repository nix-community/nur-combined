{ config, lib, pkgs, ... }:

let
  gpgRemoteForward = {
    bind.address = "/run/user/1000/gnupg/S.gpg-agent";
    host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
  };
  gpgSSHRemoteForward = {
    bind.address = "/run/user/1000/gnupg/S.gpg-agent.ssh";
    host.address = "/run/user/1000/gnupg/S.gpg-agent.ssh";
  };

  inherit (lib) optionalAttrs importTOML hasAttr attrsets mkIf;
  metadata = importTOML ../../../ops/hosts.toml;

  hasWireguard = name: value: hasAttr "wireguard" value;
  hasAddrs = name: value: hasAttr "addrs" value;
  hasSShAndRemoteForward = v: (hasAttr "ssh" v) && (hasAttr "gpgRemoteForward" v.ssh);
  hasCommand = v: hasAttr "command" v;

  hostWireguardIP = v: "${v.wireguard.addrs.v4}";
  hostIP = v: "${v.addrs.v4}";
  hostRemoteCommand = v: "${v.command}";

  hostToSSHConfigItem = value: ipfn: {
    hostname = ipfn value;
    remoteForwards = mkIf (hasSShAndRemoteForward value) [ gpgRemoteForward gpgSSHRemoteForward ];
    # FIXME: need support for RemoteCommand in home-manager
    # RemoteCommand = mkIf (hasCommand value) hostRemoteCommand value;
  };
  hostToSSHConfig = suffix: ipfn:
    name: value: attrsets.nameValuePair
      (toString "${name}${suffix}")
      (hostToSSHConfigItem value ipfn);

  vpnConfig = attrsets.mapAttrs'
    (hostToSSHConfig "\.vpn" hostWireguardIP)
    (attrsets.filterAttrs hasWireguard metadata.hosts);
  homeConfig = attrsets.mapAttrs'
    (hostToSSHConfig "\.home" hostIP)
    (attrsets.filterAttrs hasAddrs metadata.hosts);
in
{
  home.packages = [
    pkgs.openssh
  ];
  home.file.".ssh/sockets/.placeholder".text = '''';
  xdg.configFile."ssh/.placeholder".text = '''';
  programs.ssh = {
    enable = true;

    serverAliveInterval = 60;
    hashKnownHosts = true;
    userKnownHostsFile = "${config.xdg.configHome}/ssh/known_hosts";
    controlMaster = "auto";
    controlPersist = "10m";
    controlPath = "${config.home.homeDirectory}/.ssh/sockets/%u-%l-%r@%h:%p";
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        extraOptions = {
          controlMaster = "auto";
          controlPersist = "360";
        };
      };
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        extraOptions = {
          controlMaster = "auto";
          controlPersist = "360";
        };
      };
      "git.sr.ht" = {
        hostname = "git.sr.ht";
        user = "git";
        extraOptions = {
          controlMaster = "auto";
          controlPersist = "360";
        };
      };
      "*.redhat.com" = {
        user = "vdemeest";
      };
      "bootstrap.ospqa.com" = {
        forwardAgent = true;
      };
      "192.168.1.*" = {
        forwardAgent = true;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };
      "10.100.0.*" = {
        forwardAgent = true;
      };
    } // homeConfig // vpnConfig;
    extraConfig = ''
      GlobalKnownHostsFile ~/.config/ssh/ssh_known_hosts ~/.config/ssh/ssh_known_hosts.redhat ~/.config/ssh/ssh_known_hosts.mutable
      StrictHostKeyChecking yes
      PreferredAuthentications gssapi-with-mic,publickey,password
      GSSAPIAuthentication yes
      GSSAPIDelegateCredentials yes
      StreamLocalBindUnlink yes
      IdentityFile ~/.ssh/keys/%h
      IdentityFile ~/.ssh/id_ed25519
      IdentityFile ~/.ssh/id_rsa
    '';
  };
  # FIXME generate this file as well
  xdg.configFile."ssh/ssh_known_hosts".text = ''
    # Home ()
    wakasu.home,wakasu.vpn,wakasu.sbr.pm,10.100.0.8,192.168.1.77 wakasu.vpn ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrAh07USjRnAdS3mMNGdKee1KumjYDLzgXaiZ5LYi2D
    aomi.home,aomi.sbr.pm,aomi.vpn,10.100.0.17,192.168.1.23 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQVlSrUKU0xlM9E+sJ8qgdgqCW6ePctEBD2Yf+OnyME
    sakhalin.home,sakhalin.sbr.pm,sakhalin.vpn,10.100.0.16,192.168.1.70 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN/PMBThi4DhgZR8VywbRDzzMVh2Qp3T6NJAcPubfXz6
    shikoku.home,shikoku.sbr.pm,shikoku.vpn,10.100.0.2,192.168.1.24 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH18c6kcorVbK2TwCgdewL6nQf29Cd5BVTeq8nRYUigm
    kerkouane.vpn,kerkouane.sbr.pm,10.100.0.1 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJguVoQYObRLyNxELFc3ai2yDJ25+naiM3tKrBGuxwwA
    synodine.home,synodine.sbr.pm,192.168.1.20 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWdnPJg0Y4kd4lHPAGE4xgMAK2qvMg3oBxh0t+xO+7O
    demeter.home,demeter.vpn,demeter.sbr.pm,192.168.1.182 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqQfEyHyjIGglayB9FtCqL7bnYfNSQlBXks2IuyCPmd
    athena.home,athena.vpn,athena.sbr.pm,192.168.1.183 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4KRP1rzOwyA2zP1Nf1WlLRHqAGutLtOHYWfH732xh
    aion.home,aion.vpn,aion.sbr.pm,192.168.1.49 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMs2o62unBFN/LHRg3q2N4QyZW0+DC/gjw3yzRbWdzx5
    
  '';
  xdg.configFile."ssh/ssh_known_hosts.redhat".text = ''
    # Red Hat
    gitlab.cee.redhat.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBgflBIyju1LV/29PmFDw0GLdB9h0JUXglNrvWjBQ2u
    code.engineering.redhat.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYZZXmzm14TUL02Qe5SCMw48OfrphoIzi4qXSEK9Hiq
  '';
}
