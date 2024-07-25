{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
        flake-compat.follows = "";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      flake-parts,
      git-hooks,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ git-hooks.flakeModule ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
        "armv6l-linux"
        "armv7l-linux"

        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          lib,
          config,
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config = {
              allowBroken = true;
              allowUnfreePredicate =
                p:
                builtins.elem (lib.getName p) [
                  "av70-neomouse"
                  "eevee-neopossum"
                  "eppa-neobun"
                  "eppa-neocube"
                  "fotoente-neodino"
                  "fotoente-neohaj"
                  "fotoente-neomilk"
                  "fotoente-neotrain"
                  "mahiwa-neorat"
                  "moonrabbits-neodog"
                  "renere-spinny-blobcats"
                  "renere-spinny-blobfoxes"
                  "renere-spinny-blobs"
                  "olivvybee-blobbee"
                  "olivvybee-fox"
                  "olivvybee-neobread"
                  "olivvybee-neodlr"
                  "olivvybee-neofriends"
                  "olivvybee-neossb"
                  "volpeon-drgn"
                  "volpeon-floof"
                  "volpeon-gphn"
                  "volpeon-neocat"
                  "volpeon-neofox"
                  "volpeon-vlpn"
                ];
            };
          };

          legacyPackages = import ./. { inherit system pkgs; };
          packages = import ./flattenTree.nix config.legacyPackages;

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              deadnix
              jq
              nix-inspect
              nix-tree
              nushell
              statix
              (writers.writeNuBin "just" (builtins.readFile ./just.nu))
            ];

            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };

          apps = {
            default.program = pkgs.writers.writeNuBin "just" (builtins.readFile ./just.nu);

            generate-readme.program =
              let
                # 😱
                programList = lib.importJSON (
                  pkgs.runCommand "program-list.json" { } ''
                    { ${
                      builtins.concatStringsSep "\n" (
                        lib.mapAttrsToList (name: value: ''
                          if test -d ${value}/bin; then
                            ${lib.getExe pkgs.jq} -n '{"${name}": $ARGS.positional}' --args $(find ${value}/bin -type f -executable -not -name ".*" -printf "%f\n" | sort)
                          fi
                        '') config.packages
                      )
                    } } | ${lib.getExe pkgs.jq} -s add > $out
                  ''
                );

                packageList = pkgs.writeText "package-list.md" (
                  builtins.concatStringsSep "\n" (
                    lib.mapAttrsToList (
                      name: value:
                      let
                        programs = programList.${name} or [ ];

                        description = value.meta.description or "";
                        longDescription = value.meta.longDescription or "";
                        outputs = value.outputs or [ ];
                        homepage = value.meta.homepage or "";
                        changelog = value.meta.changelog or "";
                        position = value.meta.position or "";
                        licenses = lib.toList (value.meta.license or [ ]);
                        maintainers = value.meta.maintainers or [ ];
                        platforms = value.meta.platforms or [ ];
                        mainProgram = value.meta.mainProgram or "";
                        broken = value.meta.broken or false;
                        unfree = value.meta.unfree or false;

                        brokenSection = lib.optionalString broken ''
                          **💥 NOTE:** This package has been marked as broken.
                        '';

                        unfreeSection = lib.optionalString unfree ''
                          **🔒 NOTE:** This package has an unfree license.
                        '';

                        pnameSection = "- Name: `${value.pname or value.name}`";

                        versionSection = lib.optionalString (value ? version) "- Version: `${value.version}`";

                        descriptionSection = if longDescription != "" then longDescription else "${description}.";

                        outputsSection =
                          let
                            formatOutput = x: if x == value.outputName then "**`${x}`**" else "`${x}`";
                          in
                          lib.optionalString (outputs != [ ]) (
                            "- Outputs: " + (lib.concatMapStringsSep ", " formatOutput outputs)
                          );

                        homepageSection = lib.optionalString (homepage != "") "- [Homepage](${homepage})";

                        changelogSection = lib.optionalString (changelog != "") "- [Changelog](${changelog})";

                        positionSection =
                          let
                            formatPosition =
                              x:
                              let
                                parts = builtins.match "/nix/store/.{32}-source/(.+):([[:digit:]]+)" x;
                                path = builtins.elemAt parts 0;
                                line = builtins.elemAt parts 1;
                              in
                              if builtins.pathExists (lib.path.append ./. path) then
                                "./${path}#L${line}"
                              else
                                "https://github.com/NixOS/nixpkgs/blob/${nixpkgs.shortRev}/${path}#L${line}";
                          in
                          lib.optionalString (position != "") "- [Source](${formatPosition position})";

                        licenseSection =
                          let
                            formatLicense = x: if x ? url then "[`${x.spdxId}`](${x.url} '${x.fullName}')" else x.fullName;
                          in
                          lib.optionalString (licenses != null) (
                            "- License${if builtins.length licenses > 1 then "s" else ""}: "
                            + (lib.concatMapStringsSep ", " formatLicense licenses)
                          );

                        programsSection =
                          let
                            formatProgram = x: if x == mainProgram then "**`${x}`**" else "`${x}`";
                          in
                          lib.optionalString (programs != [ ]) (
                            "- Programs provided: " + (lib.concatMapStringsSep ", " formatProgram programs)
                          );

                        maintainersSection =
                          let
                            formatMaintainer =
                              x:
                              let
                                formattedName = if x ? github then "[${x.name}](https://github.com/${x.github})" else x.name;
                                formattedEmail = lib.optionalString (x ? email) " <[`${x.email}`](mailto:${x.email})>";
                              in
                              "  - ${formattedName}${formattedEmail}\n";
                            allMaintainersLink =
                              if builtins.any (x: x ? email) maintainers then
                                "  - [✉️ Mail to all maintainers](mailto:"
                                + (lib.concatMapStringsSep "," (x: x.email or null) maintainers)
                                + ")"
                              else
                                "";
                          in
                          lib.optionalString (maintainers != [ ]) (
                            "- Maintainers:\n" + (lib.concatMapStringsSep "" formatMaintainer maintainers) + allMaintainersLink
                          );

                        platformsSection =
                          let
                            formatPlatform = x: "`${x}`";
                          in
                          lib.optionalString (platforms != [ ]) (
                            "- Platforms: " + (lib.concatMapStringsSep ", " formatPlatform platforms)
                          );
                      in
                      builtins.concatStringsSep "\n" (
                        builtins.filter (x: x != "") [
                          ''
                            ### `${name}`
                          ''
                          brokenSection
                          unfreeSection
                          descriptionSection
                          pnameSection
                          versionSection
                          homepageSection
                          changelogSection
                          licenseSection
                          positionSection
                          maintainersSection
                          ''

                            <!-- markdownlint-disable-next-line no-inline-html -->
                            <details>
                              <!-- markdownlint-disable-next-line no-inline-html -->
                              <summary>
                                Package details
                              </summary>
                          ''
                          outputsSection
                          programsSection
                          platformsSection
                          ''
                            </details>
                          ''
                        ]
                      )
                    ) config.packages
                  )
                );
              in
              pkgs.writeShellApplication {
                name = "generate-readme";
                text = ''
                  cat ${meta/README.tmpl.md} ${packageList} > README.md
                  ${lib.getExe pkgs.nodePackages.prettier} --write README.md
                '';
              };

            update.program = pkgs.writeShellApplication {
              name = "update";
              text = ''
                nix-shell --show-trace "${nixpkgs.outPath}/maintainers/scripts/update.nix" \
                  --arg commit 'true' \
                  --arg include-overlays "[(import ./overlay.nix)]" \
                  --arg keep-going 'true' \
                  --arg predicate '(
                    let prefix = builtins.toPath ./pkgs; prefixLen = builtins.stringLength prefix;
                    in (_: p: p.meta?position && (builtins.substring 0 prefixLen p.meta.position) == prefix)
                  )'
              '';
            };
          };

          pre-commit = {
            check.enable = true;
            settings.hooks = {
              # Nix
              nixfmt = {
                enable = true;
                package = config.formatter;
              };
              deadnix.enable = true;
              statix.enable = true;
              generate-readme = {
                enable = true;
                entry = "nix run --print-build-logs .#generate-readme";
              };
            };
          };

          formatter = pkgs.nixfmt-rfc-style;
        };
    };

  nixConfig = {
    extra-substituters = [ "https://federicoschonborn.cachix.org" ];
    extra-trusted-public-keys = [
      "federicoschonborn.cachix.org-1:tqctt7S1zZuwKcakzMxeATNq+dhmh2v6cq+oBf4hgIU="
    ];
  };
}
