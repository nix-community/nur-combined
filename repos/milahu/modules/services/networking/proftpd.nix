{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.proftpd;

  inherit (pkgs) proftpd;

  configFile = pkgs.writeText "proftpd.conf"
    ''
      ${cfg.config}
    '';
in

{
  # based on nixpkgs/nixos/modules/services/networking/vsftpd.nix

  ###### interface

  options = {

    services.proftpd = {

      enable = mkEnableOption "proftpd";

      args = mkOption {
        default = [];
        description = "Arguments for the proftpd command.";
      };

      config = mkOption {
        default = "";
        description = "Content for the proftpd.conf configuration file.";
        # see also
        # man proftpd
        # man proftpd.conf
        # https://github.com/proftpd/proftpd/tree/master/sample-configurations
        # http://www.proftpd.org/docs/howto/Chroot.html
        # http://www.proftpd.org/docs/howto/Debugging.html

        # check configfile
        # ./pkgs/proftpd/result/bin/proftpd -c /nix/store/bar0wxfdq9nwn4v4psznvks5gwzwj6j2-proftpd.conf -d10 -t

        # run server in foreground
        # ./pkgs/proftpd/result/bin/proftpd -c /nix/store/bar0wxfdq9nwn4v4psznvks5gwzwj6j2-proftpd.conf -d10 -n
        # ./pkgs/proftpd/result/bin/proftpd -c $(readlink -f proftpd.conf) -d10 -n

        # test client
        # curl ftp://127.0.0.1/ -v

        # note: to keep your configuration.nix clean, you can use
        # `services.proftpd.config = builtins.readFile ./path/to/proftpd.conf;`

        example = ''
          # This is a basic ProFTPD configuration file
          # It establishes a single server and a single anonymous login.
          # It assumes that you have a user/group
          # "nobody" and "ftp" for normal operation and anon.

          # http://www.proftpd.org/docs/directives/index.html

          # NOTE: the /var/proftpd/ are also used in systemd.services.proftpd

          # ScoreboardFile: path to the file
          # where the daemon will store its run-time "scoreboard" session information.
          # This file is necessary for support features such as MaxClients to work properly
          # proftpd fails with default value (read-only filesystem)
          ScoreboardFile                  "/var/proftpd/proftpd.scoreboard"

          # PidFile: path to which the daemon process records its process ID (PID).
          # proftpd fails with default value (read-only filesystem)
          PidFile                         "/var/proftpd/proftpd.pid"

          # SystemLog disables proftpd's use of the syslog mechanism
          # and instead redirects all logging output to the specified path
          SystemLog                       "/var/proftpd/proftpd.log"

          #SyslogLevel notice # default
          #SyslogLevel info
          SyslogLevel debug
          DebugLevel 10

          ServerName			"ProFTPD FTP Server"
          ServerType			standalone
          DefaultServer			on

          # Port 21 is the standard FTP port.
          Port				21

          # Don't use IPv6 support by default.
          UseIPv6				off

          # Umask 022 is a good standard umask to prevent new dirs and files
          # from being group and world writable.
          Umask				022

          # To prevent DoS attacks, set the maximum number of child processes
          # to 30.  If you need to allow more than 30 concurrent connections
          # at once, simply increase this value.  Note that this ONLY works
          # in standalone mode, in inetd mode you should use an inetd server
          # that allows you to limit maximum number of processes per service
          # (such as xinetd).
          MaxInstances			30

          # Set the user and group under which the server will run.
          User				nobody
          Group				nogroup

          # To cause every FTP user to be "jailed" (chrooted) into their home
          # directory, uncomment this line.
          #DefaultRoot ~

          # Normally, we want files to be overwriteable.
          AllowOverwrite		on

          # Bar use of SITE CHMOD by default
          <Limit SITE_CHMOD>
            DenyAll
          </Limit>

          # A basic anonymous configuration, no upload directories.  If you do not
          # want anonymous users, simply delete this entire <Anonymous> section.
          # The <Anonymous> configuration section is used to create an anonymous FTP login,
          # and is closed by a matching </Anonymous> directive.
          # The anon-directory parameter specifies the directory to which the daemon,
          # immediately after successful authentication, will restrict the session via chroot(2).
          #<Anonymous ~ftp>
          <Anonymous /home/user/src/project>
            # the user needs read access to the 
            #User				ftp
            #Group				ftp
            User				user
            Group				users

            # We want clients to be able to login with "anonymous" as well as "ftp"
            #UserAlias			anonymous ftp

            # Limit the maximum number of anonymous logins
            MaxClients			10

            # We want 'welcome.msg' displayed at login, and '.message' displayed
            # in each newly chdired directory.
            DisplayLogin			welcome.msg
            DisplayChdir			.message

            # Limit WRITE everywhere in the anonymous chroot
            <Limit WRITE>
              DenyAll
            </Limit>
          </Anonymous>
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    users.users = {
      "proftpd" = {
        group = "proftpd";
        isSystemUser = true;
        description = "proftpd user";
        home = "/homeless-shelter";
        #home = if cfg.localRoot != null
        #       then cfg.localRoot # <= Necessary for virtual users.
        #       else "/homeless-shelter";
      };
    }
    # // optionalAttrs cfg.anonymousUser {
    #  "ftp" = { name = "ftp";
    #      uid = config.ids.uids.ftp;
    #      group = "ftp";
    #      description = "Anonymous FTP user";
    #      home = cfg.anonymousUserHome;
    #    };
    #}
    ;

    users.groups.proftpd = {};
    users.groups.ftp.gid = config.ids.gids.ftp;

    # based on proftpd/contrib/dist/rpm/proftpd.service
    systemd.services.proftpd = {
      description = "ProFTPD FTP Server";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" "nss-lookup.target" "local-fs.target" "remote-fs.target" ];
      preStart = ''
        mkdir -p /var/proftpd
        chmod -R +w /var/proftpd
      '';
      serviceConfig = {
        #Type = "simple";
        Type = "exec";
        ExecStartPre = [
          "${pkgs.bash}/bin/bash -c 'echo proftpd configfile is ${configFile}'"
          "${proftpd}/bin/proftpd --configtest --config ${configFile}"
        ];
        ExecStart = "${proftpd}/bin/proftpd --nodaemon --config ${configFile} ${lib.escapeShellArgs cfg.args}";
        ExecReload = "${pkgs.procps}/bin/kill -s HUP $MAINPID";
        Environment = "PROFTPD_OPTIONS=";
        PIDFile = "/var/proftpd/proftpd.pid";
        Restart = "on-failure";
      };
    };
  };
}
