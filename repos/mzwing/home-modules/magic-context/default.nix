{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.magic-context;
  jsonFormat = pkgs.formats.json {};

  localPackages = {
    magic-context = (import ../../internal/discover.nix {inherit (pkgs) lib;}).package {
      inherit pkgs;
      name = "magic-context";
    };
  };

  # Per-harness blocks, plus the flat form upstream still migrates.
  historian = cfg.settings.historian or {};
  historianConfigured =
    historian
    ? model
    || lib.any (harness: (historian.${harness} or {}) ? model) ["opencode" "pi"];
in {
  options.programs.magic-context = {
    enable = lib.mkEnableOption "Magic Context, self-managing context and cross-session memory for coding agents";

    package = lib.mkPackageOption localPackages "magic-context" {
      pkgsText = "inputs.nur.repos.mzwing";
      extraDescription = "It is added to `home.packages`. Register the plugin with your harness using `magic-context setup`; this module only manages the shared configuration file.";
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = {};
      example = lib.literalExpression ''
        {
          historian.opencode.model = "anthropic/claude-sonnet-4-6";
          dreamer.opencode.model = "anthropic/claude-haiku-4-5";
          memory.git_commit_indexing.enabled = true;
        }
      '';
      description = ''
        Schema-agnostic configuration rendered to
        `~/.config/cortexkit/magic-context.jsonc`, the shared CortexKit location
        every harness reads, with `$schema` filled in unless you set it
        yourself. The module neither enumerates nor validates Magic Context's
        own keys; see
        <https://github.com/cortexkit/magic-context/blob/master/CONFIGURATION.md>.
        The active harness's historian model
        (`historian.opencode.model` or `historian.pi.model`) is required for
        history compacting.

        The generated file is a read-only Nix store symlink, so the desktop
        app's config editor and `magic-context setup` cannot change it; change
        this option instead. When empty, no file is generated and Magic Context
        keeps its built-in defaults, including its migration of a config left at
        an older location.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    warnings = lib.optional (cfg.settings != {} && !historianConfigured) ''
      programs.magic-context.settings sets no historian model. Magic Context
      loads, but every historian run fails, older history is never summarized,
      and the harness eventually shows a "history comparting needs attention"
      notice. Set historian.opencode.model or historian.pi.model to a real
      provider/model-id.
    '';

    xdg.configFile = lib.mkIf (cfg.settings != {}) {
      "cortexkit/magic-context.jsonc".source =
        jsonFormat.generate "magic-context.jsonc"
        ({"$schema" = "https://raw.githubusercontent.com/cortexkit/magic-context/master/assets/magic-context.schema.json";} // cfg.settings);
    };
  };
}
