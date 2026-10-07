{ pkgs }:

let
  inherit (pkgs) lib;
  isBuildable =
    package:
    !(package.meta.broken or false)
    && (package.meta.hydraPlatforms or package.meta.platforms or [ ]) != [ ]
    && lib.meta.availableOn pkgs.stdenv.hostPlatform package;

  hasGitHubSource =
    package:
    let
      source = package.src or { };
      urls = source.urls or [ ];
      # nix-update uses src.url first, otherwise the first entry in src.urls.
      url =
        if builtins.isAttrs source then
          source.url or (if urls == [ ] then null else builtins.head urls)
        else
          null;
    in
    url != null && builtins.match "https://(github\\.com|api\\.github\\.com)/[^/]+/[^/]+.*" url != null;

  isUpdatable =
    package: isBuildable package && (package.updateScript or null != null || hasGitHubSource package);
in
{
  inherit isBuildable isUpdatable;
}
