# this entry-point exposes all packages, hosts, etc, but with no purity guarnatees.
# the intended way to use this is to first copy every .nix file and dependency in this repo to the nix store, then enter this file.
# entering this file *before* copying anything into the nix store can cause interesting
# race conditions or eval failures.
#
# see default.nix for a wrapper around this with better purity guarantees.
{
  localSystem ? builtins.currentSystem,
}:
let
  mkPkgs = branch: args: (
    (import ./pkgs/by-name/nixpkgs-bootstrap/${branch}.nix {}).override args
  ).extend (import ./overlays/all.nix);
  pkgs = mkPkgs "master" {};
  inherit (pkgs) lib;

  evalHost = { name, localSystem, system, branch ? "master", variant ? null }:
  let
    pkgs = mkPkgs branch { inherit localSystem system; };
  in pkgs.nixos [
    (import ./hosts/instantiate.nix { hostName = name; inherit variant; })
    (import ./modules)
    pkgs.sops-nix.nixosModules.sops
  ];
  mkFlavoredHost = args: let
    host = evalHost args;
    # expose the toplevel nixos system as the toplevel attribute itself,
    # with nested aliases for other common build targets
  in host.config.system.build.toplevel.overrideAttrs (base: {
    passthru = (base.passthru or {}) // {
      config = host.config;
      fs = host.config.sane.fs;
      img = host.config.system.build.img;
      pkgs = host.config.system.build.pkgs;
      programs = builtins.mapAttrs (_: p: p.package) host.config.sane.programs;
      toplevel = host.config.system.build.toplevel;  #< self
    };
  });
  mkHost = args: {
    # TODO: swap order: $host-{next,staging}-{min,light}:
    # then lexicographically-adjacent targets would also have the minimal difference in closure,
    # and the order in which each target should be built is more evident
    "${args.name}" = mkFlavoredHost args;
    "${args.name}-next" = mkFlavoredHost (args // { branch = "staging-next"; });
    "${args.name}-staging" = mkFlavoredHost (args // { branch = "staging"; });
    "${args.name}-light" = mkFlavoredHost (args // { variant = "light"; });
    "${args.name}-light-next" = mkFlavoredHost (args // { variant = "light"; branch = "staging-next"; });
    "${args.name}-light-staging" = mkFlavoredHost (args // { variant = "light"; branch = "staging"; });
    "${args.name}-min" = mkFlavoredHost (args // { variant = "min"; });
    "${args.name}-min-next" = mkFlavoredHost (args // { variant = "min"; branch = "staging-next"; });
    "${args.name}-min-staging" = mkFlavoredHost (args // { variant = "min"; branch = "staging"; });
  };

  # this exists to unify my kernel configs across different platforms.
  # ordinarily, certain kernel config options are derived by nixpkgs using the `system` parameter,
  # via <repo:nixos/nixpkgs:lib/systems/platforms.nix>.
  # but i want these a little more normalized, which is possible either here, or
  # by assigning `boot.kernelPackages`.
  # elaborate = system: system;
  elaborate = system: let
    e = lib.systems.elaborate system;
  in
    {
      inherit system;
      linux-kernel = {
        inherit (e.linux-kernel) name baseConfig target;
      } // (lib.optionalAttrs (e.linux-kernel ? DTB) { inherit (e.linux-kernel) DTB; }) // {
        # explicitly ignore nixpkgs' extraConfig and preferBuiltin options
        autoModules = true;
        # build all features as modules where possible, especially because
        # 1. some bootloaders fail on large payloads and this allows the kernel/initrd to be smaller.
        # 2. building as module means i can override that module very cheaply as i develop.
        preferBuiltin = false;
        # `target` support matrix:
        # Image:     aarch64:yes (nixpkgs default)       x86_64:no
        # Image.gz:  aarch64:yes, if capable bootloader  x86_64:no
        # zImage     aarch64:no                          x86_64:yes
        # bzImage    aarch64:no                          x86_64:yes (nixpkgs default)
        # vmlinux    aarch64:?                           x86_64:no?
        # vmlinuz    aarch64:?                           x86_64:?
        # uImage     aarch64:bootloader?                 x86_64:probably not
        # # target = if system == "x86_64-linux" then "bzImage" else "Image";
      };
    };

  hosts = builtins.foldl'
    # XXX: i `elaborate` localSystem the same as i do `system` because otherwise nixpkgs
    # sees they're (slightly) different and forces everything down the (expensive) cross-compilation path.
    (acc: host: acc // mkHost ({ localSystem = elaborate localSystem; } // host))
    {}
    [
      # real hosts:
      # { name = "crappy"; system = "armv7l-linux";  }
      { name = "desko";  system = elaborate "x86_64-linux";  }
      { name = "lappy";  system = elaborate "x86_64-linux";  }
      { name = "moby";   system = elaborate "aarch64-linux"; }
      { name = "servo";  system = elaborate "x86_64-linux";  }

      { name = "rescue"; system = elaborate "x86_64-linux";  }
      # pseudo hosts used for debugging
      { name = "baseline-x86_64";  system = elaborate "x86_64-linux";  }
      { name = "baseline-aarch64";  system = elaborate "aarch64-linux";  }
    ];

  # subAttrNames :: AttrSet -> [ String ]
  # returns the names of all items in `attrs` which are themselves attrsets.
  # presumably, this is the list of items which we may wish to descend into.
  subAttrNames = attrs: builtins.attrNames (subAttrs attrs);
  subAttrs = attrs: lib.filterAttrs
    (name: value:
      let
        # many attributes in the `pkgs` set do not evaluate (even `pkgs.sane`, thanks to e.g. linuxPackages).
        # wrap in `tryEval` to deal with that, and not descend into such attributes.
        isAttrs = builtins.tryEval (builtins.isAttrs value);
      in
        isAttrs.success && isAttrs.value
    )
    attrs;

  # update only packages maintained by me:
  # shouldUpdate = pkg: let
  #   maintainers = ((pkg.meta or {}).maintainers or []);
  # in
  #   pkg ? updateScript &&
  #   (lib.elem lib.maintainers.colinsane maintainers || maintainers == [])
  # ;

  # update any package possible, and just rely on good namespacing:
  shouldUpdate = pkg: pkg ? updateScript;

  # given the path to a package, and that package, returns a list of all attr-paths (stringified)
  # which should be updated as part of that package (including the package in question).
  mkUpdateList = prefix: pkg: (lib.optionals (shouldUpdate pkg) [ prefix ]) ++
    lib.concatMap
      (nestedName: mkUpdateListIfAuto "${prefix}.${nestedName}" pkg."${nestedName}")
      (lib.optionals (pkg.recurseForDerivations or false) (subAttrNames pkg))
  ;
  # a package can set `passthru.updateWithSuper = false;` if it doesn't want to be auto-updated.
  mkUpdateListIfAuto = prefix: pkg: lib.optionals (pkg.updateWithSuper or true) (mkUpdateList prefix pkg);

  mkUpdateInfo = prefix: pkg: let
    # the actual shell command which can update the package, after an environment has been configured for the updater:
    updateArgv = lib.optionals (pkg ? updateScript) (
      if builtins.isList pkg.updateScript then pkg.updateScript
      else if pkg.updateScript ? command then builtins.map builtins.toString pkg.updateScript.command
      else if (pkg.updateScript.meta or {}) ? mainProgram then
        # raw derivation like `writeShellScriptBin`
        [ "${lib.getExe pkg.updateScript}" ]
      else
        []
    );
  in {
    "${prefix}" = {
      subPackages = mkUpdateList prefix pkg;
      updateScript = let
        pname = lib.escapeURL (pkg.pname or (pkg.name or "unknown"));
        script = pkgs.writeShellScriptBin "update-${pname}" ''
          # update script assumes $PWD is an entry point to a writable copy of my nix config,
          # so provide that:
          pushd /home/colin/nixos/integrations/nix-update
          UPDATE_NIX_NAME=${pkg.name or ""} \
          UPDATE_NIX_PNAME=${pkg.pname or ""} \
          UPDATE_NIX_OLD_VERSION=${pkg.version or ""} \
          UPDATE_NIX_ATTR_PATH=${prefix} \
          ${lib.escapeShellArgs updateArgv}
          popd
        '';
      in lib.optionalString (shouldUpdate pkg && updateArgv != []) (lib.getExe script);
    };
  } // builtins.foldl'
    (acc: subPkgName: acc // mkUpdateInfo "${prefix}.${subPkgName}" pkg."${subPkgName}")
    {}
    (if pkg.recurseForDerivations or false then subAttrNames pkg else [])
  ;

  updateInfo = mkUpdateInfo "sane" pkgs.sane;
in {
  inherit hosts;
  inherit updateInfo;
  # AttrSet mapping attrpath to a list of attrpaths representing all updatable packages beneath it
  updateTargets = builtins.mapAttrs (_: v: v.subPackages) (lib.filterAttrs (_: v: v.subPackages != []) updateInfo);
  # AttrSet mapping attrpath to the path of a shell script which can be used to update the package at that attrpath
  updateScripts = builtins.mapAttrs (_: v: v.updateScript) (lib.filterAttrs (_: v: v.updateScript != "") updateInfo);
} // pkgs
