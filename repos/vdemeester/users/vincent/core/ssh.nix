{ config, lib, pkgs, ... }:

with lib;
let
  patchedOpenSSH = pkgs.openssh.override { withKerberos = true; withGssapiPatches = true; };
  secretPath = ../../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);
  sshConfig = optionalAttrs secretCondition (import secretPath).sshConfig;
in
{
  home.packages = [
    patchedOpenSSH
  ];
  home.file.".ssh/sockets/.placeholder".text = '''';
  xdg.configFile.".ssh/.placeholder".text = '''';
  programs.ssh = {
    enable = true;

    serverAliveInterval = 60;
    hashKnownHosts = true;
    userKnownHostsFile = "${config.xdg.configHome}/ssh/known_hosts";
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
      "192.168.1.*" = {
        forwardAgent = true;
      };
      "10.100.0.*" = {
        forwardAgent = true;
      };
    } // sshConfig;
    extraConfig = ''
      PreferredAuthentications gssapi-with-mic,publickey,password
      GSSAPIAuthentication yes
      GSSAPIDelegateCredentials yes
    '';
  };
}
