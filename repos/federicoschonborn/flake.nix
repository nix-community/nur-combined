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

      debug = true;

      flake = {
        lib = import ./lib { inherit (nixpkgs) lib; };
      };

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
                  # akkoma-emoji
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
                  "olivvybee-blobbee"
                  "olivvybee-fox"
                  "olivvybee-neobread"
                  "olivvybee-neodlr"
                  "olivvybee-neofriends"
                  "olivvybee-neossb"
                  "renere-spinny-blobcats"
                  "renere-spinny-blobfoxes"
                  "renere-spinny-blobs"
                  "volpeon-drgn"
                  "volpeon-floof"
                  "volpeon-gphn"
                  "volpeon-neocat"
                  "volpeon-neofox"
                  "volpeon-vlpn"

                  "super-mario-127"
                ];
            };
          };

          legacyPackages = import ./. { inherit lib pkgs system; };
          packages = import ./flattenTree.nix config.legacyPackages;

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              deadnix
              jq
              nix-inspect
              nix-tree
              nushell
              statix
              nix-init
              nix-update
            ];

            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };

          apps = {
            default.program = pkgs.writers.writeNuBin "just" (builtins.readFile ./just.nu);

            generate-readme.program =
              let
                packageList = pkgs.writeText "package-list.md" (
                  builtins.concatStringsSep "\n" (
                    lib.mapAttrsToList (
                      name: value:
                      let
                        description = value.meta.description or "";
                        longDescription = value.meta.longDescription or "";
                        outputs = value.outputs or [ ];
                        homepage = value.meta.homepage or "";
                        changelog = value.meta.changelog or "";
                        position = value.meta.position or "";
                        licenses = lib.toList (value.meta.license or [ ]);
                        maintainers = value.meta.maintainers or [ ];
                        platforms = value.meta.platforms or [ ];
                        broken = value.meta.broken or false;
                        unfree = value.meta.unfree or false;

                        brokenSection = lib.optionalString broken ''
                          **💥 NOTE:** This package has been marked as broken.
                        '';

                        unfreeSection = lib.optionalString unfree ''
                          **🔒 NOTE:** This package has an unfree license.
                        '';

                        descriptionSection =
                          "${description}." + lib.optionalString (longDescription != "") "\n\n${longDescription}";

                        pnameSection = "- Name: `${value.pname or value.name}`";

                        versionSection = lib.optionalString (value ? version) "- Version: `${value.version}`";

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
                              let
                                emails = builtins.map (x: x.email) (builtins.filter (x: x ? email) maintainers);
                              in
                              if emails != [ ] then
                                "  - [✉️ Mail to all maintainers](mailto:" + (builtins.concatStringsSep "," emails) + ")"
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

            no-updateScript.program = pkgs.writeShellApplication {
              name = "no-updateScript";
              text = lib.concatLines (
                lib.mapAttrsToList (
                  name: value: lib.optionalString (!value ? updateScript) "echo '${name}'"
                ) config.packages
              );
            };

            update.program = pkgs.writeShellApplication {
              name = "update";
              text = lib.concatLines (
                lib.mapAttrsToList (
                  name: value:
                  lib.optionalString (value ? updateScript) (
                    lib.concatMapStringsSep " " lib.escapeShellArg (
                      value.updateScript
                      ++ [
                        name
                      ]
                    )
                  )
                ) config.packages
              );
            };
          };

          pre-commit = {
            check.enable = true;
            settings.hooks = {
              # Nix
              nixfmt-rfc-style = {
                enable = true;
                package = config.formatter;
              };
              deadnix.enable = true;
              statix.enable = true;
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
