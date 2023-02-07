{ lib, pkgs, config, ... }:
# This option intends to make local domain refrences possible and
# consistent between nixOS and macOS; currently darwin does not 
# expose a local domain or domain equivilent option meaning 
# settings dependent on this knowledge are broken.
with lib;
let
  defaultValue = "lan";
  default = if (builtins.hasAttr "domain" config.networking) then
    (if config.networking.domain != null then
      config.networking.domain
    else
      defaultValue)
  else
    defaultValue;
in {
  options.networking = {
    localDomain = mkOption {
      type = types.str;
      # This is used rather than the networking.domain option to
      # explicitly define local domains rather than general domains.
      # Overriding the original would probably not be wise.
      inherit default;
      description =
        "The domain. It can be left empty if it is auto-detected through DHCP.";
    };
  };
}
