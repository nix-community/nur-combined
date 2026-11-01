{
  delta,
  difftastic,
  git,
  static-nix-shell,
  symlinkJoin,
}:
let
  git-cherry-pick = static-nix-shell.mkBash {
    pname = "git-cherry-pick";
    srcRoot = ./.;
    packages = {
      inherit git;
    };
  };
  git-pr = static-nix-shell.mkBash {
    pname = "git-pr";
    srcRoot = ./.;
    packages = {
      inherit git;
    };
  };
  git-pshow = static-nix-shell.mkBash {
    pname = "git-pshow";
    srcRoot = ./.;
    packages = {
      inherit
        delta
        difftastic
        git
        ;
    };
  };
  git-work = static-nix-shell.mkBash {
    pname = "git-work";
    srcRoot = ./.;
    packages = {
      inherit git;
    };
  };
in
symlinkJoin {
  name = "git-sane";
  paths = [
    git-cherry-pick
    git-pr
    git-pshow
    git-work
  ];
}
