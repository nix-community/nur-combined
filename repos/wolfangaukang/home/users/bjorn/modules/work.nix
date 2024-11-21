{ config, lib, pkgs, ... }:

let
  inherit (lib) concatStrings types mkIf mkMerge mkOption;
  inherit (pkgs.nur.repos.rycee) firefox-addons;
  settings.firefox = import ../settings/firefox { inherit config lib pkgs; };

  generateSSMConnectionString = { target, profile, region ? "" }:
    concatStrings [
      "sh -c \"aws ssm start-session --target ${target} --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=${profile}"
      (if (region != "") then " --region=${region}" else "")
      "\""
    ];

  generateWildcardSSMConnectionString = { profile, region ? "" }: generateSSMConnectionString { target = "$(echo %h | awk -F '_' 'NR==1{print $2}')"; inherit profile region; };

  cfg = config.defaultajAgordoj.work;

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
    (mkIf cfg.simplerisk.enable {
      home.packages = with pkgs; [
        # GUI
        keybase-gui
        remmina

        # CLI
        awscli2
        aws-mfa
        sarchi
        ssm-session-manager-plugin
      ];
      programs = {
        firefox.profiles.work = {
          id = 5;
          search = settings.firefox.searchSettings;
          extensions = settings.firefox.baseExtensions ++ (with firefox-addons; [ keybase ]);
          settings = mkMerge [
            (settings.firefox.baseSettings)
          ];
          name = "SimpleRisk";
        };
        neovim = {
          extraPackages = with pkgs; [
            # Terraform LSP
            terraform-ls
          ];
          plugins = with pkgs.vimPlugins; [
            Jenkinsfile-vim-syntax
            vim-packer
          ];
        };
        ssh = {
          enable = true;
          matchBlocks =
            let
              user = "pedro";
              identityFile = "${config.home.homeDirectory}/.ssh/Keys/devices/servers";
            in
            {
              vpn = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-009d4ed7fd7372feb"; profile = user; };
              };
              vpn-canada = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-0436147dded5cfdc4"; profile = user; region = "ca-central-1"; };
              };
              vpn-london = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-04f0c4defbaba5c0d"; profile = user; region = "eu-west-2"; };
              };
              elk = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-0a83d0bc2e5b71538"; profile = user; };
              };
              dev-k8s-m = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-087189274e47ce9cb"; profile = user; };
              };
              dev-k8s-w1 = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-0776fac6d2f947df7"; profile = user; };
              };
              prod-k8s-m = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-0cc94219444dd3efa"; profile = user; };
              };
              prod-k8s-w1 = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-0fc54c73ddeadecad"; profile = user; };
              };
              prod-k8s-w2 = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-09a1e5e79c4fd630d"; profile = user; };
              };
              prod-k8s-w3 = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-0d2e4483227cf2af5"; profile = user; };
              };
              www = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-0496f3e028de86fbe"; profile = user; };
              };
              jenkins = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-0d10de49d69d7ed57"; profile = user; };
              };
              services = {
                inherit user identityFile;
                proxyCommand = generateSSMConnectionString { target = "i-0a90f07d42b4d3f86"; profile = user; };
              };
              "simplerisk_i-* simplerisk_mi-*" = {
                inherit identityFile;
                proxyCommand = generateWildcardSSMConnectionString { profile = user; };
              };
              "simplerisk-ca_i-* simplerisk-ca_mi-*" = {
                inherit identityFile;
                proxyCommand = generateWildcardSSMConnectionString { profile = user; region = "ca-central-1"; };
              };
              "simplerisk-lo_i-* simplerisk-lo_mi-*" = {
                inherit identityFile;
                proxyCommand = generateWildcardSSMConnectionString { profile = user; region = "eu-west-2"; };
              };
              #proxyJumpExample = {
              #  hostname = "example.com";
              #  proxyJump = "proxyjumpserver";
              #};
            };
        };
        vscode = {
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
    })
  ];

}
