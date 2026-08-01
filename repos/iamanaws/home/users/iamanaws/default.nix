# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  config,
  hostConfig,
  pkgs,
  ...
}:

let
  # `outputs` can vary depending on who instantiates home-manager (NixOS module vs standalone HM),
  # so prefer `outputs.overlays` when present, otherwise import overlays from the flake tree.
  flakeOverlays =
    if outputs ? overlays then outputs.overlays else import ../../../overlays { inherit (inputs) nur; };
  llmAgentPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  disabledModules = [
    "programs/zed-editor.nix"
  ];

  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    ../../shared/modules/zed-editor.nix

    ./config
    ./graphical.nix
  ];

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      flakeOverlays.additions
      flakeOverlays.modifications

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  # Add environment variables
  home.sessionVariables = { };

  home.packages =
    with pkgs;
    [
      nixd
    ]
    ++ [ llmAgentPkgs.cursor-agent ];

  programs.mcp = {
    enable = config.programs.claude-code.enable || config.programs.codex.enable;
    servers = {
      cxf-docs.url = "https://docs.cxf.app/mcp";
    };
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.claude-code = {
    enable = hostConfig.isGraphical;
    enableMcpIntegration = true;
    package = llmAgentPkgs.claude-code.override {
      disableTelemetry = true;
    };
    settings = {
      includeCoAuthoredBy = false;
      model = "opus";
      effortLevel = "xhigh";
      permissions = {
        allow = [ ];
      };
    };
    skills = { };
  };

  programs.codex = {
    enable = config.programs.claude-code.enable;
    enableMcpIntegration = true;
    package = llmAgentPkgs.codex;
    settings = { };
    skills = { };
  };

  programs.git = {
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
      fetch.prune = true;
      fetch.prunetags = true;
      merge.conflictStyle = "zdiff3";
      push.autosetupremote = true;
      push.followtags = true;

      diff.algorithm = "histogram";
      diff.colorMoved = "default";
      help.autocorrect = "prompt";

      #log.date = "iso";
      branch.sort = "-committerdate";
      tag.sort = "taggerdate";

      # better submodule logs
      status.submoduleSummary = true;
      diff.submodule = "log";

      # avoid data corruption
      transfer.fsckobjects = true;
      fetch.fsckobjects = true;
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
