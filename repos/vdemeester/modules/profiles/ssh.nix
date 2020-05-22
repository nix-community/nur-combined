{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.ssh;
  patchedOpenSSH = pkgs.openssh.override { withKerberos = true; withGssapiPatches = true; };
in
{
  options = {
    profiles.ssh = {
      enable = mkOption {
        default = true;
        description = "Enable ssh profile and configuration";
        type = types.bool;
      };
      machines = mkOption {
        default = { };
        type = types.attrs;
      };
    };
  };
  config = mkIf cfg.enable {
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
        "*.redhat.com" = {
          user = "vdemeest";
        };
        "192.168.1.*" = {
          forwardAgent = true;
        };
      } // cfg.machines;
      extraConfig = ''
        PreferredAuthentications gssapi-with-mic,publickey,password
        GSSAPIAuthentication yes
        GSSAPIDelegateCredentials yes
      '';
    };
  };
}
