# FLAKE FEEDBACK:
# - if flake inputs are meant to be human-readable, a human should be able to easily track them down given the URL.
#   - this is not the case with registry URLs, like `nixpkgs/nixos-22.11`.
#   - this is marginally the case with schemes like `github:nixos/nixpkgs`.
#   - given the *existing* `git+https://` scheme, i propose expressing github URLs similarly:
#     - `github+https://github.com/nixos/nixpkgs/tree/nixos-22.11`
#     - this would allow for the same optimizations as today's `github:nixos/nixpkgs`, but without obscuring the source.
#       a code reader could view the source being referenced simply by clicking the https:// portion of that URI.
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
    # branch workflow:
    # - daily:
    #   - nixos-unstable cut from master after enough packages have been built in caches.
    # - every 6 hours:
    #   - master auto-merged into staging and staging-next
    #   - staging-next auto-merged into staging.
    # - manually, approximately once per month:
    #   - staging-next is cut from staging.
    #   - staging-next merged into master.
    #
    # which branch to source from?
    # - nixos-unstable: for everyday development; it provides good caching
    # - master: temporarily if i'm otherwise cherry-picking lots of already-applied patches
    # - staging-next: if testing stuff that's been PR'd into staging, i.e. base library updates.
    # - staging: maybe if no staging-next -> master PR has been cut yet?
    #
    # <https://github.com/nixos/nixpkgs/tree/nixos-unstable>
    # nixpkgs-unpatched.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-unpatched.url = "github:nixos/nixpkgs?ref=master";
    # nixpkgs-unpatched.url = "github:nixos/nixpkgs?ref=nixos-staging";
    # nixpkgs-unpatched.url = "github:nixos/nixpkgs?ref=nixos-staging-next";
    nixpkgs-next-unpatched.url = "github:nixos/nixpkgs?ref=staging-next";

    mobile-nixos = {
      # <https://github.com/nixos/mobile-nixos>
      # only used for building disk images, not relevant after deployment
      # TODO: replace with something else. commit `0f3ac0bef1aea70254a3bae35e3cc2561623f4c1`
      # replaces the imageBuilder with a "new implementation from celun" and wildly breaks my use.
      # pinning to d25d3b... is equivalent to holding at 2023-09-15
      url = "github:nixos/mobile-nixos?ref=d25d3b87e7f300d8066e31d792337d9cd7ecd23b";
      flake = false;
    };
    sops-nix = {
      # <https://github.com/Mic92/sops-nix>
      # used to distribute secrets to my hosts
      url = "github:Mic92/sops-nix";
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unpatched";
    };
    uninsane-dot-org = {
      # provides the package to deploy <https://uninsane.org>, used only when building the servo host
      url = "git+https://git.uninsane.org/colin/uninsane";
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unpatched";
    };
  };

  outputs = {
    self,
    nixpkgs-unpatched,
    nixpkgs-next-unpatched ? nixpkgs-unpatched,
    mobile-nixos,
    sops-nix,
    uninsane-dot-org,
    ...
  }@inputs:
    let
      inherit (builtins) attrNames elem listToAttrs map mapAttrs;
      # redefine some nixpkgs `lib` functions to avoid the infinite recursion
      # of if we tried to use patched `nixpkgs.lib` as part of the patching process.
      mapAttrs' = f: set:
        listToAttrs (map (attr: f attr set.${attr}) (attrNames set));
      optionalAttrs = cond: attrs: if cond then attrs else {};
      # mapAttrs but without the `name` argument
      mapAttrValues = f: mapAttrs (_: f);

      # rather than apply our nixpkgs patches as a flake input, do that here instead.
      # this (temporarily?) resolves the bad UX wherein a subflake residing in the same git
      # repo as the main flake causes the main flake to have an unstable hash.
      patchNixpkgs = variant: nixpkgs: (import ./nixpatches/flake.nix).outputs {
        inherit variant nixpkgs;
        self = patchNixpkgs variant nixpkgs;
      } // {
        # provide values that nixpkgs ordinarily sources from the flake.lock file,
        # inaccessible to it here because of the import-from-derivation.
        # rev and shortRev seem to not always exist (e.g. if the working tree is dirty),
        # so those are made conditional.
        #
        # these values impact the name of a produced nixos system. having date/rev in the
        # `readlink /run/current-system` store path helps debuggability.
        inherit (self) lastModifiedDate lastModified;
      } // optionalAttrs (self ? rev) {
        inherit (self) rev;
      } // optionalAttrs (self ? shortRev) {
        inherit (self) shortRev;
      };

      nixpkgs' = patchNixpkgs "master" nixpkgs-unpatched;
      nixpkgsCompiledBy = system: nixpkgs'.legacyPackages."${system}";

      evalHost = { name, local, target, light ? false, nixpkgs ? nixpkgs' }: nixpkgs.lib.nixosSystem {
        system = target;
        modules = [
          {
            nixpkgs.buildPlatform.system = local;
            # nixpkgs.config.replaceStdenv = { pkgs }: pkgs.ccacheStdenv;
          }
          (optionalAttrs (local != target) {
            # XXX(2023/12/11): cache.nixos.org uses `system = ...` instead of `hostPlatform.system`, and that choice impacts the closure of every package.
            # so avoid specifying hostPlatform.system on non-cross builds, so i can use upstream caches.
            nixpkgs.hostPlatform.system = target;
          })
          (optionalAttrs light {
            sane.enableSlowPrograms = false;
          })
          (import ./hosts/instantiate.nix { hostName = name; })
          self.nixosModules.default
          self.nixosModules.passthru
          {
            nixpkgs.overlays = [
              self.overlays.passthru
              self.overlays.sane-all
            ];
          }
        ];
      };
    in {
      nixosConfigurations = let
        hosts = {
          servo       = { name = "servo";  local = "x86_64-linux"; target = "x86_64-linux";  };
          desko       = { name = "desko";  local = "x86_64-linux"; target = "x86_64-linux";  };
          desko-light = { name = "desko";  local = "x86_64-linux"; target = "x86_64-linux";  light = true; };
          lappy       = { name = "lappy";  local = "x86_64-linux"; target = "x86_64-linux";  };
          lappy-light = { name = "lappy";  local = "x86_64-linux"; target = "x86_64-linux";  light = true; };
          moby        = { name = "moby";   local = "x86_64-linux"; target = "aarch64-linux"; };
          moby-light  = { name = "moby";   local = "x86_64-linux"; target = "aarch64-linux"; light = true; };
          rescue      = { name = "rescue"; local = "x86_64-linux"; target = "x86_64-linux";  };
        };
        hostsNext = mapAttrs' (h: v: {
          name = "${h}-next";
          value = v // { nixpkgs = patchNixpkgs "staging-next" nixpkgs-next-unpatched; };
        }) hosts;
      in mapAttrValues evalHost (
        hosts // hostsNext
      );

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
      hostConfigs = mapAttrValues (host: host.config) self.nixosConfigurations;
      hostSystems = mapAttrValues (host: host.config.system.build.toplevel) self.nixosConfigurations;
      hostPkgs = mapAttrValues (host: host.config.system.build.pkgs) self.nixosConfigurations;
      hostPrograms = mapAttrValues (host: mapAttrValues (p: p.package) host.config.sane.programs) self.nixosConfigurations;

      patched.nixpkgs = nixpkgs';

      overlays = {
        # N.B.: `nix flake check` requires every overlay to take `final: prev:` at defn site,
        #   hence the weird redundancy.
        default = final: prev: self.overlays.pkgs final prev;
        sane-all = final: prev: import ./overlays/all.nix final prev;
        disable-flakey-tests = final: prev: import ./overlays/disable-flakey-tests.nix final prev;
        pkgs = final: prev: import ./overlays/pkgs.nix final prev;
        pins = final: prev: import ./overlays/pins.nix final prev;
        preferences = final: prev: import ./overlays/preferences.nix final prev;
        optimizations = final: prev: import ./overlays/optimizations.nix final prev;
        passthru = final: prev:
          let
            mobile = (import "${mobile-nixos}/overlay/overlay.nix");
            uninsane = uninsane-dot-org.overlays.default;
          in
            (mobile final prev)
            // (uninsane final prev)
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
          sanePkgs = import ./pkgs { inherit pkgs; };
          deployScript = host: addr: action: pkgs.writeShellScript "deploy-${host}" ''
            nix build '.#nixosConfigurations.${host}.config.system.build.toplevel' --out-link ./result-${host} "$@"
            sudo nix sign-paths -r -k /run/secrets/nix_serve_privkey $(readlink ./result-${host})

            # XXX: this triggers another config eval & (potentially) build.
            # if the config changed between these invocations, the above signatures might not apply to the deployed config.
            # let the user handle that edge case by re-running this whole command.
            # N.B.: `--fast` option here is critical to cross-compiled deployments: without it the build machine will try to invoke the host machine's `nix` binary.
            # TODO: solve this by replacing the nixos-build invocation with:
            # - nix-copy-closure --to $host $result
            # - on target: nix-env set -p /nix/var/nix/profiles/system $result
            # - on target: $result/bin/switch-to-configuration
            nixos-rebuild --flake '.#${host}' ${action} --target-host colin@${addr} --use-remote-sudo "$@" --fast
          '';
          deployApp = host: addr: action: {
            type = "app";
            program = ''${deployScript host addr action}'';
          };

          # pkg updating.
          # a cleaner alternative lives here: <https://discourse.nixos.org/t/how-can-i-run-the-updatescript-of-personal-packages/25274/2>
          # mkUpdater :: [ String ] -> { type = "app"; program = path; }
          mkUpdater = attrPath: {
            type = "app";
            program = let
              pkg = pkgs.lib.getAttrFromPath attrPath sanePkgs;
              strAttrPath = pkgs.lib.concatStringsSep "." attrPath;
              commandArgv = pkg.updateScript.command or pkg.updateScript;
              command = pkgs.lib.escapeShellArgs commandArgv;
            in builtins.toString (pkgs.writeShellScript "update-${strAttrPath}" ''
              export UPDATE_NIX_NAME=${pkg.name}
              export UPDATE_NIX_PNAME=${pkg.pname}
              export UPDATE_NIX_OLD_VERSION=${pkg.version}
              export UPDATE_NIX_ATTR_PATH=${strAttrPath}
              ${command}
            '');
          };
          mkUpdatersNoAliases = opts: basePath: pkgs.lib.concatMapAttrs
            (name: pkg:
              if pkg.recurseForDerivations or false then {
                "${name}" = mkUpdaters opts (basePath ++ [ name ]);
              } else if pkg.updateScript or null != null then {
                "${name}" = mkUpdater (basePath ++ [ name ]);
              } else {}
            )
            (pkgs.lib.getAttrFromPath basePath sanePkgs);
          mkUpdaters = { ignore ? [], flakePrefix ? [] }@opts: basePath:
            let
              updaters = mkUpdatersNoAliases opts basePath;
              invokeUpdater = name: pkg:
                let
                  fullPath = basePath ++ [ name ];
                  doUpdateByDefault = !builtins.elem fullPath ignore;

                  # in case `name` has a `.` in it, we have to quote it
                  escapedPath = builtins.map (p: ''"${p}"'') fullPath;
                  updatePath = builtins.concatStringsSep "." (flakePrefix ++ escapedPath);
                in pkgs.lib.optionalString doUpdateByDefault (
                  pkgs.lib.escapeShellArgs [
                    "nix" "run" ".#${updatePath}"
                  ]
                );
            in {
              type = "app";
              # top-level app just invokes the updater of everything one layer below it
              program = builtins.toString (pkgs.writeShellScript
                (builtins.concatStringsSep "-" (flakePrefix ++ basePath))
                (builtins.concatStringsSep
                  "\n"
                  (pkgs.lib.mapAttrsToList invokeUpdater updaters)
                )
              );
            } // updaters;
        in {
          help = {
            type = "app";
            program = let
              helpMsg = builtins.toFile "nixos-config-help-message" ''
                commands:
                - `nix run '.#help'`
                  - show this message
                - `nix run '.#update.pkgs'`
                  - updates every package
                - `nix run '.#update.feeds'`
                  - updates metadata for all feeds
                - `nix run '.#init-feed' <url>`
                - `nix run '.#deploy.{desko,lappy,moby,servo}[-light][.test]' [nixos-rebuild args ...]`
                - `nix run '.#check'`
                  - make sure all systems build; NUR evaluates

                specific build targets of interest:
                - `nix build '.#imgs.rescue'`
              '';
            in builtins.toString (pkgs.writeShellScript "nixos-config-help" ''
              cat ${helpMsg}
              echo ""
              echo "complete flake structure:"
              nix flake show --option allow-import-from-derivation true
            '');
          };
          # wrangle some names to get package updaters which refer back into the flake, but also conditionally ignore certain paths (e.g. sane.feeds).
          # TODO: better design
          update = rec {
            _impl.pkgs.sane = mkUpdaters { flakePrefix = [ "update" "_impl" "pkgs" ]; ignore = [ [ "sane" "feeds" ] ]; } [ "sane" ];
            pkgs = _impl.pkgs.sane;
            _impl.feeds.sane.feeds = mkUpdaters { flakePrefix = [ "update" "_impl" "feeds" ]; } [ "sane" "feeds" ];
            feeds = _impl.feeds.sane.feeds;
          };

          init-feed = {
            type = "app";
            program = "${pkgs.feeds.init-feed}";
          };

          deploy = {
            lappy       = deployApp "lappy"       "lappy" "switch";
            lappy-light = deployApp "lappy-light" "lappy" "switch";
            moby        = deployApp "moby"        "moby"  "switch";
            moby-light  = deployApp "moby-light"  "moby"  "switch";
            moby-test   = deployApp "moby"        "moby"  "test";
            servo       = deployApp "servo"       "servo" "switch";
          };

          sync = {
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "sync-all" ''
              RC_lappy=$(nix run '.#sync.lappy' -- "$@")
              RC_moby=$(nix run '.#sync.moby' -- "$@")
              RC_desko=$(nix run '.#sync.desko' -- "$@")

              echo "lappy: $RC_lappy"
              echo "moby: $RC_moby"
              echo "desko: $RC_desko"
            '');
          };

          sync.desko = {
            # copy music from servo to desko
            # can run this from any device that has ssh access to desko and servo
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "sync-to-desko" ''
              sudo mount /mnt/desko-home
              ${pkgs.sane-scripts.sync-music}/bin/sane-sync-music --compat /mnt/servo-media/Music /mnt/desko-home/Music "$@"
            '');
          };

          sync.lappy = {
            # copy music from servo to lappy
            # can run this from any device that has ssh access to lappy and servo
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "sync-to-lappy" ''
              sudo mount /mnt/lappy-home
              ${pkgs.sane-scripts.sync-music}/bin/sane-sync-music --compress --compat /mnt/servo-media/Music /mnt/lappy-home/Music "$@"
            '');
          };

          sync.moby = {
            # copy music from servo to moby
            # can run this from any device that has ssh access to moby and servo
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "sync-to-moby" ''
              sudo mount /mnt/moby-home
              # N.B.: limited by network/disk -> reduce job count to improve pause/resume behavior
              ${pkgs.sane-scripts.sync-music}/bin/sane-sync-music --compress --compat --jobs 4 /mnt/servo-media/Music /mnt/moby-home/Music "$@"
            '');
          };

          check = {
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "check-all" ''
              nix run '.#check.nur'
              RC0=$?
              nix run '.#check.hostConfigs'
              RC1=$?
              nix run '.#check.rescue'
              RC2=$?
              echo "nur: $RC0"
              echo "hostConfigs: $RC1"
              echo "rescue: $RC2"
              exit $(($RC0 | $RC1 | $RC2))
            '');
          };

          check.nur = {
            # `nix run '.#check-nur'`
            # validates that my repo can be included in the Nix User Repository
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "check-nur" ''
              cd ${./.}/integrations/nur
              NIX_PATH= NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix-env -f . -qa \* --meta --xml \
                --allowed-uris https://static.rust-lang.org \
                --option restrict-eval true \
                --option allow-import-from-derivation true \
                --drv-path --show-trace \
                -I nixpkgs=${nixpkgs-unpatched} \
                -I ../../ \
                | tee  # tee to prevent interactive mode
            '');
          };

          check.hostConfigs = {
            type = "app";
            program = let
              checkHost = host: let
                shellHost = pkgs.lib.replaceStrings [ "-" ] [ "_" ] host;
              in ''
                nix build -v '.#nixosConfigurations.${host}.config.system.build.toplevel' --out-link ./result-${host} -j2 "$@"
                RC_${shellHost}=$?
              '';
            in builtins.toString (pkgs.writeShellScript
              "check-host-configs"
              ''
                # build minimally-usable hosts first, then their full image.
                # this gives me a minimal image i can deploy or copy over, early.
                ${checkHost "desko-light"}
                ${checkHost "moby-light"}
                ${checkHost "lappy-light"}

                ${checkHost "desko"}
                ${checkHost "lappy"}
                ${checkHost "servo"}
                ${checkHost "moby"}
                ${checkHost "rescue"}

                # still want to build the -light variants first so as to avoid multiple simultaneous webkitgtk builds
                ${checkHost "desko-light-next"}
                ${checkHost "moby-light-next"}

                ${checkHost "desko-next"}
                ${checkHost "lappy-next"}
                ${checkHost "servo-next"}
                ${checkHost "moby-next"}
                ${checkHost "rescue-next"}

                echo "desko: $RC_desko"
                echo "lappy: $RC_lappy"
                echo "servo: $RC_servo"
                echo "moby: $RC_moby"
                echo "rescue: $RC_rescue"

                echo "desko-next: $RC_desko_next"
                echo "lappy-next: $RC_lappy_next"
                echo "servo-next: $RC_servo_next"
                echo "moby-next: $RC_moby_next"
                echo "rescue-next: $RC_rescue_next"

                # i don't really care if the -next hosts fail. i build them mostly to keep the cache fresh/ready
                exit $(($RC_desko | $RC_lappy | $RC_servo | $RC_moby | $RC_rescue))
              ''
            );
          };

          check.rescue = {
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "check-rescue" ''
              nix build -v '.#imgs.rescue' --out-link ./result-rescue-img -j2
            '');
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
        pkgs.make = {
          # initialize with:
          # - `nix flake init -t '/home/colin/dev/nixos/#pkgs.make'`
          path = ./templates/pkgs/make;
          description = "default Makefile-based derivation";
        };
      };
    };
}

