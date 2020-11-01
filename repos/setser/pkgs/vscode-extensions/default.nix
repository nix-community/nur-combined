{ pkgs }:
{
    kahole.magit = pkgs.callPackage ./magit { };
    Rubymaniac.vscode-direnv = pkgs.callPackage ./vscode-direnv { };
    rust-lang.rust = pkgs.callPackage ./rust { };
    sjhuangx.vscode-scheme = pkgs.callPackage ./vscode-scheme { };
    tuttieee.emacs-mcx = pkgs.callPackage ./emacs-mcx { };
    vscode-org-mode.org-mode = pkgs.callPackage ./org-mode { };
}