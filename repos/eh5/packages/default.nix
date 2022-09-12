rec {
  packages = import ./packages.nix;

  legacyPackages = pkgs: import ./packages.nix { inherit pkgs; filterByPlatform = false; };

  overlays.default = final: prev: legacyPackages prev;

  overlays.v2ray-rules-dat = final: prev:
    let pkgs = legacyPackages prev; in
    {
      v2ray-geoip = pkgs.v2ray-rules-dat-geoip;
      v2ray-domain-list-community = pkgs.v2ray-rules-dat-geosite;
    };
}
