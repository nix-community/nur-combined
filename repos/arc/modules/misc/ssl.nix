{ lib, config, options, pkgs, name, ... }: with lib; {
  options = {
    enable = mkEnableOption "ssl" // { default = options.keyPath.isDefined; };
    keyPath = mkOption {
      type = types.path;
    };
    pem = mkOption {
      type = types.str;
    };
    certPath = mkOption {
      type = types.path;
      default = pkgs.writeText "${config.fqdn}.pem" config.pem;
    };
    fqdn = mkOption {
      type = types.str;
      default = name;
    };
    fqdnAliases = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };
}
