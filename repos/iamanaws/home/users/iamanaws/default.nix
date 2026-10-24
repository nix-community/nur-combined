{
  inputs,
  config,
  hostConfig,
  pkgs,
  ...
}:

let
  llmAgentPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  disabledModules = [
    "programs/zed-editor.nix"
  ];

  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    ../../shared/modules/zed-editor.nix

    ./config
    ./graphical.nix
  ];

  home.packages =
    with pkgs;
    [
      nixd
    ]
    ++ [ llmAgentPkgs.cursor-agent ];

  programs = {
    home-manager.enable = true;

    claude-code = {
      enable = hostConfig.isGraphical;
      enableMcpIntegration = true;
      package = llmAgentPkgs.claude-code.override {
        disableTelemetry = true;
      };
      settings = {
        includeCoAuthoredBy = false;
        model = "fable";
        effortLevel = "low";
        permissions = {
          allow = [ ];
        };
      };
    skills = { };
    };

    codex = {
      enable = config.programs.claude-code.enable;
      # enableMcpIntegration = true;
      package = llmAgentPkgs.codex;
      # settings = { };
      # skills = { };
    };

    git = {
      enable = true;
      lfs.enable = true;

      signing = {
        signByDefault = true;
        format = "openpgp";
        key = "C5EE9152B41B8B071A4A30AD33744241C7B86BCA";
      };

      settings = {
        user = {
          name = "Angel J";
          email = "78835633+iamanaws@users.noreply.github.com";
        };

        sendemail = {
          smtpServer = "smtp.protonmail.ch";
          smtpServerPort = 587;
          smtpUser = "iamanaws@httpd.dev";
          smtpEncryption = "tls";
        };

        alias = {
          pu = "push";
          co = "checkout";
          cm = "commit";
        };

        core.editor = "vim";
        init.defaultBranch = "main";
        merge.conflictStyle = "zdiff3";
        push = {
          autosetupremote = true;
          followtags = true;
        };

        diff = {
          algorithm = "histogram";
          colorMoved = "default";
          submodule = "log";
        };
        help.autocorrect = "prompt";

        #log.date = "iso";
        branch.sort = "-committerdate";
        tag.sort = "taggerdate";

        # better submodule logs
        status.submoduleSummary = true;

        # avoid data corruption
        transfer.fsckobjects = true;
        fetch = {
          prune = true;
          prunetags = true;
          fsckobjects = true;
        };
        receive.fsckObjects = true;

        gpg.format = "openpgp";
      };

      ignores = [
        ".env"
        ".DS_Store"
        ".cursor"
        ".vscode"
        ".idea"
      ];

      hooks = { };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
