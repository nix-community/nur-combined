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
    ../programs/jujutsu.nix
    ../catppuccin.nix
  ];

  options.nixcfg.users.toyvo.enable = lib.mkEnableOption "Enable toyvo profile";

  config = lib.mkIf cfg.users.toyvo.enable {
    home = {
      packages = [
        inputs.nixcfg.packages.${system}.toyvo-neovim
      ];
      sessionVariables.EDITOR = "nvim";
    };
    programs = {
      alacritty.enable = cfg.gui.enable;
      bash.initExtra = ''
        source ${config.sops.templates."shell-secrets.env".path}
        export OPENCODE_API_KEY
      '';
      beets = {
        enable = pkgs.stdenv.hostPlatform.isLinux;
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
      fish.interactiveShellInit = ''
        sourceenv ${config.sops.templates."shell-secrets.env".path} > /dev/null 2>&1
      '';
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
      herdr.enable = true;
      hyper.enable = cfg.gui.enable;
      ideavim.enable = true;
      jujutsu = {
        enable = true;
        aiDescribe.enable = true;
        settings = {
          user = {
            name = "Collin Diekvoss";
            email = "Collin@Diekvoss.com";
          };
          ui.default-command = "st";
          signing = {
            backend = "ssh";
            behavior = "own";
            key = config.sops.secrets."git_toyvo_sign_ed25519.pub".path;
          };
        };
      };
      kitty.enable = cfg.gui.enable;
      man.package = pkgs.man;
      nix-index-database.comma.enable = true;
      opencode = {
        enable = true;
        settings.mcp.github-toyvo = {
          type = "remote";
          enabled = true;
          url = "https://api.githubcopilot.com/mcp";
          headers.Authorization = "Bearer {file:${config.sops.secrets.github_toyvo_pat.path}}";
        };
      };
      pi-coding-agent = {
        enable = true;
        extraPackages = with pkgs; [
          nodejs
          bun
        ];
      };
      # TODO: undo
      rio.enable = cfg.gui.enable && pkgs.stdenv.hostPlatform.isLinux;
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
          settings = {
            "github.com" = {
              User = "git";
              HostName = "github.com";
              IdentitiesOnly = "yes";
              IdentityFile = [
                config.sops.secrets.github_toyvo_auth_ed25519.path
                config.sops.secrets.yubikey_usbc_ed25519_sk.path
                config.sops.secrets.yubikey_usba_ed25519_sk.path
              ];
            };
            "git.toyvo.dev" = {
              User = "forgejo";
              HostName = "git.toyvo.dev";
              IdentitiesOnly = "yes";
              IdentityFile = [
                config.sops.secrets.github_toyvo_auth_ed25519.path
              ];
            };
            "macmini-intel" = identityConfig // {
              User = "toyvo";
              HostName = "macmini-intel.internal";
            };
            "macmini-m1" = identityConfig // {
              User = "toyvo";
              HostName = "macmini-m1.internal";
              RemoteCommand = "fish --login";
              RequestTTY = "yes";
            };
            "nas" = identityConfig // {
              User = "toyvo";
              HostName = "nas.internal";
            };
            "oracle" = identityConfig // {
              User = "toyvo";
              HostName = "oracle-cloud-nixos.internal";
            };
            "protectli" = identityConfig // {
              User = "toyvo";
              HostName = "protectli.internal";
            };
            "router" = identityConfig // {
              User = "toyvo";
              HostName = "router.internal";
              Port = "2222";
            };
            "steamdeck-nixos" = identityConfig // {
              User = "toyvo";
              HostName = "steamdeck-nixos.internal";
            };
            "windows-desktop" = identityConfig // {
              User = "toyvo";
              HostName = "windows-desktop.internal";
            };
            "10.1.0.*" = identityConfig;
          };
        };
      wezterm.enable = cfg.gui.enable;
      zed-editor = {
        enable = cfg.gui.enable;
        package = pkgs.zed-editor;
      };
      zsh.initContent = ''
        source ${config.sops.templates."shell-secrets.env".path}
        export OPENCODE_API_KEY
      '';
    };
    services.easyeffects.enable = pkgs.stdenv.hostPlatform.isLinux && cfg.gui.enable;
    sops = {
      secrets = {
        github_toyvo_pat = { };
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
        opencode_api_key = { };
      };
      templates = {
        "shell-secrets.env".content = ''
          OPENCODE_API_KEY=${config.sops.placeholder.opencode_api_key}
          ZED_OPEN_AI_COMPATIBLE_EDIT_PREDICTION_API_KEY=${config.sops.placeholder.opencode_api_key}
        '';
      };
    };
  };
}
