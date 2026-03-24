{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
package:
{ ... }@args:

(pkgs.dockerTools.buildLayeredImage (
  args
  // {
    name = args.name or package.pname;
    tag = args.tag or package.version;
    architecture = args.architecture or package.stdenv.hostPlatform.go.GOARCH;
    meta = args.meta or package.meta or { };

    config = (args.config or { }) // {
      Cmd = [ "${args.config.Cmd or (pkgs.lib.meta.getExe package)}" ];
      Labels =
        (args.config.Labels or { })
        // pkgs.lib.filterAttrs (_: v: v != null) {
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
