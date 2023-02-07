{ pkgs 
, self
, extra-pkgs ? []
, neovim-extensions ? []
, vscode-extensions ? []
, vscode-settings ? {}
}:

let
  inherit (pkgs.nur.repos.rycee) firefox-addons;
  inherit (pkgs.lib) mkMerge;
  common = import "${self}/home/profiles/common.nix" { inherit firefox-addons; };

in {
  home.packages = with pkgs; [
    # GUI
    keybase-gui
    remmina
    signumone-ks
    upwork-require

    # CLI
    awscli2
    aws-mfa
    ssm-session-manager-plugin
  ] ++ extra-pkgs;
  programs = {
    firefox.profiles.work = {
      id = 4;
      search = common.firefox.search;
      extensions = common.firefox.extensions;
      settings = mkMerge [
        (common.firefox.settings)
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
      ] ++ neovim-extensions;
    };
    ssh = { 
      enable = true;
      matchBlocks =
        let
          user = "pedro";
        in {
          vpn = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-009d4ed7fd7372feb --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
          };
          vpn-canada = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-0436147dded5cfdc4 --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro --region=ca-central-1\"";
          };
          vpn-london = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-04f0c4defbaba5c0d --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro --region=eu-west-2\"";
          };
          elk = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-0fd41698004c0d538 --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
          };
          dev-k8s-m = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-087189274e47ce9cb --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
          };
          dev-k8s-w1 = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-0776fac6d2f947df7 --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
          };
          prod-k8s-m = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-0cc94219444dd3efa --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
          };
          prod-k8s-w1 = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-0fc54c73ddeadecad --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
          };
          prod-k8s-w2 = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-09a1e5e79c4fd630d --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
          };
          prod-k8s-w3 = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-0d2e4483227cf2af5 --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
          };
          www = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-0496f3e028de86fbe --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
          };
          jenkins = {
            inherit user;
            proxyCommand = "sh -c \"aws ssm start-session --target i-0d10de49d69d7ed57 --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=pedro\"";
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
      ] ++ vscode-extensions;
      userSettings = vscode-settings;
    };
  };
  services = {
    kbfs.enable = true;
    keybase.enable = true;
  };
}
