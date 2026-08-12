{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.home.git;
in {
  options.my.home.git.enable = (mkEnableOption "Git configuration") // {default = true;};

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;

      settings = {
        user = {
          name = "Antoine Martin";
          email = "antoine@alarsyo.net";
        };
        alias = {
          push-wip = "push -o ci.skip";
          push-merge = "push -o merge_request.create -o merge_request.merge_when_pipeline_succeeds -o merge_request.remove_source_branch";
          push-mr = "push -o merge_request.create -o merge_request.remove_source_branch";
        };
        commit = {verbose = true;};
        core = {editor = "vim";};
        init = {defaultBranch = "main";};
        pull = {rebase = true;};
        rerere = {enabled = true;};
        maintenance.prefetch.enabled = false;
      };

      includes = [
        {
          condition = "gitdir:~/work/lrde/";
          contents = {user = {email = "amartin@lrde.epita.fr";};};
        }
        {
          condition = "gitdir:~/work/prologin/";
          contents = {user = {email = "antoine.martin@prologin.org";};};
        }
        {
          condition = "gitdir:~/work/epita/";
          contents = {user = {email = "antoine4.martin@epita.fr";};};
        }
      ];

      ignores = [
        "/.direnv/"
        "/.envrc"
      ];
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        syntax-theme = "Solarized (light)";
      };
    };
  };
}
