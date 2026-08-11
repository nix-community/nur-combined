{pkgs, ...}: {
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    nerd-fonts.fira-code
    nerd-fonts.sauce-code-pro
    nerd-fonts.zed-mono
  ];

  environment.systemPackages = with pkgs; [
    # Editors
    neovim
    zed-preview-bin
    vscode-fhs

    # Browsers
    firefox-devedition

    # Tools
    git
    git-open
    gitui
    openssl
    tea

    # Formatters & Linters
    shellcheck
    shfmt
    stylua
    taplo

    # Nix
    alejandra
    statix
    deadnix
    nixfmt
    nixd
  ];

  # Flatpak
  services.flatpak.packages = [
    # Database
    "io.dbeaver.DBeaverCommunity"

    # Containers
    "io.podman_desktop.PodmanDesktop"
  ];
}
