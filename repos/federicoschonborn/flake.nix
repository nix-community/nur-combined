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
    flake-parts.lib.mkFlake { inherit inputs; } (toplevel: {
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
        nixosModules = import ./modules/nixos;
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
                    # Packages
                  ''
                  + (lib.concatLines (
                    lib.mapAttrsToList (
                      path:
                      {
                        meta ? { },
                        ...
                      }@attrs:
                      lib.concatLines [
                        ''
                          <h2 id="${builtins.replaceStrings [ "." ] [ "-" ] path}">

                          `${path}`

                          </h2>
                        ''
                        (lib.optionalString meta.broken ''
                          > [!WARNING]
                          > 💥 This package is currently marked as broken.
                        '')
                        (lib.optionalString (meta ? description) ''
                          ${meta.description}
                        '')
                        "- Name: `${attrs.pname or attrs.name}`"
                        (lib.optionalString (attrs ? version && attrs ? pname) "- Version: `${attrs.version}`")
                        (lib.optionalString (attrs ? outputs && attrs.outputs != [ "out" ]) (
                          "- Outputs: "
                          + lib.concatMapStringsSep ", " (
                            x: if x == attrs.outputName or null then "**`${x}`**" else "`${x}`"
                          ) attrs.outputs
                        ))
                        (lib.optionalString (meta ? homepage)
                          "- [🌐 Homepage](${builtins.replaceStrings [ " " ] [ "%20" ] meta.homepage})"
                        )
                        (lib.optionalString (meta ? position) (
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
                                "https://github.com/NixOS/nixpkgs/blob/nixos-unstable/${path}#L${line}";
                          in
                          "- [📦 Source](${formatPosition meta.position})"
                        ))
                        (lib.optionalString (meta ? license) (
                          let
                            licenses = lib.toList meta.license;
                          in
                          "- License${lib.optionalString (builtins.length licenses > 1) "s"}: "
                          + (lib.concatMapStringsSep ", " (
                            x: if x ? url then "[`${x.fullName}`](${x.url})" else x.fullName
                          ) licenses)
                        ))
                        (lib.optionalString (meta ? changelog)
                          "- [📰 Changelog](${builtins.replaceStrings [ " " ] [ "%20" ] meta.changelog})"
                        )
                        ''

                          <!-- markdownlint-disable-next-line no-inline-html -->
                          <details>
                            <!-- markdownlint-disable-next-line no-inline-html -->
                            <summary>
                              Details
                            </summary>
                        ''
                        (lib.optionalString (meta ? longDescription) "${meta.longDescription}")
                        (lib.optionalString (meta ? platforms) (
                          "- Platforms:\n"
                          + lib.pipe meta.platforms [
                            (lib.filter (x: builtins.elem x toplevel.config.systems))
                            (lib.concatMapStringsSep "\n" (x: "  - `${x}`"))
                          ]
                        ))
                        ''
                          </details>
                        ''
                      ]
                    ) config.packages
                  ))
                );

                packageListFormatted =
                  pkgs.runCommand "PACKAGES.md" { nativeBuildInputs = [ pkgs.nodePackages.prettier ]; }
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
    });
}
