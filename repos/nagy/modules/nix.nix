{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./shortcommands.nix ];

  config = {
    environment.systemPackages = with pkgs; [
      nixfmt-rfc-style
      nil

      nix-prefetch
      # nix-prefetch-git # creates spooky temporary files during fetch.
      nix-diff
      nvd
      # nix-du
      nix-tree
      nix-init
      nix-update
      nix-output-monitor
      # nix-eval-jobs
      nixpkgs-review

      nickel
      nls
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
          "ca-derivations"
          # "pipe-operators"
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
    nagy.shortcommands.commands = {
      b = [ "nix-build" ];
      i = [ "nix-instantiate" ];
      b0 = [
        "nix-build"
        "--no-out-link"
      ];
      "b." = [
        "nix-build"
        "<nixpkgs>"
      ];
      "i." = [
        "nix-instantiate"
        "<nixpkgs>"
      ];
      "b.0" = [
        "nix-build"
        "<nixpkgs>"
        "--no-out-link"
      ];
      "i.j" = [
        "nix-instantiate"
        "<nixpkgs>"
        "--json"
        "--strict"
        "--eval"
      ];
      "b.." = [
        "nix-build"
        "<nixpkgs/nixos>"
      ];
      "i.." = [
        "nix-instantiate"
        "<nixpkgs/nixos>"
      ];
      "b+" = [ "nix-build-package" ];
      "i+" = [ "nix-instantiate-package" ];
      s = [ "nix-shell" ];
      sp = [
        "nix-shell"
        "-p"
      ];
      sE = [
        "nix-shell"
        "-E"
      ];
      R = [
        "nix"
        "run"
      ];
      SE = [
        "nix"
        "search"
      ];
      B = [
        "nix"
        "build"
        # until https://github.com/NixOS/nix/pull/8323 is merged
        "--print-build-logs"
      ];
      E = [
        "nix"
        "eval"
        # until https://github.com/NixOS/nix/pull/8323 is merged
        "--print-build-logs"
      ];
      S = [
        "nix"
        "shell"
        # until https://github.com/NixOS/nix/pull/8323 is merged
        "--print-build-logs"
      ];
      Ej = [
        "nix"
        "eval"
        "--json"
      ];
      Er = [
        "nix"
        "eval"
        "--raw"
      ];
      Bj = [
        "nix"
        "build"
        "--json"
        "--no-link"
      ];
      I = [
        "nix"
        "path-info"
      ];
      Is = [
        "nix"
        "path-info"
        "--size"
        "--human-readable"
      ];
      IS = [
        "nix"
        "path-info"
        "--closure-size"
        "--human-readable"
      ];
      Ij = [
        "nix"
        "path-info"
        "--json"
      ];
      IJ = [
        "nix"
        "path-info"
        "--closure-size"
        "--json"
      ];
      Ia = [
        "nix"
        "path-info"
        "-rsSh"
      ];
      SEj = [
        "nix"
        "search"
        "--json"
      ];

      "B." = [
        "nix"
        "build"
        "--file"
        "."
      ];
      "B.j" = [
        "nix"
        "build"
        "--file"
        "."
        "--json"
        "--no-link"
      ];
      "R." = [
        "nix"
        "run"
        "--file"
        "."
      ];
      "S." = [
        "nix"
        "shell"
        "--file"
        "."
      ];
      "E." = [
        "nix"
        "eval"
        "--file"
        "."
      ];
      "E.j" = [
        "nix"
        "eval"
        "--file"
        "."
        "--json"
      ];
      "SE." = [
        "nix"
        "search"
        "--file"
        "."
      ];

      "B:" = [
        "nix"
        "build"
        "--file"
        "<nixpkgs>"
        # until https://github.com/NixOS/nix/pull/8323 is merged
        "--print-build-logs"
      ];
      "B:j" = [
        "nix"
        "build"
        "--file"
        "<nixpkgs>"
        "--json"
        "--no-link"
      ];
      "R:" = [
        "nix"
        "run"
        "--file"
        "<nixpkgs>"
        # until https://github.com/NixOS/nix/pull/8323 is merged
        "--print-build-logs"
      ];
      "D:" = [
        "nix"
        "develop"
        "--file"
        "<nixpkgs>"
      ];
      "S:" = [
        "nix"
        "shell"
        "--file"
        "<nixpkgs>"
        # until https://github.com/NixOS/nix/pull/8323 is merged
        "--print-build-logs"
      ];
      "E:" = [
        "nix"
        "eval"
        "--file"
        "<nixpkgs>"
      ];
      "E:j" = [
        "nix"
        "eval"
        "--file"
        "<nixpkgs>"
        "--json"
      ];
    };
  };
}
