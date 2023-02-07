{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # CLI
    curl
    vim
    wget
    agenix
  ];
}
