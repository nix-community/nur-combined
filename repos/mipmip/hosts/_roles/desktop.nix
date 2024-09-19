{ config, inputs, system, pkgs, ... }:

{
  imports = [

    ../../modules/base-common.nix
    ../../modules/base-docker.nix
    ../../modules/base-git.nix
    ../../modules/base-hardware.nix
    ../../modules/base-infrastructure.nix
    ../../modules/base-modern-unix.nix
    ../../modules/base-tex.nix
    ../../modules/base-tmux.nix
    ../../modules/base-vim.nix

    ../../modules/desktop-chrome.nix
    ../../modules/desktop-communication.nix
    ../../modules/desktop-dtp.nix
    ../../modules/desktop-firefox.nix
    ../../modules/desktop-dev.nix
    ../../modules/desktop-fonts.nix
    ../../modules/desktop-gnome.nix
    ../../modules/desktop-hyprland.nix
    ../../modules/desktop-st.nix
    ../../modules/desktop-openai.nix
    ../../modules/desktop-video.nix
    ../../modules/desktop-audio.nix
#    ../../modules/desktop-virtualbox.nix
    ../../modules/desktop-security.nix
    ../../modules/desktop-minecraft.nix

    ../../modules/dev-jsonyaml.nix
    ../../modules/dev-core.nix
    ../../modules/dev-crystal.nix
    ../../modules/dev-go.nix
    ../../modules/dev-technative.nix

    ../../modules/explore-pkg.nix

    ../../modules/hardware-kbd-keychron.nix
    ../../modules/hardware-krd_disable-caps.nix
    ../../modules/hardware-printers.nix

    ../../modules/nix-agenix.nix
    ../../modules/nix-common.nix
    ../../modules/nix-desktop.nix
    ../../modules/nix-home-manager-global.nix
    ../../modules/nix-utils.nix

    ../../modules/nur-my-pkgs.nix

  ];
}

