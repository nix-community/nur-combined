{ config, lib, pkgs, sane-lib, ... }:
let
  cfg = config.sane.programs;
  # create an AttrSet[String -> String]
  # which maps symlink path -> symlink content
  # for every symlink known to nix
  fsSymlinksAsAttrs = lib.concatMapAttrs
    (path: value: lib.optionalAttrs
      ((value.symlink or null) != null)
      {
        "${path}" = value.symlink.target;
      }
    )
    config.sane.fs
  ;
in
{
  sane.programs.sanebox = {
    packageUnwrapped = (pkgs.sanebox.override {
      bubblewrap = cfg.bubblewrap.package;
      iproute2 = cfg.iproute2.package;
      iptables = cfg.iptables.package;
      libcap = cfg.libcap.package;
      passt = cfg.passt.package;
      landlock-sandboxer = pkgs.landlock-sandboxer.override {
        # not strictly necessary (landlock ABI is versioned), however when sandboxer version != kernel version,
        # the sandboxer may nag about one or the other wanting to be updated.
        linux = config.boot.kernelPackages.kernel;
      };
    }).overrideAttrs (base: {
      # create a directory which holds just the `sanebox` so that we
      # can add sanebox as a dependency to binaries via `PATH=/run/current-system/libexec/sanebox` without forcing rebuild every time sanebox changes
      postInstall = ''
        mkdir -p $out/libexec/sanebox
        ln -s $out/bin/sanebox $out/libexec/sanebox/sanebox
      '';
    });

    sandbox.enable = false;
  };

  environment.pathsToLink = lib.mkIf cfg.sanebox.enabled [ "/libexec/sanebox" ];

  environment.etc = lib.mkIf cfg.sanebox.enabled {
    "sanebox/symlink-cache".text = lib.concatStringsSep "\n" (
      lib.mapAttrsToList
        (k: v: "${k}\t${v}")
        ({
          "/bin/sh" = config.environment.binsh;
          "${builtins.unsafeDiscardStringContext config.environment.binsh}" = "bash";
          "/usr/bin/env" = config.environment.usrbinenv;
          "${builtins.unsafeDiscardStringContext config.environment.usrbinenv}" = "coreutils";

          # "/run/current-system" = "${config.system.build.toplevel}";
          # XXX: /run/current-system symlink can't be cached without forcing regular mass rebuilds:
          # mount it as if it were a directory instead.
          "/run/current-system" = "";
        } // lib.optionalAttrs config.hardware.graphics.enable {
          "/run/opengl-driver" = let
            gl = config.hardware.graphics;
            # from: <repo:nixos/nixpkgs:nixos/modules/hardware/graphics.nix>
            package = pkgs.buildEnv {
              name = "opengl-drivers";
              paths = [ gl.package ] ++ gl.extraPackages;
            };
          in "${package}";
        } // lib.optionalAttrs (config.hardware.graphics.enable && config.hardware.graphics.enable32Bit) {
          "/run/opengl-driver-32" = let
            gl = config.hardware.graphics;
            # from: <repo:nixos/nixpkgs:nixos/modules/hardware/graphics.nix>
            package = pkgs.buildEnv {
              name = "opengl-drivers-32bit";
              paths = [ gl.package32 ] ++ gl.extraPackages32;
            };
          in "${package}";
        } // fsSymlinksAsAttrs)
    );
  };
}
