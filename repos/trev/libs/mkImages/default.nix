{ }:
pkgs: imagesFunc:
let
  base-pkgs = imagesFunc pkgs;

  aarch64-linux-pkgs = imagesFunc pkgs.pkgsCross.aarch64-multiplatform;
  x86_64-linux-pkgs = imagesFunc pkgs.pkgsCross.musl64;
  armv7l-linux-pkgs = imagesFunc pkgs.pkgsCross.armv7l-hf-multiplatform;
  armv6l-linux-pkgs = imagesFunc pkgs.pkgsCross.raspberryPi;

  setupImage =
    image: arch:
    image.override (
      _: prev:
      let
        pkg = builtins.elemAt prev.contents 0;
      in
      {
        contents = (prev.contents or [ ]) ++ [
          pkgs.dockerTools.caCertificates
        ];

        architecture = prev.architecture or arch;

        config = (prev.config or { }) // {
          Cmd = [ "${prev.config.Cmd or (if pkg != null then (pkgs.lib.meta.getExe pkg) else null)}" ];
          Labels =
            (prev.config.Labels or { })
            // pkgs.lib.filterAttrs (_: v: v != null) {
              "org.opencontainers.image.title" = pkg.pname or null;
              "org.opencontainers.image.description" = pkg.meta.description or null;
              "org.opencontainers.image.version" = pkg.version or null;
              "org.opencontainers.image.source" = pkg.meta.homepage or null;
              "org.opencontainers.image.licenses" = pkg.meta.license.spdxId or null;
            };
        };
      }
    );
in
builtins.mapAttrs (
  name: image:
  (setupImage image pkgs.go.GOARCH).override (
    _: prev: {
      passthru = (prev.passthru or { }) // {
        x86_64-linux = x86_64-linux-pkgs.${name} "amd64";
        aarch64-linux = setupImage aarch64-linux-pkgs.${name} "arm64";
        armv7l-linux = armv7l-linux-pkgs.${name} "arm";
        armv6l-linux = armv6l-linux-pkgs.${name} "arm";
      };
    }
  )
) base-pkgs
