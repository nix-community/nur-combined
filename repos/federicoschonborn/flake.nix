{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
        gitignore.follows = "";
      };
    };

    nix-check-deps = {
      url = "github:lordgrimmauld/nix-check-deps";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    # Indirect
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      systems,
      flake-parts,
      git-hooks,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (toplevel: {
      imports = [ git-hooks.flakeModule ];

      systems = import systems;

      flake = {
        lib = import ./lib { inherit (nixpkgs) lib; };
        nixosModules = import ./nixos/modules;
      };

      perSystem =
        {
          lib,
          config,
          pkgs,
          system,
          inputs',
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
                  "super-mario-127"
                ];
            };
          };

          legacyPackages = import ./. { inherit system pkgs lib; };
          packages = lib.filterAttrs (_: lib.isDerivation) config.legacyPackages;

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              jq
              just
              nix-init
              nix-update
              nushell
              inputs'.nix-check-deps.packages.nix-check-deps
            ];

            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };

          apps = {
            generate-readme.program =
              let
                packageList = pkgs.writeText "PACKAGES.md" (
                  ''
                    <!-- markdownlint-disable MD033 -->

                    # Packages
                  ''
                  + lib.concatMapAttrsStringSep "\n\n" (
                    path: value:
                    lib.concatStringsSep "\n" (
                      let
                        inherit (value) meta;
                        cleanPath = builtins.replaceStrings [ "." ] [ "-" ] path;
                        cleanURL = x: builtins.replaceStrings [ " " ] [ "%20" ] x;
                      in
                      [ "## `${path}` {#${cleanPath}}" ]
                      ++ lib.optional (meta ? broken && meta.broken) ''
                        > [!WARNING]
                        > 💥 This package is currently marked as broken.
                      ''
                      ++ lib.optional (meta ? description) "${meta.description}."
                      ++ lib.optional (meta ? longDescription) meta.longDescription
                      ++ [ "- Name: `${lib.getName value}`" ]
                      ++ [ "- Version: `${lib.getVersion value}`" ]
                      ++
                        lib.optional (value ? outputs && value.outputs != [ "out" ])
                          "- Outputs: ${
                            lib.concatMapStringsSep ", " (
                              x: if x == value.outputName or null then "**`${x}`**" else "`${x}`"
                            ) value.outputs
                          }"
                      ++ lib.optional (meta ? homepage) "- [🌐 Homepage](${cleanURL meta.homepage})"
                      ++ lib.optional (meta ? changelog) "- [📰 Changelog](${cleanURL meta.changelog})"
                      ++ lib.optional (meta ? position) (
                        let
                          parts = builtins.match "/nix/store/.{32}-source/(.+):([[:digit:]]+)" meta.position;
                          path = builtins.elemAt parts 0;
                          line = builtins.elemAt parts 1;
                        in
                        "- [📦 Source](./${path}#L${line})"
                      )
                      ++ lib.optional (meta ? license) (
                        let
                          licenses = lib.toList meta.license;
                          label = if builtins.length licenses > 1 then "Licenses" else "License";
                        in
                        "- 📄 ${label}: ${
                          lib.concatMapStringsSep ", " (
                            x: if x ? url then "[`${x.fullName}`](${x.url})" else x.fullName
                          ) licenses
                        }"
                      )
                      ++
                        lib.optional (meta ? platforms)
                          "- 🖥️ Platforms: ${
                            lib.concatMapStringsSep ", " (system: "`${system}`") (
                              lib.intersectLists toplevel.config.systems meta.platforms
                            )
                          }"
                    )
                  ) config.packages
                );

                packageListFormatted =
                  pkgs.runCommand "PACKAGES.md"
                    {
                      nativeBuildInputs = [ pkgs.nodePackages.prettier ];
                    }
                    ''
                      prettier ${packageList} > $out
                    '';
              in
              pkgs.writeShellApplication {
                name = "generate-readme";
                text = ''
                  cat ${packageListFormatted} > PACKAGES.md
                '';
              };

            update.program = pkgs.writeShellApplication {
              name = "update";
              text = ''
                for attr in "$@"; do
                  case "$attr" in
                  ${lib.concatLines (
                    lib.mapAttrsToList (
                      name: value:
                      if value ? updateScript then
                        ''
                          ${name})
                            echo Updating ${name}...
                            ${lib.escapeShellArgs (
                              [
                                "env"
                                "UPDATE_NIX_NAME=${value.name}"
                                "UPDATE_NIX_PNAME=${value.pname}"
                                "UPDATE_NIX_OLD_VERSION=${value.version}"
                                "UPDATE_NIX_ATTR_PATH=${name}"
                              ]
                              ++ (value.updateScript.command or (lib.toList value.updateScript))
                            )}
                            ;;
                        ''
                      else
                        ''
                          ${name})
                            echo Skipping ${name}...
                            ;;
                        ''
                    ) config.packages
                  )}
                  esac
                done
              '';
            };

            update-all.program = pkgs.writeShellApplication {
              name = "update-all";
              text = ''
                ${config.apps.update.program} ${lib.concatStringsSep " " (builtins.attrNames config.packages)}
              '';
            };

            no-update-script.program = pkgs.writeShellApplication {
              name = "no-update-script";
              text = lib.concatLines (
                lib.mapAttrsToList (
                  name: value: lib.optionalString (!value ? updateScript) "echo ${name}"
                ) config.packages
              );
            };

            no-strict-deps.program = pkgs.writeShellApplication {
              name = "no-strict-deps";
              text = lib.concatLines (
                lib.mapAttrsToList (
                  name: value: lib.optionalString (!value.strictDeps or false) "echo ${name}"
                ) config.packages
              );
            };

            no-install-check.program = pkgs.writeShellApplication {
              name = "no-install-check";
              text = lib.concatLines (
                lib.mapAttrsToList (
                  name: value: lib.optionalString (!value.doInstallCheck or false) "echo ${name}"
                ) config.packages
              );
            };

            check-deps.program = pkgs.writeShellApplication {
              name = "check-deps";
              text = lib.concatLines (
                lib.mapAttrsToList (name: _: ''
                  echo "Checking ${name}..."
                  ${lib.getExe' inputs'.nix-check-deps.packages.nix-check-deps "nix-check-deps"} ".#${name}"
                '') config.packages
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
                    lib.pipe config.packages [
                      (lib.mapAttrsToList (
                        name: value:
                        lib.optionalString (isBuildable value && value ? tests && value.tests != { }) (
                          builtins.map (testName: ".#${name}.tests.${testName}") (builtins.attrNames value.tests)
                        )
                      ))
                      (lib.filter (x: x != ""))
                      lib.flatten
                      builtins.toJSON
                    ]
                  }'
                '';
            };
          };

          pre-commit = {
            check.enable = true;
            settings.hooks = {
              # Nix
              nixfmt-rfc-style = {
                enable = true;
                package = pkgs.nixfmt-rfc-style;
              };
              deadnix.enable = true;
              statix.enable = true;
            };
          };

          formatter = pkgs.nixfmt-tree;
        };
    });
}
