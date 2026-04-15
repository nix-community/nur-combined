{
  stdenv,
  dockerTools,
  lib,
}:

{
  src ? null,
  ...
}@args:

assert src != null;

let
  package =
    if
      (stdenv.hostPlatform.isStatic || (stdenv.hostPlatform.system != stdenv.buildPlatform.system))
    then
      (src.${stdenv.hostPlatform.system} or src)
    else
      src;

  platforms = [
    "x86_64-linux"
    "x86_64-linux-musl"
    "aarch64-linux"
    "aarch64-linux-musl"
    "armv7l-linux"
    "armv7l-linux-musl"
    "armv6l-linux"
    "armv6l-linux-musl"
  ];
in

dockerTools.buildLayeredImage (
  (removeAttrs args [ "src" ])
  // {
    name = args.name or package.pname;
    tag = args.tag or package.version;
    architecture = args.architecture or package.stdenv.hostPlatform.go.GOARCH;
    meta = (args.meta or package.meta or { }) // {
      crossPlatforms = builtins.filter (platform: builtins.elem platform platforms) (
        package.meta.crossPlatforms or package.meta.platforms or platforms
      );
    };

    config = (args.config or { }) // {
      Entrypoint = [ "${args.config.Entrypoint or (lib.meta.getExe package)}" ];
      Labels =
        (args.config.Labels or { })
        // lib.filterAttrs (_: v: v != null) {
          "org.opencontainers.image.title" = package.pname or package.name or null;
          "org.opencontainers.image.description" =
            package.meta.longDescription or package.meta.description or null;
          "org.opencontainers.image.version" = package.version or null;
          "org.opencontainers.image.url" = package.meta.homepage or null;
          "org.opencontainers.image.source" = package.meta.downloadPage or package.meta.homepage or null;
          "org.opencontainers.image.licenses" = package.meta.license.spdxId or null;
        };
    };
  }
)
