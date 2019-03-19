{ emacsPackagesNgGen, emacsMacport, emacs26, runCommand, stdenv }:

let
  emacs = if stdenv.isDarwin then emacsMacport else emacs26;
  inherit (emacsPackagesNgGen emacs) emacsWithPackages;
in emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
  (runCommand "site-lisp" {} ''
    mkdir -p $out/share/emacs/site-lisp
    cp ${./default.el} $_/default.el
  '')
  magit
  evil
  powerline
  nix-mode
] ++ (with epkgs.melpaPackages; [
  oceanic-theme
])))
