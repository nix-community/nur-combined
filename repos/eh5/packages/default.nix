let
  utils = import ../utils;
  specialPackages = pkgs: {
    sources = pkgs.callPackage ./_sources/generated.nix { };
  };
  allPackages = pkgs:
    let
      callPackage = fn: args:
        utils.ifTrueWithOr
          (utils.checkPlatform pkgs.system)
          (pkgs.lib.callPackageWith
            (pkgs // specialPackages pkgs)
            fn
            args
          )
          null;
    in
    (import ./packages.nix { inherit callPackage; });
in
rec {
  packages = pkgs: builtins.foldl'
    (sum: name:
      if builtins.hasAttr name pkgs && pkgs.${name} != null then
        sum // { ${name} = pkgs.${name}; }
      else sum
    )
    { }
    (builtins.attrNames (allPackages pkgs));

  nurPackages = pkgs: (import ./packages.nix {
    callPackage = pkgs.lib.callPackageWith
      (pkgs // specialPackages pkgs // nurPackages pkgs);
  });

  overlays.default = final: prev: allPackages final;

  overlays.v2ray-rules-dat = final: prev:
    let pkgs = allPackages prev; in
    {
      v2ray-geoip = pkgs.v2ray-rules-dat-geoip;
      v2ray-domain-list-community = pkgs.v2ray-rules-dat-geosite;
    };
}
