{ }:
pkgs: imagesFunc:
let
  base-pkgs = imagesFunc pkgs;

  # Images are always built for linux, so we only need to consider the architecture.
  aarch64-pkgs = imagesFunc pkgs.pkgsCross.aarch64-multiplatform;
  x86_64-pkgs = imagesFunc pkgs.pkgsCross.musl64;
  armv7l-pkgs = imagesFunc pkgs.pkgsCross.armv7l-hf-multiplatform;
  armv6l-pkgs = imagesFunc pkgs.pkgsCross.raspberryPi;

  setupImage =
    image: pkg: arch:
    image.override (prev: {
      contents = (prev.contents or [ ]) ++ [
        pkgs.dockerTools.caCertificates
      ];

      architecture = prev.architecture or arch;

      meta = prev.meta or { };

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
    });
in
builtins.mapAttrs (
  name: image:
  let
    pkg = builtins.elemAt image.contents 0;
  in
  (setupImage image pkg pkgs.go.GOARCH).overrideAttrs (
    _: prev: {
      passthru =
        (prev.passthru or { })
        // pkgs.lib.filterAttrs (_: v: v != null) {
          x86_64-linux =
            if pkg ? x86_64-linux then setupImage x86_64-pkgs.${name} pkg.x86_64-linux "amd64" else null;

          aarch64-linux =
            if pkg ? aarch64-linux then setupImage aarch64-pkgs.${name} pkg.aarch64-linux "arm64" else null;

          armv7l-linux =
            if pkg ? armv7l-linux then setupImage armv7l-pkgs.${name} pkg.armv7l-linux "arm" else null;

          armv6l-linux =
            if pkg ? armv6l-linux then setupImage armv6l-pkgs.${name} pkg.armv6l-linux "arm" else null;
        };
    }
  )
) base-pkgs
