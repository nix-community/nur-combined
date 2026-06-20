{
  config,
  pkgs,
  lib,
  ...
}:

let
  mkNixCmds = short: subcommand: extraFlags:
    let
      base = [ "nix" subcommand ] ++ extraFlags;
      withFile = file: base ++ [ "--file" file ];
      hasJson = lib.elem subcommand [ "build" "eval" ];
      jsonFlags =
        if subcommand == "build" then [ "--json" "--no-link" ]
        else [ "--json" ];
    in
    {
      "${short}" = base;
      "${short}." = withFile ".";
      "${short}:" = withFile "<nixpkgs>";
    }
    // lib.optionalAttrs hasJson {
      "${short}.j" = (withFile ".") ++ jsonFlags;
      "${short}:j" = (withFile "<nixpkgs>") ++ jsonFlags;
    };
in

{
  imports = [ ./shortcommands.nix ];

  config = {
    environment.systemPackages = [
      pkgs.nixfmt-rs
      pkgs.nil

      pkgs.nix-prefetch
      # nix-prefetch-git # creates spooky temporary files during fetch.
      pkgs.nix-diff
      pkgs.nvd
      # nix-du
      pkgs.nix-tree
      pkgs.nix-init
      pkgs.nix-update
      pkgs.nix-output-monitor
      # nix-eval-jobs
      pkgs.nixpkgs-review

      pkgs.nickel
      pkgs.nls
    ];
    nix = {
      nixPath = [
        "nixpkgs=${lib.cleanSource pkgs.path}"
      ];
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "recursive-nix"
          "impure-derivations"
        ];
        sandbox = true;
        auto-optimise-store = true;
        trusted-users = [
          "root"
          "@wheel"
        ];
        substituters = [ "https://nix-community.cachix.org" ];
        trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
        warn-dirty = false;
        # eval-cache = false;
        # Build logs are backed up. Backup mechanism itself takes care of the compression already.
        # compress-build-log = false; maybe enable after all. backups need to be thought of differently.
        # this reduces memory usage at the expense of performance
        # cores = 1;
        # this keeps build logs clean at the expense of performance
        # max-jobs = 1;
      };
      registry = {
        nixpkgs.flake = lib.cleanSource pkgs.path;
        u.to = {
          owner = "NixOS";
          repo = "nixpkgs";
          type = "github";
          ref = "nixos-unstable";
        };
        U.to = {
          owner = "NixOS";
          repo = "nixpkgs";
          type = "github";
        };
      };
    };

    environment.etc."nixos-options.json" = lib.mkIf config.documentation.nixos.enable {
      source = "${config.system.build.manual.optionsJSON}/share/doc/nixos/options.json";
    };

    environment.etc."nix-search.json" = lib.mkIf config.documentation.nixos.enable {
      source =
        pkgs.runCommandLocal "nix-search.json"
          {
            nativeBuildInputs = [
              # config.nix.package
              pkgs.nixVersions.latest
              pkgs.writableTmpDirAsHomeHook
              # optional
              pkgs.jq
            ];
          }
          ''
            echo '{"flakes":[],"version":2}' > empty-registry.json
            nix --offline --store ./. \
              --extra-experimental-features 'nix-command flakes' \
              --option flake-registry $PWD/empty-registry.json \
              search path:${pkgs.path} --json "" | jq --sort-keys > $out
          '';
    };
    nagy.shortcommands.commands =
      {
        # legacy nix-* commands
        b = [ "nix-build" ];
        i = [ "nix-instantiate" ];
        b0 = [ "nix-build" "--no-out-link" ];
        "b." = [ "nix-build" "<nixpkgs>" ];
        "i." = [ "nix-instantiate" "<nixpkgs>" ];
        "b.0" = [ "nix-build" "<nixpkgs>" "--no-out-link" ];
        "i.j" = [ "nix-instantiate" "<nixpkgs>" "--json" "--strict" "--eval" ];
        "b.." = [ "nix-build" "<nixpkgs/nixos>" ];
        "i.." = [ "nix-instantiate" "<nixpkgs/nixos>" ];
        "b+" = [ "nix-build-package" ];
        "i+" = [ "nix-instantiate-package" ];

        s  = [ "nix-shell" ];
        sp = [ "nix-shell" "-p" ];
        sE = [ "nix-shell" "-E" ];

        # nix search
        SE   = [ "nix" "search" ];
        SEj  = [ "nix" "search" "--json" ];
        "SE." = [ "nix" "search" "--file" "." ];

        # nix eval extras
        Ej = [ "nix" "eval" "--json" ];
        Er = [ "nix" "eval" "--raw" ];

        # nix build extras
        Bj = [ "nix" "build" "--json" "--no-link" ];

        # nix path-info
        I   = [ "nix" "path-info" ];
        Is  = [ "nix" "path-info" "--size" "--human-readable" ];
        IS  = [ "nix" "path-info" "--closure-size" "--human-readable" ];
        Ij  = [ "nix" "path-info" "--json" ];
        IJ  = [ "nix" "path-info" "--closure-size" "--json" ];
        Ia  = [ "nix" "path-info" "-rsSh" ];
      }
      // mkNixCmds "B" "build" [ "--print-build-logs" ]
      // mkNixCmds "E" "eval" [ "--print-build-logs" ]
      // mkNixCmds "R" "run" [ "--print-build-logs" ]
      // mkNixCmds "S" "shell" [ "--print-build-logs" ]
      // mkNixCmds "D" "develop" [];
  };
}
