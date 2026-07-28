{
  config,
  vaculib,
  pkgs,
  lib,
  ...
}:
let
  domain = "wiki.pm3.dev";
  plugin-preregister = pkgs.fetchFromGitHub {
    name = "preregister";
    owner = "c3lingo";
    repo = "dokuwiki-preregister";
    rev = "b4804c8a8c1346b6801cc2f3c041740cdd83af5c";
    hash = "sha256-lvpcyDeCGHb4UQ8PiMtOKLA1CmRWFmsoiREiFbz1f3o=";
  };
  plugin-smtp = pkgs.fetchFromGitHub {
    name = "smtp";
    owner = "splitbrain";
    repo = "dokuwiki-plugin-smtp";
    tag = "2025-08-27";
    hash = "sha256-bWw8PNHVUz2AfFHDu4Vy+vzRCMPk8Hd+I9vTtKo06B4=";
  };
in
{
  imports = vaculib.directoryGrabberList {
    path = ./.;
    ignore = [ ./dokuwiki-all-media.patch ];
  };
  services.caddy.virtualHosts.${domain}.vacu.hsts = false;
  fileSystems =
    lib.pipe
      [ "attic" "pages" "media-attic" "media" ]
      [
        (map (
          folder:
          lib.nameValuePair "/wiki-pm3-public/${folder}" {
            device = "/persistence/var/lib/dokuwiki/${domain}/data/${folder}";
            fsType = "none";
            options = [
              "ro"
              "nofail"
              "bind"
              "X-mount.mkdir=${
                vaculib.accessModeStr {
                  all = {
                    read = true;
                    execute = true;
                  };
                }
              }"
            ];
          }
        ))
        builtins.listToAttrs
      ];
  services.caddy.virtualHosts."dl.${domain}" = {
    vacu.hsts = false;
    extraConfig = ''
      root /wiki-pm3-public
      file_server browse
    '';
  };
  services.dokuwiki.webserver = "caddy";
  services.dokuwiki.sites.${domain} = {
    package = pkgs.dokuwiki.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./dokuwiki-all-media.patch ];
    });
    plugins = [
      plugin-preregister
      plugin-smtp
    ];
    pluginsConfig = {
      preregister = true;
    };
    phpOptions."upload_max_filesize" = "100G";
    phpOptions."post_max_size" = "100G";
    settings = {
      title = "PM3 Wiki";
      basedir = "/";
      baseurl = "https://wiki.pm3.dev";
      useacl = true;
      superuser = "@superuser";
      defaultgroup = "user,emailverified";
      autopasswd = false;
      userewrite = true;
      iexssprotect = false; # it's only helpful for a browser nobody uses, and isn't very good protection anyways
      subscribers = true;
      mailfrom = ''"PM3 Wiki" <noreply@wiki.pm3.dev>'';
      updatecheck = false;
      autoplural = true;
      dnslookups = false;
      dformat = "%Y-%m-%d %H:%M %Z (%f)";
      auth_security_timeout = 10;

      plugin.preregister = {
        send_confirm = true;
        captcha = "none";
      };
      plugin.smtp = {
        smtp_host = "smtp.shelvacu.com";
        smtp_port = 465;
        smtp_ssl = "ssl";
        auth_user = "pm3-wiki";
        auth_pass._file = config.sops.secrets.pm3WikiMailKey.path;
        debug = true;
      };
    };
    acl = [
      {
        page = "*";
        actor = "@ALL";
        level = "read";
      }
      {
        page = "*";
        actor = "@approved";
        level = "upload";
      }
      {
        page = "*";
        actor = "@emailverified";
        level = "upload";
      }
    ];
  };

  sops.secrets.pm3WikiMailKey = {
    owner = "dokuwiki";
  };

  # vacu.pm3Wiki.msmtp = {
  #   enable = true;
  #   defaults = {
  #     host = "smtp.shelvacu.com";
  #     port = "465";
  #     tls = true;
  #     tls_starttls = false;
  #     auth = true;
  #     user = "pm3-wiki";
  #     passwordeval = "cat ${config.sops.secrets.pm3WikiMailKey.path}";
  #     from = "system@wiki.pm3.dev";
  #   };
  # };
}
