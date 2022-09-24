{ lib, config, options, ... }: with lib; let
  localaddr = {
    ipv4 = "127.0.0.1";
    ipv6 = "::1";
  };
  wildaddr = {
    ipv4 = "0.0.0.0";
    ipv6 = "::";
  };
in {
  options = {
    url = mkOption {
      type = types.str;
    };
    host = mkOption {
      type = types.str;
    };
    address = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    extraUrlArgs = mkOption {
      type = types.attrsOf types.unspecified;
      default = { };
    };
    isLocal = mkOption {
      type = types.bool;
      default = config.binding.isLocalhost;
    };
    binding = mkOption {
      type = types.unspecified;
    };
  };
  config = let
    url = genUrl ({
      inherit (config) host;
      inherit (config.binding) protocol port explicitPort;
      isUrl = config.binding.ipProtocol != "unix";
    } // config.extraUrlArgs);
    host =
      if config.address != null then config.address
      else if config.binding.isLocal && (config.binding.isWildcard || !config.binding.isAddress)
        then localaddr.${config.binding.ipProtocol}
      else if config.binding.isAddress then config.binding.address
      else throw "unknown address for binding ${config.binding.name}";
  in {
    url = mkOptionDefault (if config.binding.ipProtocol == "unix" then config.address else url);
    host = mkOptionDefault host;
  };
}
