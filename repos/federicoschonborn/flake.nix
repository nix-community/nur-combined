{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

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
                  "volpeon-blobfox"
                  "volpeon-blobfox_flip"
                  "volpeon-bunhd"
                  "volpeon-bunhd_flip"
                  "volpeon-drgn"
                  "volpeon-floof"
                  "volpeon-fox"
                  "volpeon-gphn"
                  "volpeon-neocat"
                  "volpeon-neofox"
                  "volpeon-raccoon"
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
                      path:
                      {
                        passthru ? { },
                        meta ? { },
                        ...
                      }@attrs:
                      let
                        versionPart = lib.optionalString (attrs ? version) " `${attrs.version}`";

                        homepagePart =
                          lib.optionalString (meta ? homepage)
                            " [🌐](${builtins.replaceStrings [ " " ] [ "%20" ] meta.homepage} \"Homepage\")";

                        changelogPart =
                          lib.optionalString (meta ? changelog)
                            " [📰](${builtins.replaceStrings [ " " ] [ "%20" ] meta.changelog} \"Changelog\")";

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
                          lib.optionalString (meta ? position) " [📦](${formatPosition meta.position} \"Source\")";

                        brokenSection = lib.optionalString meta.broken ''
                          > [!WARNING]
                          > 💥 This package has been marked as broken.
                        '';

                        unfreeSection = lib.optionalString meta.unfree ''
                          > [!WARNING]
                          > 🔒 This package has an unfree license.
                        '';

                        descriptionSection = lib.optionalString (meta ? description) "${meta.description}.\n";

                        longDescriptionSection = lib.optionalString (meta ? longDescription) "\n\n${meta.longDescription}";

                        pnameSection = "- Name: `${attrs.pname or attrs.name}`";

                        outputsSection = lib.optionalString (attrs ? outputs) (
                          "- Outputs: "
                          + (lib.concatMapStringsSep ", " (
                            x: if attrs ? outputName && x == attrs.outputName then "**`${x}`**" else "`${x}`"
                          ) attrs.outputs)
                        );

                        testsSection = lib.optionalString (passthru ? tests) (
                          "- Tests: " + (lib.concatMapStringsSep ", " (x: "`${x}`") (builtins.attrNames passthru.tests))
                        );

                        updateScriptSection = "- Update Script: ${if passthru ? updateScript then "✔️" else "❌"}";

                        sourceProvenanceSection = lib.optionalString (meta ? sourceProvenance) (
                          "- Source Provenance: "
                          + (lib.concatMapStringsSep ", " (x: "`${x.shortName}`") meta.sourceProvenance)
                        );

                        pkgConfigSection = lib.optionalString (meta ? pkgConfigModules) (
                          "- `pkg-config` Modules: " + (lib.concatMapStringsSep ", " (x: "`${x}.pc`") meta.pkgConfigModules)
                        );

                        licenseSection = lib.optionalString (meta ? license) (
                          "- Licenses: "
                          + (lib.concatMapStringsSep ", " (
                            x: if x ? url then "[`${x.spdxId}`](${x.url} '${x.fullName}')" else x.fullName
                          ) (lib.toList meta.license))
                        );

                        maintainersSection = lib.optionalString (meta ? maintainers) (
                          "- Maintainers: "
                          + (
                            "\n  - "
                            + (lib.concatMapStringsSep "\n  - " (
                              x:
                              (if x ? github then "[${x.name}](https://github.com/${x.github})" else x.name)
                              + (lib.optionalString (x ? email) " [✉️](mailto:${x.email})")
                            ) meta.maintainers)
                            + "\n  - [✉️ Mail to all maintainers](mailto:"
                            + (builtins.concatStringsSep "," (
                              builtins.map (x: x.email) (builtins.filter (x: x ? email) meta.maintainers)
                            ))
                            + ")"
                          )
                        );

                        platformsSection = lib.optionalString (meta ? platforms) (
                          "- Platforms: " + (lib.concatMapStringsSep ", " (x: "`${x}`") meta.platforms)
                        );
                      in
                      builtins.concatStringsSep "\n" (
                        builtins.filter (x: x != "") [
                          ''
                            ### `${path}`${versionPart}${homepagePart}${changelogPart}${sourcePart}
                          ''
                          descriptionSection
                          longDescriptionSection
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
                          sourceProvenanceSection
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

            tests.program = pkgs.writeShellApplication {
              name = "tests";
              text =
                let
                  isBuildable =
                    p:
                    p.meta.available or true
                    && !(p.meta.broken or false)
                    && !(p.meta.unsupported or false)
                    && p.meta.license.free or true;
                in
                ''
                  echo '${
                    builtins.toJSON (
                      lib.filter (x: x != "") (
                        lib.flatten (
                          lib.mapAttrsToList (
                            name: value:
                            lib.optionalString (isBuildable value && value ? tests && value.tests != { }) (
                              builtins.map (testName: ".#${name}.tests.${testName}") (builtins.attrNames value.tests)
                            )
                          ) config.packages
                        )
                      )
                    )
                  }'
                '';
            };

            update.program = pkgs.writeShellApplication {
              name = "update";
              text = lib.concatLines (
                lib.mapAttrsToList (
                  name: value:
                  lib.optionalString (value ? updateScript) (
                    lib.concatMapStringsSep " " lib.escapeShellArg (value.updateScript ++ [ name ])
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
}
