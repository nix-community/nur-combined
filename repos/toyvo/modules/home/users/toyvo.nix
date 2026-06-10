{
  config,
  lib,
  pkgs,
  system,
  inputs,
  ...
}:
let
  cfg = config.nixcfg;
in
{
  imports = [
    ../programs/terminals/hyper.nix
    ../programs/editors/zed.nix
  ];

  options.nixcfg.users.toyvo.enable = lib.mkEnableOption "Enable toyvo profile";

  config = lib.mkIf cfg.users.toyvo.enable {
    home.packages = [ inputs.nixcfg.packages.${system}.toyvo-neovim ];
    home.sessionVariables.EDITOR = "nvim";
    programs = {
      alacritty.enable = cfg.gui.enable;
      beets = {
        enable = pkgs.stdenv.isLinux;
        settings = {
          plugins = [
            "fetchart"
            "embedart"
          ];
          import.move = true;
          replace = {
            # Replace bad characters with _
            # prohibited in many filesystem paths
            "[<>:\\?\\*\\|]" = "_";
            # double quotation mark "
            "\\\"" = "_";
            # path separators: \ or /
            "[\\\\/]" = "_";
            # starting and closing periods
            "^\\." = "_";
            "\\.$" = "_";
            # control characters
            "[\\x00-\\x1f]" = "_";
            # dash at the start of a filename (causes command line ambiguity)
            "^-" = "_";
            # Replace bad characters with nothing
            # starting and closing whitespace
            "\\s+$" = "";
            "^\\s+" = "";
            # Use simple single quote
            "’" = "'";
          };
          paths = {
            default = "$albumartist/$album%aunique{} ($year)/$albumartist - $album - $track - $title";
            singleton = "Non-Album/$artist/$title";
            comp = "Compilations/$album%aunique{}/$track $title";
          };
          match.preferred = {
            countries = [ "US" ];
            media = [ "Digital Media|File" ];
            original_year = true;
          };
        };
      };
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      # TODO: undo
      rio.enable = cfg.gui.enable && pkgs.stdenv.isLinux;
      wezterm.enable = cfg.gui.enable;
      kitty.enable = cfg.gui.enable;
      git = {
        enable = true;
        signing = {
          key = config.sops.secrets."git_toyvo_sign_ed25519.pub".path;
          signByDefault = true;
        };
        settings.user = {
          name = "Collin Diekvoss";
          email = "Collin@Diekvoss.com";
        };
      };
      helix.enable = true;
      hyper.enable = cfg.gui.enable;
      opencode.enable = true;
      ssh =
        let
          identityConfig = {
            IdentitiesOnly = "yes";
            IdentityFile = [
              config.sops.secrets.ssh_toyvo_auth_ed25519.path
              config.sops.secrets.yubikey_usbc_ed25519_sk.path
              config.sops.secrets.yubikey_usba_ed25519_sk.path
            ];
          };
        in
        {
          enable = true;
          settings."github.com" = {
            IdentitiesOnly = "yes";
            IdentityFile = [
              config.sops.secrets.github_toyvo_auth_ed25519.path
              config.sops.secrets.yubikey_usbc_ed25519_sk.path
              config.sops.secrets.yubikey_usba_ed25519_sk.path
            ];
          };
          settings."oracle" = identityConfig // {
            User = "toyvo";
            HostName = "oracle-cloud-nixos.internal";
          };
          settings."router" = identityConfig // {
            User = "toyvo";
            HostName = "router.internal";
          };
          settings."nas" = identityConfig // {
            User = "toyvo";
            HostName = "nas.internal";
          };
          settings."protectli" = identityConfig // {
            User = "toyvo";
            HostName = "protectli.internal";
          };
          settings."macmini-m1" = identityConfig // {
            User = "toyvo";
            HostName = "macmini-m1.internal";
            RemoteCommand = "fish --login";
            RequestTTY = "yes";
          };
          settings."macmini-intel" = identityConfig // {
            User = "toyvo";
            HostName = "macmini-intel.internal";
            RemoteCommand = "fish --login";
            RequestTTY = "yes";
          };
          settings."windows-desktop" = identityConfig // {
            User = "toyvo";
            HostName = "windows-desktop.internal";
          };
          settings."steamdeck-nixos" = identityConfig // {
            User = "toyvo";
            HostName = "steamdeck-nixos.internal";
          };
          settings."10.1.0.*" = identityConfig;
        };
      zed-editor = {
        enable = cfg.gui.enable;
        package = pkgs.zed-editor;
      };
      zellij.enable = true;
      ideavim.enable = true;
    };
    catppuccin = {
      flavor = "frappe";
      accent = "red";
    };
    sops.secrets = {
      "git_toyvo_sign_ed25519.pub".mode = "0644";
      git_toyvo_sign_ed25519.mode = "0600";
      "github_toyvo_auth_ed25519.pub".mode = "0644";
      github_toyvo_auth_ed25519.mode = "0600";
      "ssh_toyvo_auth_ed25519.pub".mode = "0644";
      ssh_toyvo_auth_ed25519.mode = "0600";
      "yubikey_usba_ed25519_sk.pub".mode = "0644";
      yubikey_usba_ed25519_sk.mode = "0600";
      "yubikey_usbc_ed25519_sk.pub".mode = "0644";
      yubikey_usbc_ed25519_sk.mode = "0600";
    };
  };
}
