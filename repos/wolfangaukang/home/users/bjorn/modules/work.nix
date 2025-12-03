{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (inputs) self;

  cfg = config.personaj.work;

  firefoxSettings = import "${self}/home/users/bjorn/settings/firefox" { inherit config lib pkgs; };
  ssmServersInfo = lib.importJSON "${self}/home/users/bjorn/misc/ssm.json";

  generateSSMConnectionString =
    target: profile: region:
    "sh -c \"aws ssm start-session --target ${target} --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=${profile} --region=${region}\"";

  ssmSettings =
    let
      identityFile = "${config.home.homeDirectory}/.ssh/Keys/devices/servers";
    in
    lib.attrsets.mapAttrs (
      name: value:
      let
        profile = value.profile;
        region = value.region;
        target = value.target;
        user = value.user;
      in
      {
        inherit identityFile user;
        proxyCommand = generateSSMConnectionString target profile region;
      }
    ) ssmServersInfo;

in
{
  options.personaj.work.simplerisk.enable = lib.mkEnableOption "the SimpleRisk profile";

  config = lib.mkIf cfg.simplerisk.enable {
    home.packages = with pkgs; [
      # GUI
      gnome-screenshot
      keybase-gui
      remmina
      slack

      # CLI
      awscli2
      aws-mfa
      sarchi
      ssm-session-manager-plugin
    ];
    programs = {
      firefox.profiles = lib.mkForce (
        firefoxSettings.defaultProfiles // { work = firefoxSettings.profiles.simplerisk; }
      );
      neovim = {
        extraPackages = with pkgs; [ terraform-ls ];
        plugins = with pkgs.vimPlugins; [
          Jenkinsfile-vim-syntax
          vim-packer
        ];
      };
      ssh = {
        enable = true;
        matchBlocks = ssmSettings;
      };
      vscode.profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          redhat.vscode-yaml
          kddejong.vscode-cfn-lint
        ];
        userSettings = {
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
      };
    };
    services = {
      kbfs.enable = true;
      keybase.enable = true;
    };
  };
}
