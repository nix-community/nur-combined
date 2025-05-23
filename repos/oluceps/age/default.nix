{
  type ? "default",
}:
{
  config,
  user,
  self,
  lib,
  ...
}:
{
  systemd.services.vaultix-activate.serviceConfig.Environment = [ "RUST_LOG=trace" ];
  vaultix = {
    settings = {  };

    secrets =
      let
        gen =
          ns: owner: group: mode:
          self.lib.genAttrs ns (n: {
            file = self + "/sec/${n}.age";
            inherit owner group mode;
          });
        hard = i: gen i "root" "users" "400";
        userRo = i: gen i user "users" "400";
        rootRo = i: gen i "root" "root" "400";
        sdnet = i: gen i "root" "systemd-network" "0440";
        rrr = i: gen i "root" "root" "444";
        gener = {
          inherit
            hard
            userRo
            rootRo
            sdnet
            rrr
            lib
            ;
        };
      in
      (hard [
        "ss"
        "sing"
        "sing-server"
        "caddy"
      ])
      // (userRo [
        "nyaw.cert"
        "nyaw.key"
        "gh-token"
      ])
      // (sdnet [ "psk" ])
      // (rrr [ "ntfy-token" ])
      // (if type != "default" then (import ./${type}.nix gener) else { });
  };
}
