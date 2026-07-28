{
  config,
  lib,
  pkgs,
  vaculib,
  ...
}:
let
  ip = "127.55.41.113";
  port = 5590;
  dist_port = 58449;
  couchdb_package = config.services.couchdb.package;
  vm_file = pkgs.runCommand "vm.args" { } ''
    cat ${couchdb_package}/etc/vm.args > $out
    # sed -i '/inet_dist_use_interface/d' $out
    echo "-kernel inet_dist_listen_min ${toString dist_port}" >> $out
    echo "-kernel inet_dist_listen_max ${toString dist_port}" >> $out
  '';
in
{
  services.couchdb = {
    enable = true;
    argsFile = vm_file;
    extraConfig = {
      couchdb = {
        enable_database_recovery = true;
        single_node = true;
        users_db_security_editable = false;
      };
      chttpd = {
        bind_address = ip;
        inherit port;
        # authentication_handlers = "{chttpd_auth, cookie_authentication_handler}, {chttpd_auth, default_authentication_handler}";
        config_whitelist = "";
        # require_valid_user = true;
        # require_valid_user_except_for_up = true;
      };
      x_frame_options = { };
      admins.admin = "-pbkdf2:sha256-280dea79f48353496827eeb24c9e1790ca5cbb2eacf84de377b64e3f1db891cb,0b7b84d73831d26d2d72ac8591d8db3a,600000";
      chttpd_auth = {
        same_site = "strict";
        hash_algorithms = "sha256";
        timeout = 7 * 24 * 60 * 60;
      };
      vendor.name = "Shelvacu";
      csp = {
        utils_enable = true;
        attachments_enable = true;
        showlist_enable = true;
      };
    };
  };

  systemd.services.couchdb.serviceConfig = {
    # ExecStart = lib.mkForce "${pkgs.strace}/bin/strace -f -e trace=bind ${couchdb_package}/bin/couchdb";
    RestrictAddressFamilies = lib.mkForce [
      "AF_INET"
      "AF_INET6"
    ];
    SocketBindAllow = [
      "tcp:${toString port}"
      # i cant figure out how to get it to not listen on a port for this. i dont need it
      "tcp:${toString dist_port}"
    ];
    # this just always breaks it aaahhhh
    # SocketBindDeny = "any";
    StateDirectory = "couchdb";
    StateDirectoryMode = vaculib.accessModeStr { user = "all"; };
  };

  services.caddy.virtualHosts = {
    "couchdb.shelvacu.com" = {
      vacu.hsts = "preload";
      extraConfig = ''
        reverse_proxy http://${ip}:${toString port}
      '';
    };

    "couch.shelvacu.com" = {
      vacu.hsts = "preload";
      extraConfig = "redir * https://couchdb.shelvacu.com{uri}";
    };
  };
}
