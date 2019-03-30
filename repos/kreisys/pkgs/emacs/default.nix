{ emacsPackagesNgGen, emacs26, runCommand, stdenv, ncurses }:

let
  xterm-24bit = runCommand "xterm-24bit" {
    buildInputs = [ ncurses ];
  } "tic -x -o $out ${./xterm-24bit.terminfo}";

  emacs = emacs26.override {
    # I live in terminal spare me the macOS gui garbage.
    withNS = false;
    # Assertion fails without this 🤷‍♀️
    withX = true;
  };

  inherit (emacsPackagesNgGen emacs) emacsWithPackages;

  emacs' = emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
    (runCommand "site-lisp" {} ''
      mkdir -p $out/share/emacs/site-lisp
      cp ${./default.el} $_/default.el
    '')
    (runCommand "term-cursor" {} ''
      mkdir -p $out/share/emacs/site-lisp
      cp ${./term-cursor.el} $_/term-cursor.el
    '')
    magit
    evil
    powerline
    nix-mode
    evil-leader
    evil-surround
    evil-nerd-commenter
  ] ++ (with epkgs.melpaPackages; [
    oceanic-theme
  ])));

  emacs'' = runCommand "emacs" {} ''
    cp -a ${emacs'} $out
    cd $out/bin

    chmod +w .

    for f in emacs{,client}; do
      chmod +w $f
      (head -n1 $f ; printf "export LANG=en_CA.UTF-8\nexport TERMINFO_DIRS=${xterm-24bit}\nexport TERM=xterm-24bit\n" ; tail -n+2 $f) > $f.fixed
      mv $f.fixed $f
      chmod +x $f
    done
  '';
in emacs''
