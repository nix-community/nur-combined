{
  lib,
  ...
}:
with lib;
{
  imports = [
    ./duckdns
    ./cloudflare
    ./freedns
    ./desec
  ];

  options.ddns = {
    duckdns = {
      enable = mkEnableOption "DuckDNS Dynamic DNS Client";
      tokenFile = mkOption {
        default = null;
        type = types.path;
        description = ''
          The path to a file containing the token
          used to authenticate with DuckDNS.
        '';
      };

      domains = mkOption {
        default = null;
        type = types.nullOr (types.listOf types.str);
        example = [ "examplehost" ];
        description = ''
          The domain(s) to update in DuckDNS
          (without the .duckdns.org suffix)
        '';
      };

      domainsFile = mkOption {
        default = null;
        type = types.nullOr types.path;
        example = literalExpression ''
          pkgs.writeText "duckdns-domains.txt" '''
            examplehost
            examplehost2
            examplehost3
          '''
        '';
        description = ''
          The path to a file containing a
          newline-separated list of DuckDNS
          domain(s) to be updated
          (without the .duckdns.org suffix)
        '';
      };
    };

    cloudflare = {
      enable = mkEnableOption "Cloudflare Dynamic DNS Client";
      apiTokenFile = mkOption {
        default = null;
        type = types.path;
        description = ''
          The path to a file containing the API token
          used to authenticate with Cloudflare.
        '';
      };

      zoneId = mkOption {
        default = null;
        type = types.str;
        description = ''
          The Zone ID of the domain in Cloudflare.
        '';
      };

      recordName = mkOption {
        default = null;
        type = types.str;
        description = ''
          The full record name to update in Cloudflare (e.g., subdomain.example.com).
        '';
      };
    };

    freedns = {
      enable = mkEnableOption "FreeDNS (afraid.org) Dynamic DNS Client";
      updateUrlFile = mkOption {
        default = null;
        type = types.path;
        description = ''
          The path to a file containing the secret FreeDNS
          update URL for this host, as shown on the
          "Dynamic DNS" page of the FreeDNS member area
          (e.g. https://freedns.afraid.org/dynamic/update.php?&#60;hash&#62;).
        '';
      };
    };

    desec = {
      enable = mkEnableOption "deSEC Dynamic DNS Client";
      domain = mkOption {
        type = types.str;
        example = "example.dedyn.io";
        description = ''
          The dedyn.io domain (or subdomain) to update in deSEC.
        '';
      };

      tokenFile = mkOption {
        default = null;
        type = types.path;
        description = ''
          The path to a file containing the deSEC dynDNS
          token used to authenticate the update.
        '';
      };
    };
  };
}
