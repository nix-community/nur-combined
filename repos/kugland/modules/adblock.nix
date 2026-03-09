{ pkgs
, lib
, config
, ...
}:
let
  inherit (builtins) any concatLists filter head map match readFile;
  inherit (lib) concatStringsSep hasPrefix hasSuffix removePrefix sort splitString;

  cfg = config.networking.adblock;
  recipes = map (list: "${cfg.blocklistPackage.${list}}/hosts") cfg.recipe;
  recipeLines = concatLists (map (f: splitString "\n" (readFile f)) recipes);
  shouldBlock = a: !(any (b: a == b || (hasSuffix ".${b}" a)) cfg.allowedHosts);
  stripComments = s: head (match "^([^# ]*)( *#.*)?$" s);
  blocked =
    sort
      (a: b: a <= b)
      (filter (a: a != "0.0.0.0" && (shouldBlock a))
        (map (a: stripComments (removePrefix "0.0.0.0 " a))
          (filter (hasPrefix "0.0.0.0 ")
            recipeLines)));

  extraHosts = concatStringsSep "\n" (map (a: "0.0.0.0 ${a}") blocked);
  unboundCfg = concatStringsSep "\n" (map (a: ''local-zone: "${a}." always_refuse'') blocked);
in
{
  options.networking.adblock = {
    enable = lib.mkEnableOption "Enable hosts ad-blocking";
    recipe = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [
        "ads"
        "fakenews"
        "gambling"
        "porn"
        "social"
      ]);
      default = [ "ads" ];
      example = [ "ads" "gambling" "porn" ];
      description = ''
        The blocklist recipe to use. This will determine which hosts are blocked.
        The blocklists are provided by StevenBlack's hosts project.
      '';
    };
    blocklistPackage = lib.mkPackageOption pkgs "stevenblack-blocklist" {
      default = [ "stevenblack-blocklist" ];
      example = "pkgs.unstable.stevenblack-blocklist";
    };
    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        A list of hosts to allow even if they are in the blocklist. This is useful
        for allowing certain hosts that are commonly blocked but you want to access.

        Note: any subdomain of the allowed hosts will also be allowed.
      '';
      example = [ "myshopify.com" "shopify.com" ];
    };
    extraHosts.enable = (lib.mkEnableOption "Add ad-blocking entries to /etc/hosts") // {
      default = true;
    };
    unbound.enable = (lib.mkEnableOption "Add ad-blocking entries to unbound config") // {
      default = config.services.unbound.enable;
    };
  };
  config = lib.mkIf config.networking.adblock.enable {
    networking.extraHosts = lib.mkIf cfg.extraHosts.enable extraHosts;
    services.unbound.settings.server.include = lib.mkIf cfg.unbound.enable [
      "${pkgs.writeText "unbound-adblock.conf" unboundCfg}"
    ];
  };
}
