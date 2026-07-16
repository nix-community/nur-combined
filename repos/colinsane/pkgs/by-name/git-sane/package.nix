{
  delta,
  difftastic,
  git,
  static-nix-shell,
  symlinkJoin,
}:
let
  git-pr = static-nix-shell.mkBash {
    pname = "git-pr";
    srcRoot = ./.;
    pkgs = {
      inherit git;
    };
  };
  git-pshow = static-nix-shell.mkBash {
    pname = "git-pshow";
    srcRoot = ./.;
    pkgs = {
      inherit
        delta
        difftastic
        git
        ;
    };
  };
in
symlinkJoin {
  name = "git-sane";
  paths = [
    git-pr
    git-pshow
  ];
}
