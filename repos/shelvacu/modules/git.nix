{
  lib,
  config,
  pkgs,
  vacuModuleType ? "nixos",
  vacuModules,
  ...
}:
let
  inherit (lib) types;
  cfg = config.vacu.git;
in
{
  imports = [
    vacuModules.packageSet
    (lib.optionalAttrs (vacuModuleType == "nixos") {
      vacu.assertions = [
        {
          assertion = !(cfg.enable && config.programs.git.enable);
          message = "vacu.git and programs.git should not both be enabled";
        }
      ];

      programs.git.enable = lib.mkIf cfg.enable false;
    })
    (lib.optionalAttrs (vacuModuleType == "nixos" || vacuModuleType == "nix-on-droid") {
      environment = lib.mkIf (cfg.enable && cfg.config != [ ]) { etc.gitconfig.text = cfg.configText; };
    })
  ];
  # https://github.com/NixOS/nixpkgs/blob/e8c38b73aeb218e27163376a2d617e61a2ad9b59/nixos/modules/programs/git.nix#L16
  options.vacu.git = {
    package = lib.mkPackageOption pkgs "git" { };
    enable = lib.mkEnableOption "git";
    config = lib.mkOption {
      type =
        let
          gitini = types.attrsOf (types.attrsOf types.anything);
        in
        types.either gitini (types.listOf gitini)
        // {
          merge =
            loc: defs:
            let
              config =
                builtins.foldl'
                  (
                    acc:
                    { value, ... }@x:
                    acc
                    // (
                      if builtins.isList value then
                        { ordered = acc.ordered ++ value; }
                      else
                        { unordered = acc.unordered ++ [ x ]; }
                    )
                  )
                  {
                    ordered = [ ];
                    unordered = [ ];
                  }
                  defs;
            in
            [ (gitini.merge loc config.unordered) ] ++ config.ordered;
        };
      default = [ ];
    };
    lfs.enable = lib.mkEnableOption "git lfs";
    lfs.package = lib.mkPackageOption pkgs "git-lfs" { };
    configText = lib.mkOption {
      readOnly = true;
      type = types.str;
      default = lib.concatMapStringsSep "\n" lib.generators.toGitINI cfg.config;
      defaultText = "(output config)";
    };
  };

  config = lib.mkIf cfg.enable {
    vacu.packages.git = {
      enable = true;
      package = cfg.package;
    };
    vacu.packages.git-lfs = lib.mkIf cfg.lfs.enable {
      enable = true;
      package = cfg.lfs.package;
    };
    vacu.git.config = lib.mkIf cfg.lfs.enable (
      let
        bin = lib.getExe cfg.lfs.package;
      in
      {
        filter.lfs = {
          clean = "${bin} clean -- %f";
          smudge = "${bin} smudge -- %f";
          process = "${bin} filter-process";
          required = true;
        };
      }
    );
  };
}
// lib.optionalAttrs (vacuModuleType == "nixos") { _class = "nixos"; }
