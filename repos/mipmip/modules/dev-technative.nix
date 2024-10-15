{ config, lib, pkgs, unstable, ... }:

{


  environment.systemPackages = with pkgs; [

    # DIAGRAM
    drawio
    graphviz

    # OFFICE365
    onedrivegui
    onedrive

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
    unstable.dbgate

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


    vulnix

  ];
}

