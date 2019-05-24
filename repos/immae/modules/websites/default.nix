{ lib, config, ... }: with lib;
let
  cfg = config.services.websites;
in
{
  options.services.websitesCerts = mkOption {
    description = "Default websites configuration for certificates as accepted by acme";
  };
  options.services.websites = with types; mkOption {
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
          type = listOf string;
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
                type = string;
                description = "The hostname to use for this vhost";
              };
              root = mkOption {
                type = path;
                default = ./nosslVhost;
                description = "The root folder to serve";
              };
              indexFile = mkOption {
                type = string;
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
              certName = mkOption { type = string; };
              hosts    = mkOption { type = listOf string; };
              root     = mkOption { type = nullOr path; };
              extraConfig = mkOption { type = listOf lines; default = []; };
            };
          };
        };
        vhostConfs = mkOption {
          default = {};
          description = "List of vhosts to define for Apache";
          type = attrsOf (submodule {
            options = {
              certName = mkOption { type = string; };
              addToCerts = mkOption {
                type = bool;
                default = false;
                description = "Use these to certificates. Is ignored (considered true) if certMainHost is not null";
              };
              certMainHost = mkOption {
                type = nullOr string;
                description = "Use that host as 'main host' for acme certs";
                default = null;
              };
              hosts    = mkOption { type = listOf string; };
              root     = mkOption { type = nullOr path; };
              extraConfig = mkOption { type = listOf lines; default = []; };
            };
          });
        };
      };
    });
  };

  config.services.httpd = let
    redirectVhost = ips: { # Should go last, catchall http -> https redirect
      listen = map (ip: { inherit ip; port = 80; }) ips;
      hostName = "redirectSSL";
      serverAliases = [ "*" ];
      enableSSL = false;
      logFormat = "combinedVhost";
      documentRoot = "${config.security.acme.directory}/acme-challenge";
      extraConfig = ''
        RewriteEngine on
        RewriteCond "%{REQUEST_URI}"   "!^/\.well-known"
        RewriteRule ^(.+)              https://%{HTTP_HOST}$1  [R=301]
        # To redirect in specific "VirtualHost *:80", do
        #   RedirectMatch 301 ^/((?!\.well-known.*$).*)$ https://host/$1
        # rather than rewrite
      '';
    };
    nosslVhost = ips: cfg: {
      listen = map (ip: { inherit ip; port = 80; }) ips;
      hostName = cfg.host;
      enableSSL = false;
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
      enableSSL = true;
      sslServerCert = "${config.security.acme.directory}/${vhostConf.certName}/cert.pem";
      sslServerKey = "${config.security.acme.directory}/${vhostConf.certName}/key.pem";
      sslServerChain = "${config.security.acme.directory}/${vhostConf.certName}/chain.pem";
      logFormat = "combinedVhost";
      listen = map (ip: { inherit ip; port = 443; }) ips;
      hostName = builtins.head vhostConf.hosts;
      serverAliases = builtins.tail vhostConf.hosts or [];
      documentRoot = vhostConf.root;
      extraConfig = builtins.concatStringsSep "\n" vhostConf.extraConfig;
    };
  in attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
    icfg.httpdName (mkIf icfg.enable {
      enable = true;
      listen = map (ip: { inherit ip; port = 443; }) icfg.ips;
      stateDir = "/run/httpd_${name}";
      logPerVirtualHost = true;
      multiProcessingModule = "worker";
      inherit (icfg) adminAddr;
      logFormat = "combinedVhost";
      extraModules = lists.unique icfg.modules;
      extraConfig = builtins.concatStringsSep "\n" icfg.extraConfig;
      virtualHosts = [ (toVhost icfg.ips icfg.fallbackVhost) ]
        ++ optionals (icfg.nosslVhost.enable) [ (nosslVhost icfg.ips icfg.nosslVhost) ]
        ++ (attrsets.mapAttrsToList (n: v: toVhost icfg.ips v) icfg.vhostConfs)
        ++ [ (redirectVhost icfg.ips) ];
    })
  ) cfg;

  config.security.acme.certs = let
    typesToManage = attrsets.filterAttrs (k: v: v.enable) cfg;
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
    then config.services.websitesCerts // {
      domain = groupToDomain g;
      extraDomains = builtins.listToAttrs (
        map (d: attrsets.nameValuePair d null) (extraDomains g));
    }
    else {
      extraDomains = builtins.listToAttrs (
        map (d: attrsets.nameValuePair d null) (extraDomains g));
    }
  ) groupedCerts;
}
