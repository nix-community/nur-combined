# this entry-point exposes all packages, hosts, etc, but with no purity guarantees.
# the intended way to use this is to first copy every .nix file and dependency in this repo to the nix store, then enter this file.
# entering this file *before* copying anything into the nix store can cause interesting
# race conditions or eval failures.
#
# see default.nix for a wrapper around this with better purity guarantees.
{
  localSystem ? {
    system = builtins.currentSystem;
  },
}:
let
  overlays = import ./overlays/all.nix;
  mkNixpkgs = { branch, localSystem }: let
    mkNixpkgs = import ./pkgs/by-name/nixpkgs-bootstrap/mkNixpkgs.nix { inherit localSystem; };
    nixpkgs = import ./pkgs/by-name/nixpkgs-bootstrap/${branch}.nix { inherit mkNixpkgs; };
  in nixpkgs // {
    lib = import "${nixpkgs}/lib";
    pkgs = import "${nixpkgs}/pkgs/top-level" { inherit localSystem overlays; };
  };
  nixpkgs = mkNixpkgs { branch = "master"; inherit localSystem; };
  inherit (nixpkgs) lib pkgs;

  evalHost = { name, buildPlatform, config ? {}, branch ? "master", variant ? null, libc ? null, buildLibc ? null, cpu ? null }:
  let
    nixpkgs = mkNixpkgs { inherit branch; localSystem = buildPlatform; };
    # ${nixpkgs}/nixos/lib/eval-config.nix is like `pkgs.nixos`, but doesn't set `config.nixpkgs.{pkgs,localSystem}`.
    # that allows me to set `nixpkgs.config.*` (e.g. `strictDepsByDefault`) via the module system,
    # instead of forcing them to be fixed at import-time.
    #
    # ${nixpkgs}/nixos is an abstraction around the above with an evern more minimal interface
  in import "${nixpkgs}/nixos" {
    configuration = {
      imports = [
        ./hosts/by-name/${name}
        nixpkgs.pkgs.sops-nix.nixosModules.sops  #< XXX should be `pkgs` from module arg, not `nixpkgs`.
      ];

      sane.hostVariant = lib.mkIf (variant != null) variant;
      sane.buildLibc = lib.mkIf (buildLibc != null) buildLibc;
      sane.libc = lib.mkIf (libc != null) libc;
      sane.cpu = lib.mkIf (cpu != null) cpu;

      nixpkgs = {
        inherit config overlays;
        # XXX(2026-01-02): this is fragile.
        # we care about `nixpkgs.buildPlatform` and `nixpkgs.hostPlatform`; `nixpkgs.system` is an unused legacy option.
        # however the option merging of `nixpkgs.buildPlatform` is bad enough that when i needed to query `nixpkgs.buildPlatform.system`
        # in my own code, i couldn't w/o infinite recursion.
        # so i'm just setting `nixpkgs.system` to shuttle `nixpkgs.buildPlatform.system` into places it can't otherwise be read.
        system = buildPlatform.system;
      };
    };
    system = null;  # else it defaults to `builtins.currentSystem`
  };

  mkHost = args: let
    expandArch = lib.concatMapAttrs (hostName: args': {
      "${hostName}" = args';
      "${hostName}-aarch64" = lib.recursiveUpdate args' { cpu = "aarch64"; };
      "${hostName}-x86_64" = lib.recursiveUpdate args' { cpu = "x86_64"; };
    });
    expandLibc = lib.concatMapAttrs (hostName: args': {
      "${hostName}" = args';
      "${hostName}-musl" = lib.recursiveUpdate args' { libc = "musl"; };
      "${hostName}-glibc" = lib.recursiveUpdate args' { libc = "glibc"; };
      "${hostName}-musl-from-glibc" = lib.recursiveUpdate args' { libc = "musl"; buildLibc = "glibc"; };
      # "${hostName}-musl-cross" = lib.recursiveUpdate args' { hostPlatform.abi = abis.musl; };
      # "${hostName}-glibc-cross" = lib.recursiveUpdate args' { hostPlatform.abi = abis.gnu; };
    });
    # aspirational targets. these aren't expected to work _yet_, but getting them to build further achieves more broad benefits.
    # ordered by feasibility.
    expandNovelties = lib.concatMapAttrs (hostName: args': {
      "${hostName}" = args';
      "${hostName}-strict" = lib.recursiveUpdate args' { config.strictDepsByDefault = true; };
      # N.B.: `_crossMarker` isn't a well-known/used stdenv attribute. it's set simply to force `hostPlatform != buildPlatform`
      # and hence force a "cross-compile-by-default" workflow.
      # "${hostName}-forcecross" = lib.recursiveUpdate args' { hostPlatform._crossMarker = true; };
      # "${hostName}-static" = lib.recursiveUpdate args' { hostPlatform.isStatic = true; };
    });
    expandBranches = lib.concatMapAttrs (hostName: args': {
      "${hostName}" = args';
      "${hostName}-staging" = args' // { branch = "staging"; };
      "${hostName}-next" = args' // { branch = "staging-next"; };
    });
    expandVariants = lib.concatMapAttrs (hostName: args': {
      "${hostName}" = args';
      "${hostName}-light" = args' // { variant = "light"; };
      "${hostName}-min" = args' // { variant = "min"; };
      "${hostName}-smoke" = args' // { variant = "smoke"; };
    });
    defineOutputs = lib.mapAttrs (_hostName: args': let
      plainHost = evalHost args';
    in {
      inherit (plainHost) config options pkgs;
      inherit (plainHost.system) drvPath name outputName outPath type;  #< support `nix-build -A hosts.FOO`
      inherit (plainHost.config.sane) fs;
      inherit (plainHost.config.system.build) img;
      programs = builtins.mapAttrs (_: p: p.package) plainHost.config.sane.programs;
      toplevel = plainHost.system;
    });
  in 
    lib.pipe {
      "${args.name}" = lib.recursiveUpdate {
        buildPlatform = localSystem;
      } args;
    }
    [
      expandArch
      expandLibc
      expandNovelties
      expandBranches
      expandVariants
      defineOutputs
    ];

  hosts = builtins.foldl'
    (acc: host: acc // mkHost host)
    {}
    [
      # real hosts:
      # { name = "crappy"; }
      { name = "cadey"; }
      { name = "desko"; }
      { name = "flowy"; }
      { name = "lappy"; }
      { name = "moby";  }
      { name = "servo"; }

      { name = "rescue"; cpu = (lib.systems.elaborate localSystem).parsed.cpu.name; }

      # pseudo hosts used for debugging and packaging/nixpkgs development
      { name = "baseline"; cpu = (lib.systems.elaborate localSystem).parsed.cpu.name; }
      # interesting pseudo hosts:
      # - baseline-strict{,-min}
      # - baseline-musl{,-min}
      # - baseline-cross{,-min}
      # - baseline-static{,-min}
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
        isAttrs' = builtins.tryEval (builtins.isAttrs value);
      in
        isAttrs'.success && isAttrs'.value
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

  shouldRecurse = attrs: attrs.recurseForDerivations or false;
  # shouldRecurse = attrs: attrs ? callPackage;
  # shouldRecurse = _attrs: true;

  # given the path to a package, and that package, returns a list of all attr-paths (stringified)
  # which should be updated as part of that package (including the package in question).
  mkUpdateList = prefix: pkg: (lib.optionals (shouldUpdate pkg) [ prefix ]) ++
    lib.concatMap
      (nestedName: mkUpdateListIfAuto "${prefix}.${nestedName}" pkg."${nestedName}")
      (lib.optionals (shouldRecurse pkg) (subAttrNames pkg))
  ;
  # a package can set `passthru.skipBulkUpdate = true;` if it doesn't want to be auto-updated.
  mkUpdateListIfAuto = prefix: pkg: lib.optionals (!(pkg.skipBulkUpdate or false)) (mkUpdateList prefix pkg);

  mkUpdateInfo = prefix: pkg: let
    # the actual shell command which can update the package, after an environment has been configured for the updater:
    updateArgv = pkgs.updater-tools.updateArgvForPkg pkg;
  in {
    "${prefix}" = {
      subPackages = mkUpdateList prefix pkg;
      updateScript = let
        pname = lib.escapeURL (pkg.pname or (pkg.name or "unknown"));
        script = pkgs.writeShellScriptBin "update-${pname}" ''
          # give each update script a unique $PWD and $TMPDIR because:
          # 1. updaters often assume $PWD is an entry point into a _mutable_ copy of the nix config.
          # 2. updaters often write artifacts (e.g. `git-commits.txt`) to the working directory.
          # 3. tmp artifacts can be _large_ for things involving `git clone`, and scripts don't often do cleanup.
          REPO_ROOT=$(${lib.getExe pkgs.git} -C "$PWD" rev-parse --show-toplevel)
          UNIQUE_TO_UPDATER=$REPO_ROOT/.work/update/${prefix}
          rm -rf "$UNIQUE_TO_UPDATER"
          mkdir -p "$UNIQUE_TO_UPDATER"

          echo "working out of: $UNIQUE_TO_UPDATER"

          pushd "$UNIQUE_TO_UPDATER"
          # because nix-update needs to update source attributes, it can't go through the hermetic
          # toplevel `default.nix`, but rather needs the in-place `impure.nix`.
          echo "import $REPO_ROOT/impure.nix" > default.nix

          TMPDIR=$UNIQUE_TO_UPDATER \
          UPDATE_NIX_NAME=${pkg.name or ""} \
          UPDATE_NIX_PNAME=${pkg.pname or ""} \
          UPDATE_NIX_OLD_VERSION=${pkg.version or ""} \
          UPDATE_NIX_ATTR_PATH=${prefix} \
          ${lib.escapeShellArgs updateArgv}  > >(tee update.log)  2> >(tee update.stderr >&2)
          popd
        '';
      in lib.optionalString (shouldUpdate pkg && updateArgv != []) (lib.getExe script);
    };
  } // builtins.foldl'
    (acc: subPkgName: acc // mkUpdateInfo "${prefix}.${subPkgName}" pkg."${subPkgName}")
    {}
    (lib.optionals (shouldRecurse pkg) (subAttrNames pkg))
  ;

  sane = import ./pkgs/packages.nix pkgs;
  updateInfo = mkUpdateInfo "sane" sane;
in pkgs // {
  inherit hosts;
  inherit updateInfo;
  inherit sane;
  # AttrSet mapping attrpath to a list of attrpaths representing all updatable packages beneath it
  updateTargets = builtins.mapAttrs (_: v: v.subPackages) (lib.filterAttrs (_: v: v.subPackages != []) updateInfo);
  # AttrSet mapping attrpath to the path of a shell script which can be used to update the package at that attrpath
  updateScripts = builtins.mapAttrs (_: v: v.updateScript) (lib.filterAttrs (_: v: v.updateScript != "") updateInfo);
}
