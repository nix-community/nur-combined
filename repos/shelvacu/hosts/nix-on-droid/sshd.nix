{
  lib,
  pkgs,
  config,
  vaculib,
  ...
}:
let
  inherit (lib) mkOption types;
  # from <nixpkgs>/nixos/modules/networking/ssh/sshd.nix
  settingsFormat =
    let
      # reports boolean as yes / no
      mkValueString =
        v:
        if lib.isInt v then
          toString v
        else if lib.isString v then
          v
        else if true == v then
          "yes"
        else if false == v then
          "no"
        else
          throw "unsupported type ${builtins.typeOf v}: ${(lib.generators.toPretty { }) v}";

      base = pkgs.formats.keyValue {
        mkKeyValue = lib.generators.mkKeyValueDefault { inherit mkValueString; } " ";
      };
      # OpenSSH is very inconsistent with options that can take multiple values.
      # For some of them, they can simply appear multiple times and are appended, for others the
      # values must be separated by whitespace or even commas.
      # Consult either sshd_config(5) or, as last resort, the OpehSSH source for parsing
      # the options at servconf.c:process_server_config_line_depth() to determine the right "mode"
      # for each. But fortunately this fact is documented for most of them in the manpage.
      commaSeparated = [
        "Ciphers"
        "KexAlgorithms"
        "Macs"
      ];
      spaceSeparated = [
        "AuthorizedKeysFile"
        "AllowGroups"
        "AllowUsers"
        "DenyGroups"
        "DenyUsers"
      ];
    in
    {
      inherit (base) type;
      generate =
        name: value:
        let
          transformedValue = lib.mapAttrs (
            key: val:
            if lib.isList val then
              if lib.elem key commaSeparated then
                lib.concatStringsSep "," val
              else if lib.elem key spaceSeparated then
                lib.concatStringsSep " " val
              else
                throw "list value for unknown key ${key}: ${(lib.generators.toPretty { }) val}"
            else
              val
          ) value;
        in
        base.generate name transformedValue;
    };

  configFile = settingsFormat.generate "sshd.conf-settings" (
    lib.filterAttrs (n: v: v != null) cfg.settings
  );
  sshconf = pkgs.runCommand "sshd.conf-final" { } ''
    cat ${configFile} - >$out <<EOL
    ${cfg.extraConfig}
    EOL
  '';

  cfg = config.vacu.sshd;

  settingsModule =
    { name, ... }:
    {
      freeformType = settingsFormat.type;
      options = {
        AuthorizedPrincipalsFile = mkOption {
          type = types.nullOr types.str;
          default = "none"; # upstream default
          description = ''
            Specifies a file that lists principal names that are accepted for certificate authentication. The default
            is `"none"`, i.e. not to use  a principals file.
          '';
        };
        LogLevel = mkOption {
          type = types.nullOr (
            types.enum [
              "QUIET"
              "FATAL"
              "ERROR"
              "INFO"
              "VERBOSE"
              "DEBUG"
              "DEBUG1"
              "DEBUG2"
              "DEBUG3"
            ]
          );
          default = "INFO"; # upstream default
          description = ''
            Gives the verbosity level that is used when logging messages from {manpage}`sshd(8)`. Logging with a DEBUG level
            violates the privacy of users and is not recommended.
          '';
        };
        UsePAM = lib.mkEnableOption "PAM authentication" // {
          default = true;
          type = types.nullOr types.bool;
        };
        UseDns = mkOption {
          type = types.nullOr types.bool;
          # apply if cfg.useDns then "yes" else "no"
          default = false;
          description = ''
            Specifies whether {manpage}`sshd(8)` should look up the remote host name, and to check that the resolved host name for
            the remote IP address maps back to the very same IP address.
            If this option is set to no (the default) then only addresses and not host names may be used in
            ~/.ssh/authorized_keys from and sshd_config Match Host directives.
          '';
        };
        X11Forwarding = mkOption {
          type = types.nullOr types.bool;
          default = false;
          description = ''
            Whether to allow X11 connections to be forwarded.
          '';
        };
        PasswordAuthentication = mkOption {
          type = types.nullOr types.bool;
          default = true;
          description = ''
            Specifies whether password authentication is allowed.
          '';
        };
        PermitRootLogin = mkOption {
          default = "prohibit-password";
          type = types.nullOr (
            types.enum [
              "yes"
              "without-password"
              "prohibit-password"
              "forced-commands-only"
              "no"
            ]
          );
          description = ''
            Whether the root user can login using ssh.
          '';
        };
        KbdInteractiveAuthentication = mkOption {
          type = types.nullOr types.bool;
          default = true;
          description = ''
            Specifies whether keyboard-interactive authentication is allowed.
          '';
        };
        GatewayPorts = mkOption {
          type = types.nullOr types.str;
          default = "no";
          description = ''
            Specifies whether remote hosts are allowed to connect to
            ports forwarded for the client.  See
            {manpage}`sshd_config(5)`.
          '';
        };
        KexAlgorithms = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = [
            "mlkem768x25519-sha256"
            "sntrup761x25519-sha512"
            "sntrup761x25519-sha512@openssh.com"
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
            "diffie-hellman-group-exchange-sha256"
          ];
          description = ''
            Allowed key exchange algorithms

            Uses the lower bound recommended in both
            <https://stribika.github.io/2015/01/04/secure-secure-shell.html>
            and
            <https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67>
          '';
        };
        Macs = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
          ];
          description = ''
            Allowed MACs

            Defaults to recommended settings from both
            <https://stribika.github.io/2015/01/04/secure-secure-shell.html>
            and
            <https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67>
          '';
        };
        StrictModes = mkOption {
          type = types.nullOr (types.bool);
          default = true;
          description = ''
            Whether sshd should check file modes and ownership of directories
          '';
        };
        Ciphers = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = [
            "chacha20-poly1305@openssh.com"
            "aes256-gcm@openssh.com"
            "aes128-gcm@openssh.com"
            "aes256-ctr"
            "aes192-ctr"
            "aes128-ctr"
          ];
          description = ''
            Allowed ciphers

            Defaults to recommended settings from both
            <https://stribika.github.io/2015/01/04/secure-secure-shell.html>
            and
            <https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67>
          '';
        };
        AllowUsers = mkOption {
          type = with types; nullOr (listOf str);
          default = null;
          description = ''
            If specified, login is allowed only for the listed users.
            See {manpage}`sshd_config(5)` for details.
          '';
        };
        DenyUsers = mkOption {
          type = with types; nullOr (listOf str);
          default = null;
          description = ''
            If specified, login is denied for all listed users. Takes
            precedence over [](#opt-services.openssh.settings.AllowUsers).
            See {manpage}`sshd_config(5)` for details.
          '';
        };
        AllowGroups = mkOption {
          type = with types; nullOr (listOf str);
          default = null;
          description = ''
            If specified, login is allowed only for users part of the
            listed groups.
            See {manpage}`sshd_config(5)` for details.
          '';
        };
        DenyGroups = mkOption {
          type = with types; nullOr (listOf str);
          default = null;
          description = ''
            If specified, login is denied for all users part of the listed
            groups. Takes precedence over
            [](#opt-services.openssh.settings.AllowGroups). See
            {manpage}`sshd_config(5)` for details.
          '';
        };
        # Disabled by default, since pam_motd handles this.
        PrintMotd = lib.mkEnableOption "printing /etc/motd when a user logs in interactively" // {
          type = types.nullOr types.bool;
        };

      };
    };
