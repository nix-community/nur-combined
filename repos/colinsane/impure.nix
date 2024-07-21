# this entry-point exposes all packages, hosts, etc, but with no purity guarnatees.
# the intended way to use this is to first copy every .nix file and dependency in this repo to the nix store, then enter this file.
# entering this file *before* copying anything into the nix store can cause interesting
# race conditions or eval failures.
#
# see default.nix for a wrapper around this with better purity guarantees.
{ }:
let
  mkPkgs = args: (import ./pkgs/additional/nixpkgs args).extend
    (import ./overlays/all.nix);
  inherit (mkPkgs {}) lib;

  evalHost = { name, system, branch ? "master", variant ? null }:
  let
    pkgs = mkPkgs { inherit system; variant = branch; };
  in pkgs.nixos (
    [
      (import ./hosts/instantiate.nix { hostName = name; inherit variant; })
      (import ./modules)
      pkgs.sops-nix.nixosModules.sops
    ]
  );
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
      programs = lib.mapAttrs (_: p: p.package) host.config.sane.programs;
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
    "${args.name}-min-staging" = mkFlavoredHost (args // { variant = "min"; branch = "staging-staging"; });
  };

  hosts = lib.foldl' (acc: host: acc // mkHost host) {} [
    { name = "crappy"; system = "armv7l-linux";  }
    { name = "desko";  system = "x86_64-linux";  }
    { name = "lappy";  system = "x86_64-linux";  }
    { name = "moby";   system = "aarch64-linux"; }
    { name = "rescue"; system = "x86_64-linux";  }
    { name = "servo";  system = "x86_64-linux";  }
  ];

  pkgs = mkPkgs {};

  subAttrs = attrs: lib.filterAttrs (name: value: builtins.isAttrs value) attrs;
  subAttrNames = attrs: builtins.attrNames (subAttrs attrs);

  # given the path to a package, and that package, returns a list of all attr-paths (stringified)
  # which should be updated as part of that package (including the package in question).
  mkUpdateList = prefix: pkg: (lib.optionals (pkg ? updateScript) [ prefix ]) ++
    lib.foldl'
      (acc: nestedName: acc ++ mkUpdateListIfAuto "${prefix}.${nestedName}" pkg."${nestedName}")
      []
      (lib.optionals (pkg.recurseForDerivations or false) (subAttrNames pkg))
  ;
  # a package can set `passthru.updateWithSuper = false;` if it doesn't want to be auto-updated.
  mkUpdateListIfAuto = prefix: pkg: lib.optionals (pkg.updateWithSuper or true) (mkUpdateList prefix pkg);

  mkUpdateInfo = prefix: pkg: {
    "${prefix}" = rec {
      subPackages = mkUpdateList prefix pkg;
      updateArgv = lib.optionals (pkg ? updateScript) (
        if builtins.isList pkg.updateScript then pkg.updateScript
        else if pkg.updateScript ? command then lib.map builtins.toString pkg.updateScript.command
        else []
      );
      updateScript = let
        pname = pkg.pname or (pkg.name or "unknown");
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
      in lib.optionalString (updateArgv != []) (lib.getExe script);
    };
  } // lib.foldl'
    (acc: subPkgName: acc // mkUpdateInfo "${prefix}.${subPkgName}" pkg."${subPkgName}")
    {}
    (if pkg.recurseForDerivations or false then subAttrNames pkg else [])
  ;

  updateInfo = mkUpdateInfo "sane" pkgs.sane;
in {
  inherit hosts;
  inherit updateInfo;
  updateTargets = builtins.mapAttrs (_: v: v.subPackages) (lib.filterAttrs (_: v: v.subPackages != []) updateInfo);
  updateScripts = builtins.mapAttrs (_: v: v.updateScript) (lib.filterAttrs (_: v: v.updateScript != "") updateInfo);
} // pkgs
