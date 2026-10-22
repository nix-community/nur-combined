{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.dots.ssh;
  identity = "${config.home.homeDirectory}/.ssh/avy";

  hostSubmodule = types.submodule {
    options = {
      hostname = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Hostname or IP address";
      };
      port = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "SSH port";
      };
      user = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Username for SSH connection";
      };
      identityFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to SSH identity file";
      };
      forwardAgent = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Enable SSH agent forwarding";
      };
      setEnv = mkOption {
        type = types.attrsOf (
          types.oneOf [
            types.str
            types.path
            types.int
            types.float
          ]
        );
        default = { };
        description = "Environment variables to set (maps to SetEnv)";
      };
      remoteCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Remote command to execute (maps to RemoteCommand)";
      };
      requestTTY = mkOption {
        type = types.nullOr (
          types.enum [
            "yes"
            "no"
            "force"
            "auto"
          ]
        );
        default = null;
        description = "Request a pseudo-terminal (maps to RequestTTY)";
      };
      controlMaster = mkOption {
        type = types.nullOr (
          types.enum [
            "yes"
            "no"
            "ask"
            "auto"
            "autoask"
          ]
        );
        default = null;
        description = "Control master setting";
      };
      controlPath = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Control socket path";
      };
      controlPersist = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Control persist duration";
      };
      zmx = mkOption {
        type = types.bool;
        default = false;
        description = "Enable zmx persistent sessions for this host (attaches by hostname, %n)";
      };
      extraOptions = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Extra raw ssh_config keys for this host, merged in as-is";
      };
    };
  };