in
{
  options.vacu.sshd = {
    enable = lib.mkEnableOption "openssh server";

    package = mkOption {
      type = types.package;
      default = config.vacu.git.package;
      defaultText = lib.literalExpression "config.vacu.git.package";
      description = "OpenSSH package to use for sshd.";
    };

    authorizedKeys = mkOption {
      type = types.listOf types.singleLineStr;
      default = [ ];
    };

    allowSFTP = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable the SFTP subsystem in the SSH daemon.  This
        enables the use of commands such as {command}`sftp` and
        {command}`sshfs`.
      '';
    };

    sftpServerExecutable = mkOption {
      type = types.str;
      example = "internal-sftp";
      description = ''
        The sftp server executable.  Can be a path or "internal-sftp" to use
        the sftp server built into the sshd binary.
      '';
    };

    sftpFlags = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [
        "-f AUTHPRIV"
        "-l INFO"
      ];
      description = ''
        Commandline flags to add to sftp-server.
      '';
    };

    ports = mkOption {
      type = types.listOf types.port;
      default = [ 22 ];
      description = ''
        Specifies on which ports the SSH daemon listens.
      '';
    };

    listenAddresses = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            addr = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = ''
                Host, IPv4 or IPv6 address to listen to.
              '';
            };
            port = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = ''
                Port to listen to.
              '';
            };
          };
        }
      );
      default = [ ];
      example = [
        {
          addr = "192.168.3.1";
          port = 22;
        }
        {
          addr = "0.0.0.0";
          port = 64022;
        }
      ];
      description = ''
        List of addresses and ports to listen on (ListenAddress directive
        in config). If port is not specified for address sshd will listen
        on all ports specified by `ports` option.
        NOTE: this will override default listening on all local addresses and port 22.
        NOTE: setting this option won't automatically enable given ports
        in firewall configuration.
      '';
    };

    hostKeys = mkOption {
      type = types.listOf types.attrs;
      default = [
        {
          type = "rsa";
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
        }
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
        }
      ];
      example = [
        {
          type = "rsa";
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          openSSHFormat = true;
        }
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
          comment = "key comment";
        }
      ];
      description = ''
        NixOS can automatically generate SSH host keys.  This option
        specifies the path, type and size of each key.  See
        {manpage}`ssh-keygen(1)` for supported types
        and sizes.
      '';
    };

    banner = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = ''
        Message to display to the remote user before authentication is allowed.
      '';
    };

    authorizedKeysFiles = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Specify the rules for which files to read on the host.

        This is an advanced option. If you're looking to configure user
        keys, you can generally use [](#opt-users.users._name_.openssh.authorizedKeys.keys)
        or [](#opt-users.users._name_.openssh.authorizedKeys.keyFiles).

        These are paths relative to the host root file system or home
        directories and they are subject to certain token expansion rules.
        See AuthorizedKeysFile in man sshd_config for details.
      '';
    };

    authorizedKeysInHomedir = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enables the use of the `~/.ssh/authorized_keys` file.

        Otherwise, the only files trusted by default are those in `/etc/ssh/authorized_keys.d`,
        *i.e.* SSH keys from [](#opt-users.users._name_.openssh.authorizedKeys.keys).
      '';
    };

    authorizedKeysCommand = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Specifies a program to be used to look up the user's public
        keys. The program must be owned by root, not writable by group
        or others and specified by an absolute path.
      '';
    };

    authorizedKeysCommandUser = mkOption {
      type = types.str;
      default = "nobody";
      description = ''
        Specifies the user under whose account the AuthorizedKeysCommand
        is run. It is recommended to use a dedicated user that has no
        other role on the host than running authorized keys commands.
      '';
    };

    settings = mkOption {
      description = "Configuration for `sshd_config(5)`.";
      default = { };
      example = lib.literalExpression ''
        {
          UseDns = true;
          PasswordAuthentication = false;
        }
      '';
      type = types.submodule settingsModule;
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Verbatim contents of {file}`sshd_config`.";
    };

    moduliFile = mkOption {
      example = "/etc/my-local-ssh-moduli;";
      type = types.path;
      description = ''
        Path to `moduli` file to install in
        `/etc/ssh/moduli`. If this option is unset, then
        the `moduli` file shipped with OpenSSH will be used.
      '';
    };

  };

  config = lib.mkIf cfg.enable {
    vacu.sshd.moduliFile = lib.mkDefault "${cfg.package}/etc/ssh/moduli";
    vacu.sshd.sftpServerExecutable = lib.mkDefault "${cfg.package}/libexec/sftp-server";

    environment.etc =
      { }
      # // authKeysFiles
      # // authPrincipalsFiles
      // {
        "ssh/moduli".source = cfg.moduliFile;
        "ssh/sshd_config".source = sshconf;
      };

    vacu.sshd.extraConfig = lib.mkOrder 0 ''
      Banner ${if cfg.banner == null then "none" else pkgs.writeText "ssh_banner" cfg.banner}

      AddressFamily ${if config.networking.enableIPv6 then "any" else "inet"}
      ${lib.concatMapStrings (port: ''
        Port ${toString port}
      '') cfg.ports}

      ${lib.concatMapStrings (
        { port, addr, ... }:
        ''
          ListenAddress ${addr}${lib.optionalString (port != null) (":" + toString port)}
        ''
      ) cfg.listenAddresses}

      ${lib.optionalString cfg.allowSFTP ''
        Subsystem sftp ${cfg.sftpServerExecutable} ${lib.concatStringsSep " " cfg.sftpFlags}
      ''}
      AuthorizedKeysFile ${toString cfg.authorizedKeysFiles}
      ${lib.optionalString (cfg.authorizedKeysCommand != null) ''
        AuthorizedKeysCommand ${cfg.authorizedKeysCommand}
        AuthorizedKeysCommandUser ${cfg.authorizedKeysCommandUser}
      ''}

      ${lib.flip lib.concatMapStrings cfg.hostKeys (k: ''
        HostKey ${k.path}
      '')}
    '';

    vacu.packages = [
      (pkgs.writeScriptBin "run-sshd" ''
        ${lib.flip lib.concatMapStrings cfg.hostKeys (k: ''
          declare keyPath=${lib.escapeShellArg k.path}
          if ! [ -s "$keyPath" ]; then
              if ! [ -h "$keyPath" ]; then
                  rm -f "$keyPath"
              fi
              declare keyDir
              keyDir="$(dirname -- "$keyPath")"
              mkdir -p -- "$keyDir"
              chmod u=rwx,g=rx,o=rx -- "$keyDir"
              ssh-keygen \
                -t "${lib.escapeShellArg k.type}" \
                ${lib.optionalString (k ? bits) "-b ${toString k.bits}"} \
                ${lib.optionalString (k ? rounds) "-a ${toString k.rounds}"} \
                ${lib.optionalString (k ? comment) "-C ${lib.escapeShellArg k.comment}"} \
                ${lib.optionalString (k ? openSSHFormat && k.openSSHFormat) "-o"} \
                -f "$keyPath" \
                -N ""
          fi
        '')}
        exec ${cfg.package}/bin/sshd -D -f /etc/ssh/sshd_config "$@"
      '')
    ];

    vacu.checks = [
      (pkgs.runCommand "check-sshd-config"
        {
          nativeBuildInputs = [
            (
              if pkgs.stdenv.buildPlatform == pkgs.stdenv.hostPlatform then
                cfg.package
              else
                pkgs.buildPackages.openssh
            )
          ];
        }
        ''
          ${lib.concatMapStringsSep "\n" (
            lport: "sshd -G -T -C lport=${toString lport} -f ${sshconf} > /dev/null"
          ) cfg.ports}
          ${lib.concatMapStringsSep "\n" (
            la:
            lib.concatMapStringsSep "\n" (
              port:
              "sshd -G -T -C ${lib.escapeShellArg "laddr=${la.addr},lport=${toString port}"} -f ${sshconf} > /dev/null"
            ) (if la.port != null then [ la.port ] else cfg.ports)
          ) cfg.listenAddresses}
          touch $out
        ''
      )
    ];

  };
}
