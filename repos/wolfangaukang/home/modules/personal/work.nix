{ config, lib, pkgs, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  cfg = config.defaultajAgordoj.work;
  settings = import ./settings.nix { inherit pkgs; };

in
{
  options.defaultajAgordoj.work = {
    simplerisk = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enables the SimpleRisk profile.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.simplerisk.enable (import ../../profiles/sets/simplerisk.nix {
      inherit pkgs;
      extra-pkgs = settings.packages.work;
      neovim-extensions = with pkgs.vimPlugins; [
        Jenkinsfile-vim-syntax
        vim-packer
      ];
      vscode-extensions = with pkgs.vscode-extensions; [
        redhat.vscode-yaml
        kddejong.vscode-cfn-lint
      ];
      vscode-settings = {
        # Cloudformation tags
        "yaml.customTags" = [
          "!And"
          "!And sequence"
          "!If"
          "!If sequence"
          "!Not"
          "!Not sequence"
          "!Equals"
          "!Equals sequence"
          "!Or"
          "!Or sequence"
          "!FindInMap"
          "!FindInMap sequence"
          "!Base64"
          "!Join"
          "!Join sequence"
          "!Cidr"
          "!Ref"
          "!Sub"
          "!Sub sequence"
          "!GetAtt"
          "!GetAZs"
          "!ImportValue"
          "!ImportValue sequence"
          "!Select"
          "!Select sequence"
          "!Split"
          "!Split sequence"
        ];
        "yaml.validate" = true;
      };
    }))
  ];

  meta.maintainers = with maintainers; [ wolfangaukang ];
}
