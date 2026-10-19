{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./wut/default.nix
  ];

  options.dots.git.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the git dotfiles module.";
  };

  config = lib.mkIf config.dots.git.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user = {
          name = "avycado13";
          email = "108358183+avycado13@users.noreply.github.com";
          signingkey = "680098B290681E1D28F555A90F7A57CF72410272";
        };

        alias = {
          st = "status";
          amend = "commit -a --amend";
          bmerged = "!f() { DEFAULT=$(git default); git branch --merged \${1-DEFAULT} | grep -v \"\${1-DEFAULT}$\" | xargs -r git branch -d; }; f";
          brebased = "!f() { DEFAULT=$(git default); for b in $(git branch --format=\"%(refname:short)\" | grep -vE \"(\${1-DEFAULT}|$DEFAULT)\"); do if [ -z \"$(git cherry \${1-\$DEFAULT} $b | grep \"^+\")\" ]; then git branch -D $b; fi; done; }; f";
          bdone = "!f() { DEFAULT=$(git default); git switch \${1-$DEFAULT} && git up && git brebased \${1-$DEFAULT}; }; f";
          co = "checkout";
          clog = "log --pretty=%C(yellow)%s%n%Creset%n%b%n---";
          ddfind = "log --decorate --stat --date=iso --format=fuller --patch --grep";
          ddlog = "log --decorate --stat --date=iso --format=fuller -p";
          default = " !git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'";
          dfind = "log --decorate --stat --date=iso --format=fuller --name-status --grep";
          files = "diff --name-only";
          di = "diff --color-words";
          dic = "diff --color-words=.";
          dlog = "log --decorate --stat --date=iso --format=fuller";
          ec = " config --global -e";
          find = "log --pretty=\"format:%Cgreen%H %Cblue%s\" --name-status --grep";
          flog = "log --pretty=fixes";
          format-patch-repo = "!git format-patch --subject-prefix=\'PATCH $(basename $(git rev-parse --show-toplevel))\'";
          glog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%aN>%Creset'";
          hist = "log --follow -p";
          pf = "push --force-with-lease";
          plog = "log -1 --pretty=%B";
          rba = "!f() { DEFAULT=$(git default); git rebase -i --autosquash \${1-\$DEFAULT}; }; f";
          save = "!git add -A && git commit -m 'SAVEPOINT'";
          sba = "!f() { git subtree add --prefix $1 $2 master --squash; }; f";
          sbp = "!f() { git subtree push --prefix $1 $2 $3; }; f";
          sbu = "!f() { git subtree pull --prefix $1 $2 master --squash; }; f";
          sc = "switch -c";
          send-email-repo = "!git send-email --subject-prefix=\'PATCH $(basename $(git rev-parse --show-toplevel))\'";
          slog = "shortlog -e --no-merges";
          tlog = "tag --sort=-v:refname -l --format='%(color:red)%(refname:strip=2)%(color:reset) - %(color:yellow)%(contents:subject)%(color:reset) by %(taggername) on %(taggerdate:human)\n\n%(contents:body)'";
          undo = "reset HEAD~1 --mixed";
          up = "!f() { git pull --rebase --prune $@ && git submodule update --init --recursive; }; f";
          wip = "!git add -u && git commit -m 'WIP'";
          wipe = " !git add -A && git commit -qm 'WIPE SAVEPOINT' && git reset HEAD~1 --hard";
          wt = "worktree";
        };

        color.ui = "auto";
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = false;
        url."git@github.com:".insteadOf = "https://github.com/";
        diff."sqlite3" = {
          binary = true;
          textconv = "echo .dump | sqlite3";
        };
        transfer.fsckobjects = false;
        fetch.fsckobjects = false;
        receive.fsckObjects = false;

        fsck.zeroPaddedFilemode = "ignore";
        fetch.fsck.zeroPaddedFilemode = "ignore";
        transfer.fsck.zeroPaddedFilemode = "ignore";
        receive.fsck.zeroPaddedFilemode = "ignore";
        commit.gpgsign = true;
        tag.gpgsign = true;
      };
      signing.format = "openpgp";
    };
    programs.gh = {
      enable = true;
      package = pkgs.gh;
      settings = {
        git_protocol = "ssh";

        prompt = "enabled";
        editor = "$EDITOR";

        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
      extensions = [
        pkgs.gh-stack
        pkgs.gh-markdown-preview
        pkgs.gh-skyline
      ];
    };
    programs.gh-dash = {
      enable = false;
      settings = {
        prSections = [
          {
            title = "My PRs";
            filters = "is:open author:@me";
          }
          {
            title = "Needs Review";
            filters = "is:open review-requested:@me";
          }
        ];
        issuesSections = [
          {
            title = "My Issues";
            filters = "is:open author:@me";
          }
        ];
      };
    };
    programs.lazygit = {
      enable = true;
      package = pkgs.lazygit;
      enableZshIntegration = true;
    };
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };
    home.packages = with pkgs; [
      git-extras
      mob
      (pkgs.writeShellScriptBin "git-select-branch" ''
        if [ -d "./.git" ]; then
          git fetch
          selected_remote_branch=$(git branch -r | ${pkgs.fzf}/bin/fzf | sed -e 's/^[[:space:]]*//')
          if [ -n "$selected_remote_branch" ]; then
            selected_branch=$(echo "$selected_remote_branch" | sed -e 's/origin\///');
            if git rev-parse --verify "$selected_branch" >/dev/null 2>&1; then
              git checkout "$selected_branch"
            else
              git checkout --track "$selected_remote_branch"
            fi
          else
            echo "Exit: You haven't selected a branch..."
          fi
        else
          echo "Error: There's no .git dir..."
          exit 1
        fi
      '')
    ];
    programs.zsh.shellAliases = {
      # FIXME turn these on after testing forgit
      grt = ''cd "$(git rev-parse --show-toplevel || echo .)"'';
      ggpur = "ggu";
      g = "git";
      gst = "git status";
      ga = "git add";
      gaa = "git add --all";
      gapa = "git add --patch";
      gwip = ''git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'';
      gam = "git am";
      gama = "git am --abort";
      gamc = "git am --continue";
      gamscp = "git am --show-current-patch";
      gams = "git am --skip";
      gap = "git apply";
      gapt = "git apply --3way";
      gbs = "git bisect";
      gbsb = "git bisect bad";
      gbsg = "git bisect good";
      gbsn = "git bisect new";
      gbso = "git bisect old";
      gbsr = "git bisect reset";
      gbss = "git bisect start";
      gbl = "git blame -w";
      gb = "git branch";
      gba = "git branch --all";
      gbd = "git branch --delete";
      gbD = "git branch --delete --force";
      gbm = "git branch --move";
      gbnm = "git branch --no-merged";
      gbr = "git branch --remote";
      gbg = ''LANG=C git branch -vv | grep ": gone]"'';
      gco = "git checkout";
      gcor = "git checkout --recurse-submodules";
      gcb = "git checkout -b";
      gcB = "git checkout -B";
      gcp = "git cherry-pick";
      gcpa = "git cherry-pick --abort";
      gcpc = "git cherry-pick --continue";
      gclean = "git clean --interactive -d";
      gcl = "git clone --recurse-submodules";
      gclf = "git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules";
      gcam = "git commit --all --message";
      gcas = "git commit --all --signoff";
      gcasm = "git commit --all --signoff --message";
      gcs = "git commit --gpg-sign";
      gcss = "git commit --gpg-sign --signoff";
      gcssm = "git commit --gpg-sign --signoff --message";
      gcmsg = "git commit --message";
      gcsm = "git commit --signoff --message";
      gc = "git commit --verbose";
      gca = "git commit --verbose --all";
      "gca!" = "git commit --verbose --all --amend";
      "gcan!" = "git commit --verbose --all --no-edit --amend";
      "gcans!" = "git commit --verbose --all --signoff --no-edit --amend";
      "gcann!" = "git commit --verbose --all --date=now --no-edit --amend";
      "gc!" = "git commit --verbose --amend";
      gcn = "git commit --verbose --no-edit";
      "gcn!" = "git commit --verbose --no-edit --amend";
      gcf = "git config --list";
      gd = "git diff";
      gdw = "git diff --word-diff";
      gf = "git fetch";
      gg = "git gui citool";
      glgg = "git log --graph";
      glgga = "git log --graph --decorate --all";
      glgm = "git log --graph --max-count=10";
      glog = "git log --oneline --decorate --graph";
      gloga = "git log --oneline --decorate --graph --all";
      glg = "git log --stat";
      glgp = "git log --stat --patch";
      gignored = ''git ls-files -v | grep "^[[:lower:]]"'';
      gfg = "git ls-files | grep";
      gm = "git merge";
      gma = "git merge --abort";
      gmc = "git merge --continue";
      gms = "git merge --squash";
      gmff = "git merge --ff-only";
      gmtl = "git mergetool --no-prompt";
      gmtlvim = "git mergetool --no-prompt --tool=vimdiff";
      gl = "git pull";
      gpr = "git pull --rebase";
      gp = "git push";
      "gpf!" = "git push --force";
      gpoat = "git push origin --all && git push origin --tags";
      grb = "git rebase";
      grba = "git rebase --abort";
      grbc = "git rebase --continue";
      grbi = "git rebase --interactive";
      grbo = "git rebase --onto";
      grbs = "git rebase --skip";
      gr = "git remote";
      grv = "git remote --verbose";
      gra = "git remote add";
      grrm = "git remote remove";
      grmv = "git remote rename";
      grset = "git remote set-url";
      grup = "git remote update";
      grh = "git reset";
      gru = "git reset --";
      grhh = "git reset --hard";
      grhk = "git reset --keep";
      grhs = "git reset --soft";
      gwipe = "git reset --hard && git clean --force -df";
      grs = "git restore";
      grss = "git restore --source";
      grst = "git restore --staged";
      grev = "git revert";
      greva = "git revert --abort";
      grevc = "git revert --continue";
      grm = "git rm";
      grmc = "git rm --cached";
      gcount = "git shortlog --summary -n";
      gsh = "git show";
      gsps = "git show --pretty=short --show-signature";
      gstall = "git stash --all";
      gstu = "git stash --include-untracked";
      gstaa = "git stash apply";
      gstc = "git stash clear";
      gstd = "git stash drop";
      gstl = "git stash list";
      gstp = "git stash pop";
    };
    programs.bash.shellAliases = {
      grt = ''cd "$(git rev-parse --show-toplevel || echo .)"'';
      ggpur = "ggu";
      g = "git";
      gst = "git status";
      ga = "git add";
      gaa = "git add --all";
      gapa = "git add --patch";
      gau = "git add --update";
      gav = "git add --verbose";
      gwip = ''git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'';
      gam = "git am";
      gama = "git am --abort";
      gamc = "git am --continue";
      gamscp = "git am --show-current-patch";
      gams = "git am --skip";
      gap = "git apply";
      gapt = "git apply --3way";
      gbs = "git bisect";
      gbsb = "git bisect bad";
      gbsg = "git bisect good";
      gbsn = "git bisect new";
      gbso = "git bisect old";
      gbsr = "git bisect reset";
      gbss = "git bisect start";
      gbl = "git blame -w";
      gb = "git branch";
      gba = "git branch --all";
      gbd = "git branch --delete";
      gbD = "git branch --delete --force";
      gbm = "git branch --move";
      gbnm = "git branch --no-merged";
      gbr = "git branch --remote";
      gbg = ''LANG=C git branch -vv | grep ": gone]"'';
      gco = "git checkout";
      gcor = "git checkout --recurse-submodules";
      gcb = "git checkout -b";
      gcB = "git checkout -B";
      gcp = "git cherry-pick";
      gcpa = "git cherry-pick --abort";
      gcpc = "git cherry-pick --continue";
      gclean = "git clean --interactive -d";
      gcl = "git clone --recurse-submodules";
      gclf = "git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules";
      gcam = "git commit --all --message";
      gcas = "git commit --all --signoff";
      gcasm = "git commit --all --signoff --message";
      gcs = "git commit --gpg-sign";
      gcss = "git commit --gpg-sign --signoff";
      gcssm = "git commit --gpg-sign --signoff --message";
      gcmsg = "git commit --message";
      gcsm = "git commit --signoff --message";
      gc = "git commit --verbose";
      gca = "git commit --verbose --all";
      "gca!" = "git commit --verbose --all --amend";
      "gcan!" = "git commit --verbose --all --no-edit --amend";
      "gcans!" = "git commit --verbose --all --signoff --no-edit --amend";
      "gcann!" = "git commit --verbose --all --date=now --no-edit --amend";
      "gc!" = "git commit --verbose --amend";
      gcn = "git commit --verbose --no-edit";
      "gcn!" = "git commit --verbose --no-edit --amend";
      gcf = "git config --list";
      gcfu = "git commit --fixup";
      gdct = "git describe --tags $(git rev-list --tags --max-count=1)";
      gd = "git diff";
      gdca = "git diff --cached";
      gdcw = "git diff --cached --word-diff";
      gds = "git diff --staged";
      gdw = "git diff --word-diff";
      gdup = "git diff @{upstream}";
      gdt = "git diff-tree --no-commit-id --name-only -r";
      gf = "git fetch";
      gfo = "git fetch origin";
      gg = "git gui citool";
      gga = "git gui citool --amend";
      ghh = "git help";
      glgg = "git log --graph";
      glgga = "git log --graph --decorate --all";
      glgm = "git log --graph --max-count=10";
      glod = ''git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'';
      glods = ''git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'';
      glol = ''git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'';
      glola = ''git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'';
      glols = ''git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'';
      glo = "git log --oneline --decorate";
      glog = "git log --oneline --decorate --graph";
      gloga = "git log --oneline --decorate --graph --all";
      glg = "git log --stat";
      glgp = "git log --stat --patch";
      gignored = ''git ls-files -v | grep "^[[:lower:]]"'';
      gfg = "git ls-files | grep";
      gm = "git merge";
      gma = "git merge --abort";
      gmc = "git merge --continue";
      gms = "git merge --squash";
      gmff = "git merge --ff-only";
      gmtl = "git mergetool --no-prompt";
      gmtlvim = "git mergetool --no-prompt --tool=vimdiff";
      gl = "git pull";
      gpr = "git pull --rebase";
      gprv = "git pull --rebase -v";
      gpra = "git pull --rebase --autostash";
      gprav = "git pull --rebase --autostash -v";
      gprom = "git pull --rebase origin $(git_main_branch)";
      gpromi = "git pull --rebase=interactive origin $(git_main_branch)";
      gprum = "git pull --rebase upstream $(git_main_branch)";
      gprumi = "git pull --rebase=interactive upstream $(git_main_branch)";
      ggpull = ''git pull origin "$(git_current_branch)"'';
      gluc = "git pull upstream $(git_current_branch)";
      glum = "git pull upstream $(git_main_branch)";
      gp = "git push";
      gpd = "git push --dry-run";
      "gpf!" = "git push --force";
      gpf = "git push --force-with-lease";
      ggfl = "git push --force-with-lease origin $(git_current_branch)";
      gpsup = "git push --set-upstream origin $(git_current_branch)";
      gpsupf = "git push --set-upstream origin $(git_current_branch) --force-with-lease";
      gpv = "git push --verbose";
      gpoat = "git push origin --all && git push origin --tags";
      gpod = "git push origin --delete";
      ggpush = ''git push origin "$(git_current_branch)"'';
      gpu = "git push upstream";
      grb = "git rebase";
      grba = "git rebase --abort";
      grbc = "git rebase --continue";
      grbi = "git rebase --interactive";
      grbo = "git rebase --onto";
      grbs = "git rebase --skip";
      grf = "git reflog";
      gr = "git remote";
      grv = "git remote --verbose";
      gra = "git remote add";
      grrm = "git remote remove";
      grmv = "git remote rename";
      grset = "git remote set-url";
      grup = "git remote update";
      grh = "git reset";
      gru = "git reset --";
      grhh = "git reset --hard";
      grhk = "git reset --keep";
      grhs = "git reset --soft";
      gpristine = "git reset --hard && git clean --force -dfx";
      gwipe = "git reset --hard && git clean --force -df";
      grs = "git restore";
      grss = "git restore --source";
      grst = "git restore --staged";
      grev = "git revert";
      greva = "git revert --abort";
      grevc = "git revert --continue";
      grm = "git rm";
      grmc = "git rm --cached";
      gcount = "git shortlog --summary -n";
      gsh = "git show";
      gsps = "git show --pretty=short --show-signature";
      gstall = "git stash --all";
      gstu = "git stash --include-untracked";
      gstaa = "git stash apply";
      gstc = "git stash clear";
      gstd = "git stash drop";
      gstl = "git stash list";
      gstp = "git stash pop";
    };
  };
}