in
{
  options.dots.ssh = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the ssh dotfiles module.";
    };

    zmx = {
      enable = mkEnableOption "zmx integration for persistent sessions";
      hosts = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of host patterns to enable zmx auto-attach by key (e.g. 'p.*', attaches via %k)";
      };
    };

    agent = {
      addKeysToAgent = mkOption {
        type = types.enum [
          "yes"
          "no"
          "confirm"
          "ask"
        ];
        default = "no";
        description = "Automatically add keys to the running agent (maps to AddKeysToAgent)";
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = ''
        Host eu.nixbuild.net
          PubkeyAcceptedKeyTypes ssh-ed25519
          IPQoS throughput
      '';
      description = "Extra SSH configuration";
    };

    # Defined once, here, so machines don't need to redeclare hosts to enable
    # this module. A specific machine can still override/extend a single
    # host with `dots.ssh.hosts.<name>.<option> = ...;` if it ever needs to.
    hosts = mkOption {
      type = types.attrsOf hostSubmodule;
      default = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = identity;
        };
        "gh" = {
          hostname = "github.com";
          user = "git";
          identityFile = identity;
        };
        "hackclub.app" = {
          hostname = "hackclub.app";
          user = "avycado13";
          identityFile = identity;
        };
        "hashbang" = {
          hostname = "de1.hashbang.sh";
          user = "avycado";
          identityFile = identity;
        };
        "eu.nixbuild.net" = {
          hostname = "eu.nixbuild.net";
          user = "avycado13";
          identityFile = identity;
          extraOptions.ServerAliveInterval = 60;
        };
        "oracle" = {
          user = "root";
          hostname = "167.234.216.241";
        };
        "gce" = {
          user = "avy";
          hostname = "34.10.89.155";
        };
        "eclipse" = {
          user = "avy";
          hostname = "100.114.91.116";
          # port = 30014;
          identityFile = identity;
        };
        "nest" = {
          user = "avycado13";
          hostname = "hackclub.app";
          identityFile = identity;
        };
        "club" = {
          user = "avycado13";
          hostname = "tilde.club";
          identityFile = identity;
        };
        "rw.rs" = {
          user = "avycado13";
          hostname = "rw.rs";
          identityFile = identity;
        };
        "pi1" = {
          user = "avy";
          hostname = "100.117.24.61";
          identityFile = identity;
        };
        "apollo1" = {
          user = "avy";
          hostname = "100.72.166.0";
          identityFile = identity;
        };
        "p.*" = {
          hostname = "100.117.24.61";
          zmx = true;
          identityFile = identity;
        };
        "0xff" = {
          hostname = "144.91.107.232";
          user = "avy";
        };
      };
      description = "SSH host configurations";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (optionals cfg.zmx.enable [
        pkgs.zmx
        pkgs.autossh
      ])
      ++ [
        (pkgs.writeShellScriptBin "fip" ''
          if (( $# < 2 )); then
            echo "Usage: fip <host> <port1> [port2] ..."
            exit 1
          fi
          host="$1"
          shift
          for port in "$@"; do
            ${pkgs.openssh}/bin/ssh -f -N -L "$port:localhost:$port" "$host" && \
              echo "Forwarding localhost:$port -> $host:$port"
          done
        '')
        (pkgs.writeShellScriptBin "dip" ''
          if (( $# == 0 )); then
            echo "Usage: dip <port1> [port2] ..."
            exit 1
          fi
          for port in "$@"; do
            ${pkgs.procps}/bin/pkill -f "ssh.*-L $port:localhost:$port" && \
              echo "Stopped forwarding port $port" || \
              echo "No forwarding on port $port"
          done
        '')
        (pkgs.writeShellScriptBin "lip" ''
          ${pkgs.procps}/bin/pgrep -af "ssh.*-L [0-9]+:localhost:[0-9]+" || echo "No active forwards"
        '')
        pkgs.ssh-to-age
        pkgs.ssh-to-pgp
      ];

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings =
        let
          hostSettings = filterAttrs (_: v: v != { }) (
            mapAttrs (
              _key: hostCfg:
              let
                base = filterAttrs (_: v: v != null) {
                  HostName = hostCfg.hostname;
                  Port = hostCfg.port;
                  User = hostCfg.user;
                  IdentityFile = hostCfg.identityFile;
                  ForwardAgent = hostCfg.forwardAgent;
                  RemoteCommand = hostCfg.remoteCommand;
                  RequestTTY = hostCfg.requestTTY;
                  ControlMaster = hostCfg.controlMaster;
                  ControlPath = hostCfg.controlPath;
                  ControlPersist = hostCfg.controlPersist;
                };
                envBlock = optionalAttrs (hostCfg.setEnv != { }) { SetEnv = hostCfg.setEnv; };
                # per-host zmx: attach by hostname key (%n)
                zmxBlock = optionalAttrs hostCfg.zmx {
                  RemoteCommand = "export PATH=$HOME/.nix-profile/bin:$PATH; zmx attach %n";
                  RequestTTY = "yes";
                  ControlPath = "~/.ssh/cm-%r@%h:%p";
                  ControlMaster = "auto";
                  ControlPersist = "10m";
                };
              in
              base // envBlock // zmxBlock // hostCfg.extraOptions
            ) cfg.hosts
          );

          # zmx.hosts: glob patterns that attach by matched key (%k)
          zmxPatternSettings = optionalAttrs cfg.zmx.enable (
            listToAttrs (
              map (pattern: {
                name = pattern;
                value = {
                  RemoteCommand = "export PATH=$HOME/.nix-profile/bin:$PATH; zmx attach %k";
                  RequestTTY = "yes";
                  ControlPath = "~/.ssh/cm-%r@%h:%p";
                  ControlMaster = "auto";
                  ControlPersist = "10m";
                };
              }) cfg.zmx.hosts
            )
          );

          defaultBlock = {
            "*" = {
              ForwardAgent = mkDefault false;
              AddKeysToAgent = mkDefault cfg.agent.addKeysToAgent;
              Compression = mkDefault false;
              ServerAliveInterval = mkDefault 0;
              ServerAliveCountMax = mkDefault 3;
              HashKnownHosts = mkDefault false;
              UserKnownHostsFile = mkDefault "~/.ssh/known_hosts";
              ControlMaster = mkDefault "no";
              ControlPath = mkDefault "~/.ssh/master-%r@%n:%p";
              ControlPersist = mkDefault "no";
              IdentityFile = identity;
            };
          };
        in
        defaultBlock // hostSettings // zmxPatternSettings;

      inherit (cfg) extraConfig;
    };
    programs.zsh.shellAliases = mkIf cfg.zmx.enable {
      zmls = "${lib.getExe pkgs.zmx} list";
      zmk = "${lib.getExe pkgs.zmx} kill";
      zma = "${lib.getExe pkgs.zmx} attach";
      ash = "${lib.getExe pkgs.autossh} -M 0 -q";
    };

    programs.bash.shellAliases = mkIf cfg.zmx.enable {
      zmls = "${lib.getExe pkgs.zmx} list";
      zmk = "${lib.getExe pkgs.zmx} kill";
      zma = "${lib.getExe pkgs.zmx} attach";
      ash = "${lib.getExe pkgs.autossh} -M 0 -q";
    };

    programs.fish.shellAliases = mkIf cfg.zmx.enable {
      zmls = "${lib.getExe pkgs.zmx} list";
      zmk = "${lib.getExe pkgs.zmx} kill";
      zma = "${lib.getExe pkgs.zmx} attach";
      ash = "${lib.getExe pkgs.autossh} -M 0 -q";
    };
  };
}
