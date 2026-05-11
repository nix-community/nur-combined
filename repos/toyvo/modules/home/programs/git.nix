{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.git;
in
{
  config = lib.mkIf cfg.enable {
    sops.secrets.opencode_api_key = { };
    sops.templates.opencommit.content = ''
      OCO_MODEL=kimi-k2.6
      OCO_API_URL=https://opencode.ai/zen/go/v1
      OCO_PROXY=undefined
      OCO_API_KEY=${config.sops.placeholder.opencode_api_key}
      OCO_API_CUSTOM_HEADERS=undefined
      OCO_AI_PROVIDER=openai
      OCO_TOKENS_MAX_INPUT=4096
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
    home.activation.opencommit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rm -f $HOME/.opencommit
      ln -s ${config.sops.templates.opencommit.path} $HOME/.opencommit
    '';

    home.packages = [ pkgs.opencommit ];
    catppuccin = {
      delta = {
        enable = true;
        flavor = config.catppuccin.flavor;
      };
      lazygit = {
        enable = true;
        flavor = config.catppuccin.flavor;
        accent = config.catppuccin.accent;
      };
    };
    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;
      };
      git = {
        lfs.enable = true;
        settings = {
          pull.rebase = "true";
          rebase.autostash = "true";
          core.editor = "nvim";
          core.eol = "lf";
          core.autocrlf = "input";
          gpg.format = "ssh";
          init.defaultBranch = "main";
          init.defaultRefFormat = "reftable";
          url."git@github.com:".pushInsteadOf = "https://github.com/";
          alias = {
            a = "add";
            aa = "add -A";
            b = "branch";
            ba = "branch -a";
            ac = "!oco";
            aca = "!git add -A && oco";
            c = "commit -m";
            ca = "commit -am";
            cam = "commit --amend --date=now";
            co = "checkout";
            cob = "checkout -b";
            sw = "switch";
            swc = "switch -c";
            s = "status -sb";
            po = "!git push -u origin $(git branch --show-current)";
            d = "diff";
            dc = "diff --cached";
            ignore = "update-index --assume-unchanged";
            unignore = "update-index --no-assume-unchanged";
            ignored = "!git ls-files -v | grep ^h | cut -c 3-";
            bare-clone = "!f() { if [ \"$#\" -ge 2 ]; then for d; do :; done; else d=\"$(echo \"$1\" | sed 's|.*[:/]||; s|[.]git$||').git\"; fi; git clone --bare \"$@\" && git -C \"$d\" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*' && git -C \"$d\" fetch; }; f";
            rbm = "!git fetch && git rebase origin/main";
            rbc = "-c core.editor=true rebase --continue";
          };
        };
      };
      lazygit.enable = true;
    };
  };
}
