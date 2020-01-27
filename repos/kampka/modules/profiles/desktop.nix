{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.kampka.profiles.desktop;
  common = import ./common.nix { inherit config pkgs lib; };

  neovim-overlay = self: super: let
    vimConfigure = {
      customRC = ''
        let s:localVimConfig = $HOME . "/.config/nvim/init.vim"
        if filereadable(expand(s:localVimConfig))
          exe 'source' s:localVimConfig
        endif
      '';
      packages.kampka-defaults.opt = with pkgs.vimPlugins; [ LanguageClient-neovim ];
    };
  in
    {
      neovim = super.neovim.override {
        configure = vimConfigure;
        extraMakeWrapperArgs = "--set MYVIMRC ${pkgs.vimUtils.vimrcFile vimConfigure}";
      };
    };
in
{

  options.kampka.profiles.desktop = {
    enable = mkEnableOption "A minimal profile for desktop systems";
  };

  config = mkIf cfg.enable (
    recursiveUpdate common rec{

      nixpkgs.overlays = [ neovim-overlay ];

      boot.loader.grub.splashImage = null;

      i18n = {
        consoleKeyMap = mkDefault "de-latin1-nodeadkeys";
      };

      documentation.enable = mkDefault true;
      documentation.dev.enable = mkDefault true;

      networking.firewall.enable = mkDefault true;
      networking.networkmanager.enable = mkDefault true;

      services.openssh.enable = mkDefault false;
      services.fail2ban.enable = mkDefault true;

      kampka.services.ntp.enable = mkDefault true;
      kampka.services.dns-cache.enable = mkDefault true;

      time.timeZone = mkDefault "Europe/Berlin";

      # General shell configuration
      programs.zsh.enable = mkDefault true;
      kampka.programs.zsh-history.enable = mkDefault true;
      kampka.programs.direnv.enable = mkDefault true;
      kampka.services.tmux.enable = mkDefault true;

      services.lorri.enable = mkDefault true;

      # Setup gpg-agent with yubikey support
      programs.gnupg.agent.enable = mkDefault true;
      programs.gnupg.agent.enableSSHSupport = mkDefault true;
      services.udev.packages = with pkgs; [
        yubikey-personalization
        libu2f-host
      ];
      # Enable smartcard daemon
      services.pcscd.enable = mkDefault true;

      # X-Server and Gnome3 desktop configuration
      services.xserver.enable = mkDefault true;
      services.xserver.layout = mkDefault "de";
      services.xserver.xkbOptions = mkDefault "caps:swapescape";

      services.xserver.displayManager.gdm.enable = mkDefault true;
      # Disable wayland if the nvidia driver is used
      services.xserver.displayManager.gdm.wayland = mkDefault (!(any (v: v == "nvidia") config.services.xserver.videoDrivers));
      services.xserver.desktopManager.gnome3.enable = mkDefault true;

      # Typically needed for wifi drivers and the like
      hardware.enableRedistributableFirmware = mkDefault true;

      environment.systemPackages = common.environment.systemPackages ++ [] ++ (
        with pkgs; [
          alacritty
          bat
          ctags
          fzf
          git
          gnupg
          most
          neovim
          ntfs3g
          ripgrep
          rsync
          stow
        ]
      );

      environment.variables = {
        EDITOR = "nvim";
        PAGER = "most";
      };

      environment.shellAliases = {
        vi = "nvim";
        vim = "nvim";
        cat = "bat -p --pager=never";
      };

    }
  );
}
