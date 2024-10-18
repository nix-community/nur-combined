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
              # allowAliases = false;
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

                  "lapce-nix"
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
                      drvPath:
                      {
                        name ? drvPath,
                        pname ? name,
                        version ? "",
                        outputs ? [ ],
                        outputName ? "",
                        passthru ? { },
                        meta ? { },
                        ...
                      }:
                      let
                        tests = passthru.tests or { };
                        updateScript = passthru.updateScript or null;
                        description = meta.description or "";
                        longDescription = meta.longDescription or "";
                        homepage = meta.homepage or "";
                        changelog = meta.changelog or "";
                        position = meta.position or "";
                        licenses = lib.toList (meta.license or [ ]);
                        maintainers = meta.maintainers or [ ];
                        badPlatforms = meta.badPlatforms or [ ];
                        platforms = lib.subtractLists badPlatforms (meta.platforms or [ ]);
                        pkgConfigModules = meta.pkgConfigModules or [ ];
                        broken = meta.broken or false;
                        unfree = meta.unfree or false;

                        versionPart = lib.optionalString (version != "") " `${version}`";

                        homepagePart = lib.optionalString (homepage != "") " [🌐](${homepage} \"Homepage\")";

                        changelogPart = lib.optionalString (changelog != "") " [📰](${changelog} \"Changelog\")";

                        sourcePart =
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
                          lib.optionalString (position != "") " [📦](${formatPosition position} \"Source\")";

                        brokenSection = lib.optionalString broken ''
                          > [!WARNING]
                          > 💥 This package has been marked as broken.
                        '';

                        unfreeSection = lib.optionalString unfree ''
                          > [!WARNING]
                          > 🔒 This package has an unfree license.
                        '';

                        descriptionSection = lib.optionalString (description != "") (
                          "${description}.\n" + lib.optionalString (longDescription != "") "\n\n${longDescription}"
                        );

                        pnameSection = "- Name: `${pname}`";

                        outputsSection =
                          let
                            formatOutput = x: if x == outputName then "**`${x}`**" else "`${x}`";
                          in
                          lib.optionalString (outputs != [ ]) (
                            "- Outputs: " + (lib.concatMapStringsSep ", " formatOutput outputs)
                          );

                        testsSection =
                          let
                            formatTest = x: "`${x}`";
                          in
                          lib.optionalString (tests != { }) (
                            "- Tests: " + (lib.concatMapStringsSep ", " formatTest (builtins.attrNames tests))
                          );

                        updateScriptSection = "- Update Script: ${if updateScript != null then "✔️" else "❌"}";

                        pkgConfigSection =
                          let
                            formatModule = x: "`${x}.pc`";
                          in
                          lib.optionalString (pkgConfigModules != [ ]) (
                            "- `pkg-config` Modules: " + (lib.concatMapStringsSep ", " formatModule pkgConfigModules)
                          );

                        licenseSection =
                          let
                            formatLicense = x: if x ? url then "[`${x.spdxId}`](${x.url} '${x.fullName}')" else x.fullName;
                          in
                          lib.optionalString (licenses != null) (
                            "- License${lib.optionalString (builtins.length licenses > 1) "s"}: "
                            + (lib.concatMapStringsSep ", " formatLicense licenses)
                          );

                        maintainersSection =
                          let
                            formatMaintainer =
                              x:
                              let
                                formattedName = if x ? github then "[${x.name}](https://github.com/${x.github})" else x.name;
                                formattedEmail = lib.optionalString (x ? email) " [✉️](mailto:${x.email})";
                              in
                              "${formattedName}${formattedEmail}";
                            allMaintainersLink =
                              let
                                emails = builtins.map (x: x.email) (builtins.filter (x: x ? email) maintainers);
                              in
                              lib.optionalString (builtins.length emails > 1) (
                                "\n  - [✉️ Mail to all maintainers](mailto:" + (builtins.concatStringsSep "," emails) + ")"
                              );
                          in
                          lib.optionalString (maintainers != [ ]) (
                            "- Maintainer${lib.optionalString (builtins.length maintainers > 1) "s"}:"
                            + (
                              if builtins.length maintainers > 1 then
                                ("\n  - " + (lib.concatMapStringsSep "\n  - " formatMaintainer maintainers) + allMaintainersLink)
                              else
                                (" " + (formatMaintainer (builtins.elemAt maintainers 0)))
                            )
                          );

                        platformsSection = lib.optionalString (platforms != [ ]) (
                          "- Platforms: " + (lib.concatMapStringsSep ", " (x: "`${x}`") platforms)
                        );
                      in
                      builtins.concatStringsSep "\n" (
                        builtins.filter (x: x != "") [
                          ''
                            ### `${drvPath}`${versionPart}${homepagePart}${changelogPart}${sourcePart}
                          ''
                          descriptionSection
                          brokenSection
                          unfreeSection
                          ''

                            <!-- markdownlint-disable-next-line no-inline-html -->
                            <details>
                              <!-- markdownlint-disable-next-line no-inline-html -->
                              <summary>
                                Details
                              </summary>
                          ''
                          pnameSection
                          licenseSection
                          platformsSection
                          maintainersSection
                          outputsSection
                          testsSection
                          updateScriptSection
                          pkgConfigSection
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
