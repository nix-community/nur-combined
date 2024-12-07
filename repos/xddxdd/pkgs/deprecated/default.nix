{
  callPackage,
  loadPackages,
  lib,
  ...
}:
let
  packages = loadPackages ./. { };
  packages' = packages // {
    wechat-uos-without-sandbox = callPackage ./wechat-uos {
      enableSandbox = false;
    };
    # Deprecated alias
    wechat-uos-bin = packages.wechat-uos;
  };
in
lib.mapAttrs (
  _k: v:
  v
  // {
    meta = v.meta // {
      description = "(DEPRECATED: ${builtins.concatStringsSep " " v.meta.knownVulnerabilities}) ${v.meta.description}";
    };
  }
) packages'
