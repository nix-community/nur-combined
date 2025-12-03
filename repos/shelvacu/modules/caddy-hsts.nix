{ lib, ... }:
let
  inherit (lib) types;
in
{
  options.services.caddy.virtualHosts = lib.mkOption {
    type = types.attrsOf (
      types.submodule (
        { config, ... }:
        let
          inherit (config.vacu) hsts;
          headerVal =
            if hsts == false then
              ""
            else
              lib.concatStringsSep "; " (
                [ "max-age=63072000" ]
                ++ lib.optional (hsts == "withSubdomains" || hsts == "preload") "includeSubDomains"
                ++ lib.optional (hsts == "preload") "preload"
              );
        in
        {
          options.vacu.hsts = lib.mkOption {
            type = types.enum [
              false
              true
              "withSubdomains"
              "preload"
            ];
          };
          config.extraConfig =
            if hsts == false then
              "header -Strict-Transport-Security"
            else
              ''header Strict-Transport-Security "${headerVal}"'';
        }
      )
    );
  };
}
