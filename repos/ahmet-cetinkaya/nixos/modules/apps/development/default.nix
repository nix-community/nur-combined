{pkgs, ...}: {
  imports = [
    # Languages
    ./c-cpp.nix
    ./javascript.nix
    ./go.nix
    ./dotnet.nix
    ./java.nix
    ./rust.nix
    ./python.nix

    # Frameworks
    ./flutter.nix

    # Game Development
    ./godot.nix
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    nerd-fonts.fira-code
    nerd-fonts.sauce-code-pro
    nerd-fonts.zed-mono
  ];

  environment.systemPackages = with pkgs; [
    # Editors
    neovim
    vscodium-fhs
    vscode-fhs
    zed-preview-bin

    antigravity-tools-bin
    google-antigravity-no-fhs

    # Browsers
    firefox-devedition

    # Tools
    git
    git-open
    gitui
    tea

    # Agents

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
  ];

  # Flatpak
  services.flatpak.packages = [
    # Database
    "io.dbeaver.DBeaverCommunity"

    # Containers
    "io.podman_desktop.PodmanDesktop"
  ];
}
