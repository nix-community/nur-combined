# FLAKE FEEDBACK:
# - if flake inputs are meant to be human-readable, a human should be able to easily track them down given the URL.
#   - this is not the case with registry URLs, like `nixpkgs/nixos-22.11`.
#   - this is marginally the case with schemes like `github:nixos/nixpkgs`.
#   - given the *existing* `git+https://` scheme, i propose expressing github URLs similarly:
#     - `github+https://github.com/nixos/nixpkgs/tree/nixos-22.11`
# - need some way to apply local patches to inputs.
#
#
# DEVELOPMENT DOCS:
# - Flake docs: <https://nixos.wiki/wiki/Flakes>
# - Flake RFC: <https://github.com/tweag/rfcs/blob/flakes/rfcs/0049-flakes.md>
#   - Discussion: <https://github.com/NixOS/rfcs/pull/49>
# - <https://serokell.io/blog/practical-nix-flakes>
#
#
# COMMON OPERATIONS:
# - update a specific flake input:
#   - `nix flake lock --update-input nixpkgs`

{
  # XXX: use the `github:` scheme instead of the more readable git+https: because it's *way* more efficient
  # preferably, i would rewrite the human-readable https URLs to nix-specific github: URLs with a helper,
  # but `inputs` is required to be a strict attrset: not an expression.
  inputs = {
    # <https://github.com/nixos/nixpkgs/tree/nixos-22.11>
    # nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-22.11";

    # branch workflow:
    # - daily:
    #   - nixos-unstable cut from master after enough packages have been built in caches.
    # - every 6 hours:
    #   - master auto-merged into staging.
    #   - staging-next auto-merged into staging.
    # - manually, approximately once per month:
    #   - staging-next is cut from staging.
    #   - staging-next merged into master.
    #
    # which branch to source from?
    # - for everyday development, prefer `nixos-unstable` branch, as it provides good caching.
    # - if need to test bleeding updates (e.g. if submitting code into staging):
    #   - use `staging-next` if it's been cut (i.e. if there's an active staging-next -> master PR)
    #   - use `staging` if no staging-next branch has been cut.
    #
    # <https://github.com/nixos/nixpkgs/tree/nixos-unstable>
    # nixpkgs-unpatched.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-unpatched.url = "github:nixos/nixpkgs?ref=staging-next";
    # nixpkgs-unpatched.url = "github:nixos/nixpkgs?ref=staging";

    mobile-nixos = {
      # <https://github.com/nixos/mobile-nixos>
      url = "github:nixos/mobile-nixos";
      flake = false;
    };
    sops-nix = {
      # <https://github.com/Mic92/sops-nix>
      url = "github:Mic92/sops-nix";
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unpatched";
    };
    uninsane-dot-org = {
      url = "git+https://git.uninsane.org/colin/uninsane";
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unpatched";
    };
    nix-serve = {
      # <https://github.com/edolstra/nix-serve>
      url = "github:edolstra/nix-serve";
    };
  };

  outputs = {
    self,
    nixpkgs-unpatched,
    mobile-nixos,
    sops-nix,
    uninsane-dot-org,
    nix-serve,
    ...
  }@inputs:
    let
      inherit (builtins) attrNames elem listToAttrs map mapAttrs;
      mapAttrs' = f: set:
        listToAttrs (map (attr: f attr set.${attr}) (attrNames set));
      # mapAttrs but without the `name` argument
      mapAttrValues = f: mapAttrs (_: f);
      # rather than apply our nixpkgs patches as a flake input, do that here instead.
      # this (temporarily?) resolves the bad UX wherein a subflake residing in the same git
      # repo as the main flake causes the main flake to have an unstable hash.
      nixpkgs = (import ./nixpatches/flake.nix).outputs {
        self = nixpkgs;
        nixpkgs = nixpkgs-unpatched;
      };

      nixpkgsCompiledBy = local: nixpkgs.legacyPackages."${local}";

      evalHost = { name, local, target }:
        let
          # XXX: we'd prefer to use `nixosSystem = (nixpkgsCompiledBy target).nixos`
          # but it doesn't propagate config to the underlying pkgs, meaning it doesn't let you use
          # non-free packages even after setting nixpkgs.allowUnfree.
          # XXX: patch using the target -- not local -- otherwise the target will
          # need to emulate the host in order to rebuild!
          nixosSystem = import ((nixpkgsCompiledBy target).path + "/nixos/lib/eval-config.nix");
        in
          (nixosSystem {
            modules = [
              (import ./hosts/instantiate.nix { localSystem = local; hostName = name; })
              self.nixosModules.default
              self.nixosModules.passthru
              {
                nixpkgs.overlays = [
                  self.overlays.disable-flakey-tests
                  self.overlays.passthru
                  self.overlays.pins
                  self.overlays.pkgs
                  # self.overlays.optimizations
                ];
                nixpkgs.hostPlatform = target;
                # nixpkgs.buildPlatform = local;  # set by instantiate.nix instead
                # nixpkgs.config.replaceStdenv = { pkgs }: pkgs.ccacheStdenv;
              }
            ];
          });
    in {
      nixosConfigurations =
        let
          hosts = {
            servo =  { name = "servo"; local = "x86_64-linux"; target = "x86_64-linux"; };
            desko =  { name = "desko"; local = "x86_64-linux"; target = "x86_64-linux"; };
            lappy =  { name = "lappy"; local = "x86_64-linux"; target = "x86_64-linux"; };
            moby  =  { name = "moby";  local = "x86_64-linux"; target = "aarch64-linux"; };
            rescue = { name = "rescue"; local = "x86_64-linux"; target = "x86_64-linux"; };
          };
          # cross-compiled builds: instead of emulating the host, build using a cross-compiler.
          # - these are faster to *build* than the emulated variants (useful when tweaking packages),
          # - but fewer of their packages can be found in upstream caches.
          cross = mapAttrValues evalHost hosts;
          emulated = mapAttrValues
            ({name, local, target}: evalHost {
              inherit name target;
              local = null;
            })
            hosts;
          prefixAttrs = prefix: attrs: mapAttrs'
            (name: value: {
              name = prefix + name;
              inherit value;
            })
            attrs;
        in
          (prefixAttrs "cross-" cross) //
          (prefixAttrs "emulated-" emulated) // {
            # prefer native builds for these machines:
            inherit (emulated) servo desko lappy rescue;
            # prefer cross-compiled builds for these machines:
            inherit (cross) moby;
          };

      # unofficial output
      # this produces a EFI-bootable .img file (GPT with a /boot partition and a system (/ or /nix) partition).
      # after building this:
      #   - flash it to a bootable medium (SD card, flash drive, HDD)
      #   - resize the root partition (use cfdisk)
      #   - mount the part
      #      - chown root:nixbld <part>/nix/store
      #      - chown root:root -R <part>/nix/store/*
      #      - chown root:root -R <part>/persist  # if using impermanence
      #      - populate any important things (persist/, home/colin/.ssh, etc)
      #   - boot
      #   - if fs wasn't resized automatically, then `sudo btrfs filesystem resize max /`
      #   - checkout this flake into /etc/nixos AND UPDATE THE FS UUIDS.
      #   - `nixos-rebuild --flake './#<host>' switch`
      imgs = mapAttrValues (host: host.config.system.build.img) self.nixosConfigurations;

      # unofficial output
      host-pkgs = mapAttrValues (host: host.config.system.build.pkgs) self.nixosConfigurations;

      overlays = {
        # N.B.: `nix flake check` requires every overlay to take `final: prev:` at defn site,
        #   hence the weird redundancy.
        default = final: prev: self.overlays.pkgs final prev;
        disable-flakey-tests = final: prev: import ./overlays/disable-flakey-tests.nix final prev;
        pkgs = final: prev: import ./overlays/pkgs.nix final prev;
        pins = final: prev: import ./overlays/pins.nix final prev;
        optimizations = final: prev: import ./overlays/optimizations.nix final prev;
        passthru = final: prev:
          let
            stable =
              if inputs ? "nixpkgs-stable" then (
                final': prev': {
                  stable = inputs.nixpkgs-stable.legacyPackages."${prev'.stdenv.hostPlatform.system}";
                }
              ) else (final': prev': {});
            mobile = (import "${mobile-nixos}/overlay/overlay.nix");
            uninsane = uninsane-dot-org.overlay;
            # nix-serve' = nix-serve.overlay;
            nix-serve' = next: prev: {
              # XXX(2023/03/02): upstream isn't compatible with modern `nix`. probably the perl bindings.
              # - we use the package built against `nixpkgs` specified in its flake rather than use its overlay,
              #   to get around this.
              inherit (nix-serve.packages."${next.system}") nix-serve;
            };
          in
              (stable final prev)
              // (mobile final prev)
              // (uninsane final prev)
              // (nix-serve' final prev)
            ;
      };

      nixosModules = rec {
        default = sane;
        sane = import ./modules;
        passthru = { ... }: {
          imports = [
            sops-nix.nixosModules.sops
          ];
        };
      };

      # this includes both our native packages and all the nixpkgs packages.
      legacyPackages =
        let
          allPkgsFor = sys: (nixpkgsCompiledBy sys).appendOverlays [
            self.overlays.passthru self.overlays.pkgs
          ];
        in {
          x86_64-linux = allPkgsFor "x86_64-linux";
          aarch64-linux = allPkgsFor "aarch64-linux";
        };

      # extract only our own packages from the full set.
      # because of `nix flake check`, we flatten the package set and only surface x86_64-linux packages.
      packages = mapAttrs
        (system: allPkgs:
          allPkgs.lib.filterAttrs (name: pkg:
            # keep only packages which will pass `nix flake check`, i.e. keep only:
            # - derivations (not package sets)
            # - packages that build for the given platform
            (! elem name [ "feeds" "pythonPackagesExtensions" ])
            && (allPkgs.lib.meta.availableOn allPkgs.stdenv.hostPlatform pkg)
          )
          (
            # expose sane packages and chosen inputs (uninsane.org)
            (import ./pkgs { pkgs = allPkgs; }) // {
              inherit (allPkgs) uninsane-dot-org;
            }
          )
        )
        # self.legacyPackages;
        { inherit (self.legacyPackages) x86_64-linux; }
      ;

      apps."x86_64-linux" =
        let
          pkgs = self.legacyPackages."x86_64-linux";
          deployScript = action: pkgs.writeShellScript "deploy-moby" ''
            nixos-rebuild --flake '.#moby' build $@
            sudo nix sign-paths -r -k /run/secrets/nix_serve_privkey $(readlink ./result)
            nixos-rebuild --flake '.#moby' ${action} --target-host colin@moby-hn --use-remote-sudo $@
          '';
        in {
          update-feeds = {
            type = "app";
            program = "${pkgs.feeds.updateScript}";
          };

          init-feed = {
            # use like `nix run '.#init-feed' uninsane.org`
            type = "app";
            program = "${pkgs.feeds.initFeedScript}";
          };

          deploy-moby-test = {
            # `nix run '.#deploy-moby-test'`
            type = "app";
            program = ''${deployScript "test"}'';
          };
          deploy-moby = {
            # `nix run '.#deploy-moby-switch'`
            type = "app";
            program = ''${deployScript "switch"}'';
          };
        };

      templates = {
        env.python-data = {
          # initialize with:
          # - `nix flake init -t '/home/colin/dev/nixos/#env.python-data'`
          # then enter with:
          # - `nix develop`
          path = ./templates/env/python-data;
          description = "python environment for data processing";
        };
        pkgs.rust-inline = {
          # initialize with:
          # - `nix flake init -t '/home/colin/dev/nixos/#pkgs.rust-inline'`
          path = ./templates/pkgs/rust-inline;
          description = "rust package and development environment (inline rust sources)";
        };
        pkgs.rust = {
          # initialize with:
          # - `nix flake init -t '/home/colin/dev/nixos/#pkgs.rust'`
          path = ./templates/pkgs/rust;
          description = "rust package fit to ship in nixpkgs";
        };
      };
    };
}

