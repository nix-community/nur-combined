{ emacsPackagesNgFor, emacsMacport, runCommand, ncurses, writeText }:

let
  xterm-24bit = runCommand "xterm-24bit" {
    buildInputs = [ ncurses ];
  } "tic -x -o $out ${./xterm-24bit.terminfo}";

  emacs = (emacsPackagesNgFor emacsMacport).emacsWithPackages (_: []);

in runCommand emacs.name {
  inherit (emacs) meta;
} ''
  cp -a ${emacs} $out

  cd $out

  chmod -R +w Applications
  cp ${./Emacs.icns} $_/Emacs.app/Contents/Resources/Emacs.icns

  cd bin

  chmod +w .

  for f in emacs{,client}; do
    chmod +w $f
    (head -n1 $f ; cat ${writeText "emacs-wrapper-patch" ''
      export LANG=en_CA.UTF-8
      export TERMINFO_DIRS=${xterm-24bit}
      export TERM=xterm-24bit
    ''} ; tail -n+2 $f) > $f.fixed
    mv $f.fixed $f
    chmod +x $f
  done

''
