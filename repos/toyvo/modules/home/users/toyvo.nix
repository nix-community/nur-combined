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
    home.packages = with pkgs; [
      inputs.nixcfg.packages.${system}.toyvo-neovim
      opencommit
    ];
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
      jujutsu = {
        enable = true;
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
          aliases = {
            rbm = [
              "util"
              "exec"
              "--"
              "sh"
              "-c"
              "jj git fetch --all-remotes && jj rebase \"$@\" -d main@origin"
              "sh"
            ];
          };
        };
      };
      helix.enable = true;
      herdr.enable = true;
      hyper.enable = cfg.gui.enable;
      pi-coding-agent = {
        enable = true;
        extraPackages = with pkgs; [
          nodejs
          bun
        ];
      };
      opencode = {
        enable = true;
        settings.mcp.github-toyvo = {
          type = "remote";
          enabled = true;
          url = "https://api.githubcopilot.com/mcp";
          headers.Authorization = "Bearer {file:${config.sops.secrets.github_toyvo_pat.path}}";
        };
      };
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
      ideavim.enable = true;
      bash.initExtra = ''
        source ${config.sops.templates."shell-secrets.env".path}
        export OPENCODE_API_KEY
      '';
      zsh.initContent = ''
        source ${config.sops.templates."shell-secrets.env".path}
        export OPENCODE_API_KEY
      '';
      fish.interactiveShellInit = ''
        sourceenv ${config.sops.templates."shell-secrets.env".path} > /dev/null 2>&1
      '';
    };
    catppuccin = {
      flavor = "frappe";
      accent = "red";
    };
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
        # see https://models.dev/?search=opencode&sort=output-costper&order=asc if considering different models, same api key, but url is different https://opencode.ai/zen/v1 vs https://opencode.ai/zen/go/v1
        opencommit.content = ''
          OCO_MODEL=mimo-v2.5-free
          OCO_API_URL=https://opencode.ai/zen/v1
          OCO_PROXY=undefined
          OCO_API_KEY=${config.sops.placeholder.opencode_api_key}
          OCO_API_CUSTOM_HEADERS=undefined
          OCO_AI_PROVIDER=openai
          OCO_TOKENS_MAX_INPUT=8192
          OCO_TOKENS_MAX_OUTPUT=500
          OCO_DESCRIPTION=false
          OCO_EMOJI=false
          OCO_LANGUAGE=en
          OCO_MESSAGE_TEMPLATE_PLACEHOLDER=$msg
          OCO_PROMPT_MODULE=conventional-commit
          OCO_ONE_LINE_COMMIT=false
          OCO_TEST_MOCK_TYPE=commit-message
          OCO_OMIT_SCOPE=false
          OCO_GITPUSH=true
          OCO_WHY=false
          OCO_HOOK_AUTO_UNCOMMENT=false
        '';
        "shell-secrets.env".content = ''
          OPENCODE_API_KEY=${config.sops.placeholder.opencode_api_key}
        '';
      };
    };
    home.file.".opencommit".source =
      config.lib.file.mkOutOfStoreSymlink config.sops.templates.opencommit.path;
    # ~/.opencommit is a read-only sops symlink, so opencommit's startup
    # migrations (which rewrite the global config) fail with EACCES. Our
    # config is fully managed above, so mark all known migrations complete.
    home.file.".opencommit_migrations".text = ''
      ["00_use_single_api_key_and_url","01_remove_obsolete_config_keys_from_global_file","02_set_missing_default_values"]
    '';
  };
}
