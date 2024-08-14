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


    vscode
    dhall

    # AWS
    cw # cloudwatch in the terminal
    aws-mfa
    awsweeper
    #unstable.cloud-nuke
    #unstable.aws-nuke
    unstable.awscli2
    ssm-session-manager-plugin
    aws-vault
    ssmsh

    git-remote-codecommit

    unstable.azure-cli
    unstable.bruno


    # TERRAFORM
    terraform-docs
    terrascan
    terraformer
    tflint
    #tfswitch
    #unstable.terracognita


    #RANDSTAD
    #citrix_workspace

    #TRACKLIB
    #wireguard-tools
    #unstable.nodePackages.aws-cdk

    #ADEVINTA
    #unstable.globalprotect-openconnect
    #openconnect
    proxychains

    #VNC ADEVINTA
    remmina
    #realvnc-vnc-viewer

  ];
}

