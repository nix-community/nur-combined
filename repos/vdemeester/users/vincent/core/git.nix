{ config, lib, pkgs, ... }:
let
  ca-bundle_crt = "/etc/ssl/certs/ca-bundle.crt";
in
{
  home.packages = with pkgs; [
    gist
    git-lfs
    gitAndTools.git-annex
    gitAndTools.hub
    gitAndTools.gh
    mr
    my.prm
    my.ape
  ];
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

    userName = "Vincent Demeester";
    userEmail = "vincent@sbr.pm";

    signing = {
      key = "6EB699A3";
      signByDefault = false;
    };

    aliases = {
      b = "branch --color -v";
      br = "branch";
      ci = "commit --signoff";
      co = "checkout";
      conflicts = "!git ls-files --unmerged | cut -c51- | sort -u | xargs $EDITOR";
      ca = "commit --amend";
      wdiff = "diff --color-words";
      unstage = "reset HEAD";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
      lga = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative --branches --remotes";
      lol = "log --pretty=oneline --abbrev-commit --graph --decorate";
      ls-ignored = "ls-files --exclude-standard --ignored --others";
      resolve = "!git ls-files --unmerged | cut -c51- | sort -u | xargs git add";
      su = "submodule update --init --recursive";
      st = "status";
      w = "status -sb";
    };
    attributes = [
      "*.org   diff=org"
    ];
    extraConfig = {
      core = {
        editor = "${pkgs.emacs}/bin/emacsclient -t";
      };
      color = {
        status = "auto";
        diff = "auto";
        branch = "auto";
        interactive = "auto";
        ui = "auto";
        sh = "auto";
      };
      "color.branch" = {
        current = "cyan reverse";
        local = "cyan";
        remote = "green";
      };
      "color.diff" = {
        current = "white reverse";
        frag = "magenta reverse";
        old = "red";
        new = "green";
      };
      "color.status" = {
        added = "green";
        changed = "yellow";
        untracked = "red";
      };
      "diff.org" = {
        xfuncname = "\"^\\\\*+.*\"";
      };
      forge = {
        remote = "upstream";
      };
      hub = {
        protocol = true;
      };
      pull = {
        rebase = true;
      };
      push = {
        default = "upstream";
        recurseSubmodules = "check";
      };
      rebase = {
        autosquash = true;
      };
      advice = {
        statusHints = false;
        pushNonFastForward = false;
      };
      http = {
        sslCAinfo = "${ca-bundle_crt}";
        sslverify = true;
      };
      github.user = "vdemeester";
      "filter \"lfs\"" = {
        clean = "${pkgs.git-lfs}/bin/git-lfs clean -- %f";
        smudge = "${pkgs.git-lfs}/bin/git-lfs smudge --skip -- %f";
        required = true;
      };
      "url \"git@github.com:\"".insteadOf = "git://github.com/";
    };

    includes = [
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/github.com/kubernetes/";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/k8s.io/";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/github.com/knative/";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/github.com/tektoncd/";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir/i:${config.home.homeDirectory}/src/github.com/google**";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/k8s.io/";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/github.com/minishift/";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/github.com/operator-framework/";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/github.com/openshift**";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/github.com/redhat**";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/github.com/containers/";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/gitlab.cee.redhat.com/";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/gitlab.corp.redhat.com/";
      }
      {
        path = "${config.xdg.configHome}/git/config.d/redhat.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/src/pkg.devel.redhat.com/";
      }
    ];
    ignores = [
      "*.elc"
      "*.vo"
      "*.aux"
      "*.v.d"
      "*.o"
      "*.a"
      "*.la"
      "*.so"
      "*.dylib"
      "*.pyc"
      "*.pyo"
      ".idea"
      "*.iml"
      "*~"
      "#*#"
      ".makefile"
      ".clean"
    ];
  };
  xdg.configFile."git/config.d/redhat.gitconfig".source = ./git/redhat.gitconfig;
  xdg.configFile."nr/git" = {
    text = builtins.toJSON [
      { cmd = "tig"; }
      { cmd = "grv"; pkg = "gitAndTools.grv"; }
      { cmd = "git-appraise"; pkg = "gitAndTools.git-appraise"; chan = "unstable"; }
    ];
    onChange = "${pkgs.my.nr}/bin/nr git";
  };
}
