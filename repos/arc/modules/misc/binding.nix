{ lib, name, config, options, ... }: with lib; let
  localaddr = {
    ipv4 = "127.0.0.1";
    ipv6 = "::1";
  };
  wildaddr = {
    ipv4 = "0.0.0.0";
    ipv6 = "::";
  };
  defaultPorts = {
    ssh = 22;
    http = 80;
    https = 443;
    mpd = 6600;
  };
in {
  options = {
    name = mkOption {
      type = types.str;
      default = name;
    };
    protocol = mkOption {
      type = types.str;
      default = "http";
    };
    port = mkOption {
      type = types.port;
    };
    address = mkOption {
      type = with types; either (enum [ "localhost" "*" ]) str;
      default = "localhost";
    };
    ipProtocol = mkOption {
      type = types.enum [ "ipv4" "ipv6" "unix" ];
    };
    transport = mkOption {
      type = types.enum [ "tcp" "udp" ];
      default = "tcp";
    };
    isAddress = mkOption {
      type = types.bool;
      readOnly = true;
    };
    isLocalhost = mkOption {
      type = types.bool;
      readOnly = true;
    };
    isWildcard = mkOption {
      type = types.bool;
      readOnly = true;
    };
    isLocal = mkOption {
      type = types.bool;
      readOnly = true;
    };
    isExternal = mkOption {
      type = types.bool;
      readOnly = true;
    };
    explicitPort = mkOption {
      type = types.bool;
      readOnly = true;
    };
    out = {
      address = mkOption {
        type = types.str;
        readOnly = true;
      };
    };
    firewall = {
      open = mkOption {
        type = types.bool;
        default = config.isExternal;
      };
      interfaces = mkOption {
        type = with types; nullOr (listOf str);
        default = null; # TODO: find interface with address?
      };
    };
  };
  config = let
    isUnix = config.ipProtocol == "unix";
    isIpv4 = builtins.match ''[0-9]+\.[0-9.]*'' config.address != null;
    isIpv6 = hasInfix ":" config.address;
    ip = if hasPrefix "/" config.address then "unix"
      else if isIpv6 then "ipv6"
      else "ipv4";
    port = defaultPorts.${config.protocol} or (throw "Unknown port for protocol ${config.protocol}");
    isLocalhost = {
      ipv4 = hasPrefix "127." config.address;
      ipv6 = config.address == "::1";
      unix = true;
    };
  in {
    protocol = mkIf isUnix "unix";
    ipProtocol = mkOptionDefault ip;
    port = mkOptionDefault port;
    explicitPort = !isUnix && config.port != defaultPorts.${config.protocol} or null;
    isAddress = isIpv4 || isIpv6 || isUnix;
    isLocalhost = config.address == "localhost" || isLocalhost.${config.ipProtocol} or false;
    isWildcard = config.address == "*";
    isLocal = config.isLocalhost || config.isWildcard;
    isExternal = config.isWildcard || !config.isLocalhost;
    out = {
      address = if config.address == "*" then wildaddr.${config.ipProtocol}
        else if config.address == "localhost" then localaddr.${config.ipProtocol}
        else config.address;
    };
  };
}
