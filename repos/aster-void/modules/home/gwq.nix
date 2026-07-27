{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.gwq;
  gwqPackage = import ../../packages/gwq {inherit pkgs;};

  tomlFormat = pkgs.formats.toml {};

  # Submodule types matching upstream v0.0.5 pkg/models/models.go

  worktreeConfigType = lib.types.submodule {
    options = {
      basedir = lib.mkOption {
        type = lib.types.str;
        default = "~/worktrees";
        description = "Base directory for worktree creation.";
      };
      auto_mkdir = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically create directories.";
      };
    };
  };

  finderConfigType = lib.types.submodule {
    options = {
      preview = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable preview window.";
      };
    };
  };

  uiConfigType = lib.types.submodule {
    options = {
      icons = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable icon display.";
      };
      tilde_home = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Display home directory as tilde.";
      };
    };
  };

  namingConfigType = lib.types.submodule {
    options = {
      template = lib.mkOption {
        type = lib.types.str;
        default = "{{.Host}}/{{.Owner}}/{{.Repository}}/{{.Branch}}";
        description = "Directory naming template. Available variables: Host, Owner, Repository, Branch, Hash.";
      };
      sanitize_chars = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          "/" = "-";
          ":" = "-";
        };
        description = "Character substitution map for branch names.";
      };
    };
  };

  claudeQueueConfigType = lib.types.submodule {
    options = {
      queue_dir = lib.mkOption {
        type = lib.types.str;
        default = "~/.config/gwq/claude/queue";
        description = "Task queue directory.";
      };
    };
  };

  claudeWorktreeConfigType = lib.types.submodule {
    options = {
      auto_create_worktree = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically create worktree for tasks.";
      };
      require_existing_worktree = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Require an existing worktree.";
      };
      validate_branch_exists = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Validate that the branch exists.";
      };
    };
  };

  claudeExecutionConfigType = lib.types.submodule {
    options = {
      auto_cleanup = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically cleanup old logs.";
      };
    };
  };

  claudeConfigType = lib.types.submodule {
    options = {
      executable = lib.mkOption {
        type = lib.types.str;
        default = "claude";
        description = "Claude executable path.";
      };
      config_dir = lib.mkOption {
        type = lib.types.str;
        default = "~/.config/gwq/claude";
        description = "Configuration and state directory.";
      };
      max_parallel = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Maximum parallel execution instances.";
      };
      max_development_tasks = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = "Maximum development tasks.";
      };
      queue = lib.mkOption {
        type = claudeQueueConfigType;
        default = {};
        description = "Queue configuration.";
      };
      worktree = lib.mkOption {
        type = claudeWorktreeConfigType;
        default = {};
        description = "Worktree configuration for Claude tasks.";
      };
      execution = lib.mkOption {
        type = claudeExecutionConfigType;
        default = {};
        description = "Execution configuration.";
      };
    };
  };

  settingsType = lib.types.submodule {
    options = {
      worktree = lib.mkOption {
        type = worktreeConfigType;
        default = {};
        description = "Worktree configuration.";
      };
      finder = lib.mkOption {
        type = finderConfigType;
        default = {};
        description = "Finder configuration.";
      };
      ui = lib.mkOption {
        type = uiConfigType;
        default = {};
        description = "UI configuration.";
      };
      naming = lib.mkOption {
        type = namingConfigType;
        default = {};
        description = "Naming configuration.";
      };
      claude = lib.mkOption {
        type = claudeConfigType;
        default = {};
        description = "Claude Code integration configuration.";
      };
    };
  };
in {
  _class = "homeManager";

  options.programs.gwq = {
    enable = lib.mkEnableOption "gwq Git worktree manager";

    package = lib.mkOption {
      type = lib.types.package;
      default = gwqPackage;
      description = "The gwq package to use";
    };

    settings = lib.mkOption {
      type = settingsType;
      default = {};
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/gwq/config.toml`.
        See <https://github.com/d-kuro/gwq> for supported values.
      '';
      example = lib.literalExpression ''
        {
          worktree = {
            basedir = "~/worktrees";
            auto_mkdir = true;
          };
          finder = {
            preview = true;
          };
          naming = {
            template = "{{.Host}}/{{.Owner}}/{{.Repository}}/{{.Branch}}";
            sanitize_chars = {
              "/" = "-";
              ":" = "-";
            };
          };
          ui = {
            icons = true;
            tilde_home = true;
          };
          claude = {
            executable = "claude";
            max_parallel = 3;
            max_development_tasks = 2;
            config_dir = "~/.config/gwq/claude";
            queue = {
              queue_dir = "~/.config/gwq/claude/queue";
            };
            worktree = {
              auto_create_worktree = true;
              require_existing_worktree = false;
              validate_branch_exists = true;
            };
            execution = {
              auto_cleanup = true;
            };
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."gwq/config.toml" = lib.mkIf (cfg.settings != {}) {
      source = tomlFormat.generate "gwq-config.toml" cfg.settings;
    };
  };
}
