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

  hosts = lib.foldl' (acc: host: acc // (mkHost host)) {} [
    { name = "crappy"; system = "armv7l-linux";  }
    { name = "desko";  system = "x86_64-linux";  }
    { name = "lappy";  system = "x86_64-linux";  }
    { name = "moby";   system = "aarch64-linux"; }
    { name = "rescue"; system = "x86_64-linux";  }
    { name = "servo";  system = "x86_64-linux";  }
  ];
in {
  inherit hosts;
} // (mkPkgs {})
