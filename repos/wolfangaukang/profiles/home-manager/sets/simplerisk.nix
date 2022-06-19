{ pkgs, ... }:

{
  imports = [
    ../common/keybase.nix
  ];

  home.packages = with pkgs; [
    # GUI Tools
    upwork
    remmina
    signumone-ks

    # CLI Tools
    awscli2
    aws-mfa
    ssm-session-manager-plugin

    # Development
    # PHP 7.4 is not available on 22.11
    (php81.withExtensions ({ enabled, all }: enabled ++ [ all.ast ]))
    php81Packages.composer
    ruby
    yarn
  ];

  # Adding SimpleRisk Firefox profile
  programs = {
    firefox = {
      profiles = {
        work = {
          id = 2;
          name = "SimpleRisk";
        };
      };
    };
    neovim = {
      plugins = with pkgs.vimPlugins; [
        Jenkinsfile-vim-syntax
        vim-packer
      ];
    };
    ssh = { 
      enable = true;
      matchBlocks = {
        vpn = {
          user = "pedro";
          proxyCommand = "sh -c \"aws ssm start-session --target i-009d4ed7fd7372feb --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        elk = {
          user = "pedror";
          proxyCommand = "sh -c \"aws ssm start-session --target i-0693e8247e055bd61 --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        dev-k8s-m = {
          user = "pedro";
          proxyCommand = "sh -c \"aws ssm start-session --target i-087189274e47ce9cb --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        dev-k8s-w1 = {
          user = "pedro";
          proxyCommand = "sh -c \"aws ssm start-session --target i-0776fac6d2f947df7 --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        prod-k8s-m = {
          user = "pedro";
          proxyCommand = "sh -c \"aws ssm start-session --target i-0cc94219444dd3efa --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        prod-k8s-w1 = {
          user = "pedro";
          proxyCommand = "sh -c \"aws ssm start-session --target i-0fc54c73ddeadecad --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        prod-k8s-w2 = {
          user = "pedro";
          proxyCommand = "sh -c \"aws ssm start-session --target i-09a1e5e79c4fd630d --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        prod-k8s-w3 = {
          user = "pedro";
          proxyCommand = "sh -c \"aws ssm start-session --target i-0d2e4483227cf2af5 --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        www = {
          user = "pedro";
          proxyCommand = "sh -c \"aws ssm start-session --target i-0496f3e028de86fbe --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        jenkins = {
          user = "pedro";
          proxyCommand = "sh -c \"aws ssm start-session --target i-02e75aa4d27e485f2 --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        "simplerisk_i-* simplerisk_mi-*" = {
          proxyCommand = "sh -c \"aws ssm start-session --target $(echo %h | awk -F '_' 'NR==1{print $2}') --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
        };
        "simplerisk-ca_i-* simplerisk-ca_mi-*" = {
          proxyCommand = "sh -c \"aws ssm start-session --target $(echo %h | awk -F '_' 'NR==1{print $2}') --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --region ca-central-1 --profile=pedro\"";
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
      };
    };
  };
}
