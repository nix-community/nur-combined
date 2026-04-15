{
  stdenv,
  dockerTools,
  lib,
}:

pkg:

{ ... }@args:

let
  package = pkg.${stdenv.hostPlatform.system} or pkg;
  platforms = [
    "x86_64-linux"
    "aarch64-linux"
    "armv7l-linux"
    "armv6l-linux"
  ];
in

(dockerTools.buildLayeredImage (
  args
  // {
    name = args.name or package.pname;
    tag = args.tag or package.version;
    architecture = args.architecture or package.stdenv.hostPlatform.go.GOARCH;
    meta = (args.meta or package.meta or { }) // {
      platforms = builtins.filter (platform: builtins.elem platform platforms) (
        package.meta.platforms or platforms
      );
    };

    config = (args.config or { }) // {
      Cmd = [ "${args.config.Cmd or (lib.meta.getExe package)}" ];
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
)).overrideAttrs
  (
    _: prev: {
      passthru = (prev.passthru or { }) // {
        inherit package;
      };
    }
  )
