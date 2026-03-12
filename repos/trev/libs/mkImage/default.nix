{ pkgs }:
pkg:
{ ... }@args:

(pkgs.dockerTools.buildLayeredImage (
  args
  // {
    name = args.name or pkg.pname;
    tag = args.tag or pkg.version;
    architecture = args.architecture or pkg.stdenv.hostPlatform.go.GOARCH;
    meta = args.meta or { };

    config = (args.config or { }) // {
      Cmd = [ "${args.config.Cmd or (if pkg != null then (pkgs.lib.meta.getExe pkg) else null)}" ];
      Labels =
        (args.config.Labels or { })
        // pkgs.lib.filterAttrs (_: v: v != null) {
          "org.opencontainers.image.title" = pkg.pname or null;
          "org.opencontainers.image.description" = pkg.meta.description or null;
          "org.opencontainers.image.version" = pkg.version or null;
          "org.opencontainers.image.source" = pkg.meta.homepage or null;
          "org.opencontainers.image.licenses" = pkg.meta.license.spdxId or null;
        };
    };
  }
)).overrideAttrs
  (
    _: prev: {
      passthru = (prev.passthru or { }) // {
        inherit pkg;
      };
    }
  )
