{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.zju-connect;

  # Base config template (without secrets)
  configTemplate = pkgs.writeText "zju-connect-template.toml" ''
    protocol = "${cfg.protocol}"
    username = "${cfg.username}"
    password = "__PASSWORD__"
    ${optionalString (cfg.totpSecret != null || cfg.totpSecretFile != null) ''totp_secret = "__TOTP_SECRET__"''}
    ${optionalString (cfg.certFile != null) ''cert_file = "${cfg.certFile}"''}
    ${optionalString (cfg.certPassword != null || cfg.certPasswordFile != null) ''cert_password = "__CERT_PASSWORD__"''}

    # Advanced settings
    server_address = "${cfg.serverAddress}"
    server_port = ${toString cfg.serverPort}
    disable_server_config = ${boolToString cfg.disableServerConfig}
    skip_domain_resource = ${boolToString cfg.skipDomainResource}
    disable_zju_config = ${boolToString cfg.disableZjuConfig}
    disable_zju_dns = ${boolToString cfg.disableZjuDns}
    disable_multi_line = ${boolToString cfg.disableMultiLine}
    proxy_all = ${boolToString cfg.proxyAll}
    socks_bind = "${cfg.socksBind}"
    ${optionalString (cfg.socksUser != null) ''socks_user = "${cfg.socksUser}"''}
    ${optionalString (cfg.socksPassword != null || cfg.socksPasswordFile != null) ''socks_passwd = "__SOCKS_PASSWORD__"''}
    http_bind = "${cfg.httpBind}"
    ${optionalString (cfg.shadowsocksUrl != null) ''shadowsocks_url = "${cfg.shadowsocksUrl}"''}
    ${optionalString (cfg.dialDirectProxy != null) ''dial_direct_proxy = "${cfg.dialDirectProxy}"''}
    tun_mode = ${boolToString cfg.tunMode}
    add_route = ${boolToString cfg.addRoute}
    dns_ttl = ${toString cfg.dnsTtl}
    disable_keep_alive = ${boolToString cfg.disableKeepAlive}
    zju_dns_server = "${cfg.zjuDnsServer}"
    secondary_dns_server = "${cfg.secondaryDnsServer}"
    ${optionalString (cfg.dnsServerBind != null) ''dns_server_bind = "${cfg.dnsServerBind}"''}
    dns_hijack = ${boolToString cfg.dnsHijack}
    debug_dump = ${boolToString cfg.debugDump}

    # aTrust settings
    auth_type = "${cfg.authType}"
    login_domain = "${cfg.loginDomain}"
    ${optionalString (cfg.graphCodeFile != null) ''graph_code_file = "${cfg.graphCodeFile}"''}
    ${optionalString (cfg.casTicket != null || cfg.casTicketFile != null) ''cas_ticket = "__CAS_TICKET__"''}
    ${optionalString (cfg.clientDataFile != null) ''client_data_file = "${cfg.clientDataFile}"''}
    ${optionalString (cfg.resourceFile != null) ''resource_file = "${cfg.resourceFile}"''}

    # Port forwarding
    port_forwarding = [
    ${concatMapStringsSep "\n" (fwd: ''
      { network_type = "${fwd.networkType}", bind_address = "${fwd.bindAddress}", remote_address = "${fwd.remoteAddress}" },
    '') cfg.portForwarding}
    ]

    # Custom DNS
    custom_dns = [
    ${concatMapStringsSep "\n" (dns: ''
      { host_name = "${dns.hostname}", ip = "${dns.ip}" },
    '') cfg.customDns}
    ]

    # Custom proxy domains
    custom_proxy_domain = [
    ${concatMapStringsSep "\n" (domain: ''
      "${domain}",
    '') cfg.customProxyDomain}
    ]
  '';

  # Wrapper script that generates config with secrets at runtime
  zjuConnectWrapper = pkgs.writeShellScriptBin "zju-connect" ''
    set -euo pipefail

    # Create temporary config file
    RUNTIME_CONFIG=$(mktemp)
    trap "rm -f $RUNTIME_CONFIG" EXIT

    # Copy template to runtime config
    cp ${configTemplate} "$RUNTIME_CONFIG"

    # Read password from file or use direct value
    ${if cfg.passwordFile != null then ''
      PASSWORD=$(cat "${cfg.passwordFile}")
    '' else ''
      PASSWORD="${cfg.password}"
    ''}

    # Replace password placeholder
    ${pkgs.gnused}/bin/sed -i "s|__PASSWORD__|$PASSWORD|g" "$RUNTIME_CONFIG"

    # Handle TOTP secret
    ${optionalString (cfg.totpSecret != null || cfg.totpSecretFile != null) ''
      ${if cfg.totpSecretFile != null then ''
        TOTP_SECRET=$(cat "${cfg.totpSecretFile}")
      '' else ''
        TOTP_SECRET="${cfg.totpSecret}"
      ''}
      ${pkgs.gnused}/bin/sed -i "s|__TOTP_SECRET__|$TOTP_SECRET|g" "$RUNTIME_CONFIG"
    ''}

    # Handle cert password
    ${optionalString (cfg.certPassword != null || cfg.certPasswordFile != null) ''
      ${if cfg.certPasswordFile != null then ''
        CERT_PASSWORD=$(cat "${cfg.certPasswordFile}")
      '' else ''
        CERT_PASSWORD="${cfg.certPassword}"
      ''}
      ${pkgs.gnused}/bin/sed -i "s|__CERT_PASSWORD__|$CERT_PASSWORD|g" "$RUNTIME_CONFIG"
    ''}

    # Handle SOCKS password
    ${optionalString (cfg.socksPassword != null || cfg.socksPasswordFile != null) ''
      ${if cfg.socksPasswordFile != null then ''
        SOCKS_PASSWORD=$(cat "${cfg.socksPasswordFile}")
      '' else ''
        SOCKS_PASSWORD="${cfg.socksPassword}"
      ''}
      ${pkgs.gnused}/bin/sed -i "s|__SOCKS_PASSWORD__|$SOCKS_PASSWORD|g" "$RUNTIME_CONFIG"
    ''}

    # Handle CAS ticket
    ${optionalString (cfg.casTicket != null || cfg.casTicketFile != null) ''
      ${if cfg.casTicketFile != null then ''
        CAS_TICKET=$(cat "${cfg.casTicketFile}")
      '' else ''
        CAS_TICKET="${cfg.casTicket}"
      ''}
      ${pkgs.gnused}/bin/sed -i "s|__CAS_TICKET__|$CAS_TICKET|g" "$RUNTIME_CONFIG"
    ''}

    # Run zju-connect with the runtime config
    exec ${cfg.package}/bin/zju-connect -config "$RUNTIME_CONFIG" "$@"
  '';

in
{
  options.programs.zju-connect = {
    enable = mkEnableOption "ZJU Connect SSL VPN client";

    package = mkOption {
      type = types.package;
      default = pkgs.zju-connect;
      defaultText = literalExpression "pkgs.zju-connect";
      description = "The zju-connect package to use.";
    };

    # Basic authentication settings
    username = mkOption {
      type = types.str;
      description = "VPN username (e.g., student ID)";
      example = "U202312319";
    };

    password = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "VPN password (consider using passwordFile instead for better security)";
    };

    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing VPN password (recommended for better security, compatible with agenix)";
      example = "config.age.secrets.zju-vpn-password.path";
    };

    totpSecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "TOTP secret for automatic two-factor authentication (consider using totpSecretFile instead)";
    };

    totpSecretFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing TOTP secret (more secure than totpSecret option, compatible with agenix)";
    };

    certFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to p12 certificate file for certificate authentication";
    };

    certPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Password for the certificate file (consider using certPasswordFile instead)";
    };

    certPasswordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing certificate password (more secure than certPassword option, compatible with agenix)";
    };

    # Protocol settings
    protocol = mkOption {
      type = types.enum [ "easyconnect" "atrust" ];
      default = "easyconnect";
      description = "VPN protocol to use (easyconnect for HUST, atrust for some other schools)";
    };

    # Server settings
    serverAddress = mkOption {
      type = types.str;
      default = "vpn.hust.edu.cn";
      description = "SSL VPN server address";
      example = "rvpn.zju.edu.cn";
    };

    serverPort = mkOption {
      type = types.port;
      default = 443;
      description = "SSL VPN server port";
    };

    # Advanced settings
    disableServerConfig = mkOption {
      type = types.bool;
      default = false;
      description = "Disable server configuration";
    };

    skipDomainResource = mkOption {
      type = types.bool;
      default = true;
      description = "Skip domain resource routing from server (recommended for non-ZJU users)";
    };

    disableZjuConfig = mkOption {
      type = types.bool;
      default = true;
      description = "Disable ZJU specific configuration (recommended for non-ZJU users)";
    };

    disableZjuDns = mkOption {
      type = types.bool;
      default = false;
      description = "Disable ZJU DNS, use local DNS instead";
    };

    disableMultiLine = mkOption {
      type = types.bool;
      default = false;
      description = "Disable automatic route selection based on latency";
    };

    proxyAll = mkOption {
      type = types.bool;
      default = false;
      description = "Proxy all traffic";
    };

    # Proxy settings
    socksBind = mkOption {
      type = types.str;
      default = ":1080";
      description = "SOCKS5 proxy bind address";
    };

    socksUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "SOCKS5 proxy username";
    };

    socksPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "SOCKS5 proxy password (consider using socksPasswordFile instead)";
    };

    socksPasswordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing SOCKS5 proxy password (more secure than socksPassword option, compatible with agenix)";
    };

    httpBind = mkOption {
      type = types.str;
      default = ":1081";
      description = "HTTP proxy bind address (empty string to disable)";
    };

    shadowsocksUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Shadowsocks server URL";
      example = "ss://aes-128-gcm:password@server:port";
    };

    dialDirectProxy = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Proxy to use for direct connections";
      example = "http://127.0.0.1:7890";
    };

    # TUN mode settings
    tunMode = mkOption {
      type = types.bool;
      default = false;
      description = "Enable TUN mode (experimental, requires root)";
    };

    addRoute = mkOption {
      type = types.bool;
      default = false;
      description = "Add routes based on server configuration when TUN mode is enabled";
    };

    # DNS settings
    dnsTtl = mkOption {
      type = types.int;
      default = 3600;
      description = "DNS cache TTL in seconds";
    };

    zjuDnsServer = mkOption {
      type = types.str;
      default = "auto";
      description = "DNS server address (set to 'auto' to use server-provided DNS)";
    };

    secondaryDnsServer = mkOption {
      type = types.str;
      default = "114.114.114.114";
      description = "Secondary DNS server when ZJU DNS cannot resolve";
    };

    dnsServerBind = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "DNS server bind address";
      example = "127.0.0.1:53";
    };

    dnsHijack = mkOption {
      type = types.bool;
      default = false;
      description = "Hijack DNS requests in TUN mode";
    };

    # Other settings
    disableKeepAlive = mkOption {
      type = types.bool;
      default = false;
      description = "Disable periodic keep-alive";
    };

    debugDump = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debug logging";
    };

    # aTrust specific settings (only used when protocol = "atrust")
    authType = mkOption {
      type = types.str;
      default = "auth/psw";
      description = "aTrust authentication type (auth/psw for password auth, auth/cas for CAS unified authentication)";
    };

    loginDomain = mkOption {
      type = types.str;
      default = "Radius";
      description = "aTrust login domain";
    };

    graphCodeFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to save graph check code image for aTrust";
    };

    casTicket = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "aTrust CAS ticket (for bypassing interactive login, consider using casTicketFile instead)";
    };

    casTicketFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing aTrust CAS ticket (more secure than casTicket option, compatible with agenix)";
    };

    clientDataFile = mkOption {
      type = types.nullOr types.str;
      default = "/var/lib/zju-connect/client-data.json";
      description = "Path to save authentication data (cookies, device ID) for persistent login. Set to null to disable persistence.";
    };

    resourceFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to save/load resource data from server";
    };

    # Port forwarding
    portForwarding = mkOption {
      type = types.listOf (types.submodule {
        options = {
          networkType = mkOption {
            type = types.enum [ "tcp" "udp" ];
            description = "Network protocol type";
          };
          bindAddress = mkOption {
            type = types.str;
            description = "Local bind address";
            example = "127.0.0.1:9898";
          };
          remoteAddress = mkOption {
            type = types.str;
            description = "Remote address";
            example = "10.10.98.98:80";
          };
        };
      });
      default = [ ];
      description = "Port forwarding rules";
    };

    # Custom DNS
    customDns = mkOption {
      type = types.listOf (types.submodule {
        options = {
          hostname = mkOption {
            type = types.str;
            description = "Hostname";
            example = "www.cc98.org";
          };
          ip = mkOption {
            type = types.str;
            description = "IP address";
            example = "10.10.98.98";
          };
        };
      });
      default = [ ];
      description = "Custom DNS resolution rules";
    };

    # Custom proxy domains
    customProxyDomain = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Custom domains to proxy through RVPN";
      example = [ "nature.com" "science.org" ];
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.username != "";
        message = "programs.zju-connect.username must be set";
      }
      {
        assertion = cfg.password != null || cfg.passwordFile != null;
        message = "Either programs.zju-connect.password or programs.zju-connect.passwordFile must be set";
      }
      {
        assertion = !(cfg.password != null && cfg.passwordFile != null);
        message = "Cannot set both password and passwordFile, choose one";
      }
      {
        assertion = !(cfg.totpSecret != null && cfg.totpSecretFile != null);
        message = "Cannot set both totpSecret and totpSecretFile, choose one";
      }
      {
        assertion = !(cfg.certPassword != null && cfg.certPasswordFile != null);
        message = "Cannot set both certPassword and certPasswordFile, choose one";
      }
      {
        assertion = !(cfg.socksPassword != null && cfg.socksPasswordFile != null);
        message = "Cannot set both socksPassword and socksPasswordFile, choose one";
      }
      {
        assertion = !(cfg.casTicket != null && cfg.casTicketFile != null);
        message = "Cannot set both casTicket and casTicketFile, choose one";
      }
    ];

    # Add zju-connect wrapper to system packages
    environment.systemPackages = [ zjuConnectWrapper ];

    # Create directory for client data file
    systemd.tmpfiles.rules = mkIf (cfg.clientDataFile != null) [
      "d /var/lib/zju-connect 0755 root root -"
    ];

    # Enable forwarding if TUN mode is enabled
    boot.kernel.sysctl = mkIf cfg.tunMode {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };
}
