{ lib, config, pkgs, ... }: with lib;
let
  cfg = config.services.websites;
in
{
  options.services.websites = with types; {
    certs = mkOption {
      description = "Default websites configuration for certificates as accepted by acme";
    };
    webappDirs = mkOption {
      description = ''
        Defines a symlink between /run/current-system/webapps and a store
        app directory to be used in http configuration. Permits to avoid
        restarting httpd when only the folder name changes.
        '';
      type = types.attrsOf types.path;
      default = {};
    };
    webappDirsName = mkOption {
      type = str;
      default = "webapps";
      description = ''
        Name of the webapp dir to create in /run/current-system
        '';
    };
    env = mkOption {
      default = {};
      description = "Each type of website to enable will target a distinct httpd server";
      type = attrsOf (submodule {
        options = {
          enable = mkEnableOption "Enable websites of this type";
          adminAddr = mkOption {
            type = str;
            description = "Admin e-mail address of the instance";
          };
          httpdName = mkOption {
            type = str;
            description = "Name of the httpd instance to assign this type to";
          };
          ips = mkOption {
            type = listOf str;
            default = [];
            description = "ips to listen to";
          };
          modules = mkOption {
            type = listOf str;
            default = [];
            description = "Additional modules to load in Apache";
          };
          extraConfig = mkOption {
            type = listOf lines;
            default = [];
            description = "Additional configuration to append to Apache";
          };
          nosslVhost = mkOption {
            description = "A default nossl vhost for captive portals";
            default = {};
            type = submodule {
              options = {
                enable = mkEnableOption "Add default no-ssl vhost for this instance";
                host = mkOption {
                  type = str;
                  description = "The hostname to use for this vhost";
                };
                root = mkOption {
                  type = path;
                  default = ./nosslVhost;
                  description = "The root folder to serve";
                };
                indexFile = mkOption {
                  type = str;
                  default = "index.html";
                  description = "The index file to show.";
                };
              };
            };
          };
          fallbackVhost = mkOption {
            description = "The fallback vhost that will be defined as first vhost in Apache";
            type = submodule {
              options = {
                certName = mkOption { type = str; };
                hosts    = mkOption { type = listOf str; };
                root     = mkOption { type = nullOr path; };
                forceSSL = mkOption {
                  type = bool;
                  default = true;
                  description = ''
                    Automatically create a corresponding non-ssl vhost
                    that will only redirect to the ssl version
                  '';
                };
                extraConfig = mkOption { type = listOf lines; default = []; };
              };
            };
          };
          vhostNoSSLConfs = mkOption {
            default = {};
            description = "List of no ssl vhosts to define for Apache";
            type = attrsOf (submodule {
              options = {
                hosts    = mkOption { type = listOf str; };
                root     = mkOption { type = nullOr path; };
                extraConfig = mkOption { type = listOf lines; default = []; };
              };
            });
          };
          vhostConfs = mkOption {
            default = {};
            description = "List of vhosts to define for Apache";
            type = attrsOf (submodule {
              options = {
                certName = mkOption { type = str; };
                addToCerts = mkOption {
                  type = bool;
                  default = false;
                  description = "Use these to certificates. Is ignored (considered true) if certMainHost is not null";
                };
                certMainHost = mkOption {
                  type = nullOr str;
                  description = "Use that host as 'main host' for acme certs";
                  default = null;
                };
                hosts    = mkOption { type = listOf str; };
                root     = mkOption { type = nullOr path; };
                forceSSL = mkOption {
                  type = bool;
                  default = true;
                  description = ''
                    Automatically create a corresponding non-ssl vhost
                    that will only redirect to the ssl version
                  '';
                };
                extraConfig = mkOption { type = listOf lines; default = []; };
              };
            });
          };
          watchPaths = mkOption {
            type = listOf str;
            default = [];
            description = ''
              Paths to watch that should trigger a reload of httpd
              '';
          };
        };
      });
    };
    # Readonly variables
    webappDirsPaths = mkOption {
      type = attrsOf path;
      readOnly = true;
      description = ''
        Full paths of the webapp dir
        '';
      default = attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
        name "/run/current-system/${cfg.webappDirsName}/${name}"
      ) cfg.webappDirs;
    };
  };

  config.services.httpd = let
    nosslVhost = ips: cfg: {
      listen = map (ip: { inherit ip; port = 80; }) ips;
      hostName = cfg.host;
      logFormat = "combinedVhost";
      documentRoot = cfg.root;
      extraConfig = ''
        <Directory ${cfg.root}>
          DirectoryIndex ${cfg.indexFile}
          AllowOverride None
          Require all granted

          RewriteEngine on
          RewriteRule ^/(.+)   /   [L]
        </Directory>
        '';
    };
    toVhost = ips: vhostConf: {
      forceSSL = vhostConf.forceSSL or true;
      useACMEHost = vhostConf.certName;
      logFormat = "combinedVhost";
      listen = if vhostConf.forceSSL
        then lists.flatten (map (ip: [{ inherit ip; port = 443; ssl = true; } { inherit ip; port = 80; }]) ips)
        else map (ip: { inherit ip; port = 443; ssl = true; }) ips;
      hostName = builtins.head vhostConf.hosts;
      serverAliases = builtins.tail vhostConf.hosts or [];
      documentRoot = vhostConf.root;
      extraConfig = builtins.concatStringsSep "\n" vhostConf.extraConfig;
    };
    toVhostNoSSL = ips: vhostConf: {
      logFormat = "combinedVhost";
      listen = map (ip: { inherit ip; port = 80; }) ips;
      hostName = builtins.head vhostConf.hosts;
      serverAliases = builtins.tail vhostConf.hosts or [];
      documentRoot = vhostConf.root;
      extraConfig = builtins.concatStringsSep "\n" vhostConf.extraConfig;
    };
  in attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
    icfg.httpdName (mkIf icfg.enable {
      enable = true;
      logPerVirtualHost = true;
      multiProcessingModule = "worker";
      # https://ssl-config.mozilla.org/#server=apache&version=2.4.41&config=intermediate&openssl=1.0.2t&guideline=5.4
      sslProtocols = "all -SSLv3 -TLSv1 -TLSv1.1";
      sslCiphers = builtins.concatStringsSep ":" [
        "ECDHE-ECDSA-AES128-GCM-SHA256" "ECDHE-RSA-AES128-GCM-SHA256"
        "ECDHE-ECDSA-AES256-GCM-SHA384" "ECDHE-RSA-AES256-GCM-SHA384"
        "ECDHE-ECDSA-CHACHA20-POLY1305" "ECDHE-RSA-CHACHA20-POLY1305"
        "DHE-RSA-AES128-GCM-SHA256" "DHE-RSA-AES256-GCM-SHA384"
      ];
      inherit (icfg) adminAddr;
      logFormat = "combinedVhost";
      extraModules = lists.unique icfg.modules;
      extraConfig = builtins.concatStringsSep "\n" icfg.extraConfig;

      virtualHosts = with attrsets; {
        ___fallbackVhost = toVhost icfg.ips icfg.fallbackVhost;
      } // (optionalAttrs icfg.nosslVhost.enable {
        nosslVhost = nosslVhost icfg.ips icfg.nosslVhost;
      }) // (mapAttrs' (n: v: nameValuePair ("nossl_" + n) (toVhostNoSSL icfg.ips v)) icfg.vhostNoSSLConfs)
      // (mapAttrs' (n: v: nameValuePair ("ssl_" + n) (toVhost icfg.ips v)) icfg.vhostConfs);
    })
  ) cfg.env;

  config.services.filesWatcher = attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
    "httpd${icfg.httpdName}" {
      paths = icfg.watchPaths;
      waitTime = 5;
    }
  ) cfg.env;

  config.security.acme.certs = let
    typesToManage = attrsets.filterAttrs (k: v: v.enable) cfg.env;
    flatVhosts = lists.flatten (attrsets.mapAttrsToList (k: v:
      attrValues v.vhostConfs
    ) typesToManage);
    groupedCerts = attrsets.filterAttrs
      (_: group: builtins.any (v: v.addToCerts || !isNull v.certMainHost) group)
      (lists.groupBy (v: v.certName) flatVhosts);
    groupToDomain = group:
      let
        nonNull = builtins.filter (v: !isNull v.certMainHost) group;
        domains = lists.unique (map (v: v.certMainHost) nonNull);
      in
        if builtins.length domains == 0
          then null
          else assert (builtins.length domains == 1); (elemAt domains 0);
    extraDomains = group:
      let
        mainDomain = groupToDomain group;
      in
        lists.remove mainDomain (
          lists.unique (
            lists.flatten (map (c: optionals (c.addToCerts || !isNull c.certMainHost) c.hosts) group)
          )
        );
  in attrsets.mapAttrs (k: g:
    if (!isNull (groupToDomain g))
    then cfg.certs // {
      domain = groupToDomain g;
      extraDomains = builtins.listToAttrs (
        map (d: attrsets.nameValuePair d null) (extraDomains g));
    }
    else {
      extraDomains = builtins.listToAttrs (
        map (d: attrsets.nameValuePair d null) (extraDomains g));
    }
  ) groupedCerts;

  config.system.extraSystemBuilderCmds = lib.mkIf (builtins.length (builtins.attrValues cfg.webappDirs) > 0) ''
    mkdir -p $out/${cfg.webappDirsName}
    ${builtins.concatStringsSep "\n"
      (attrsets.mapAttrsToList
        (name: path: "ln -s ${path} $out/${cfg.webappDirsName}/${name}") cfg.webappDirs)
    }
  '';

  config.systemd.services = let
    package = httpdName: config.services.httpd.${httpdName}.package.out;
    cfgFile = httpdName: config.services.httpd.${httpdName}.configFile;
    serviceChange = attrsets.mapAttrs' (name: icfg:
      attrsets.nameValuePair
      "httpd${icfg.httpdName}" {
        stopIfChanged = false;
        serviceConfig.ExecStart =
          lib.mkForce "@${package icfg.httpdName}/bin/httpd httpd -f /etc/httpd/httpd_${icfg.httpdName}.conf";
        serviceConfig.ExecStop =
          lib.mkForce "${package icfg.httpdName}/bin/httpd -f /etc/httpd/httpd_${icfg.httpdName}.conf -k graceful-stop";
        serviceConfig.ExecReload =
          lib.mkForce "${package icfg.httpdName}/bin/httpd -f /etc/httpd/httpd_${icfg.httpdName}.conf -k graceful";
      }
      ) cfg.env;
    serviceReload = attrsets.mapAttrs' (name: icfg:
      attrsets.nameValuePair
      "httpd${icfg.httpdName}-config-reload" {
        wants = [ "httpd${icfg.httpdName}.service" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [ (cfgFile icfg.httpdName) ];
        # commented, because can cause extra delays during activate for this config:
        #      services.nginx.virtualHosts."_".locations."/".proxyPass = "http://blabla:3000";
        # stopIfChanged = false;
        serviceConfig.Type = "oneshot";
        serviceConfig.TimeoutSec = 60;
        script = ''
          if ${pkgs.systemd}/bin/systemctl -q is-active httpd${icfg.httpdName}.service ; then
            ${package icfg.httpdName}/bin/httpd -f /etc/httpd/httpd_${icfg.httpdName}.conf -t && \
              ${pkgs.systemd}/bin/systemctl reload httpd${icfg.httpdName}.service
          fi
        '';
        serviceConfig.RemainAfterExit = true;
      }
      ) cfg.env;
  in
    serviceChange // serviceReload;
}
