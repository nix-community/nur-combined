{ config, lib, pkgs, unstable, ... }:

{

  services.onedrive.enable = false;

  environment.systemPackages = with pkgs; [

    # DIAGRAM
    drawio
    graphviz

    # SHELL
    gum

    # 2FA
    authenticator

    sqlite

    # PASSWORDS
    gnupg
    pinentry
    pinentry-gtk2
    pass

    unstable.nickel
    dhall

    attic-client

    vscode

    # AWS
    cw # cloudwatch in the terminal
    aws-mfa
    awsweeper
    unstable.granted

    #unstable.cloud-nuke
    #unstable.aws-nuke
    unstable.awscli2
    ssm-session-manager-plugin
    aws-vault
    ssmsh

    #git-remote-codecommit

    #azure-cli
    #unstable.bruno # UI for testing API's

    # TERRAFORM
    terraform-docs
    terrascan
    terraformer
    tflint
    #tfswitch
    #unstable.terracognita



  ];
}

