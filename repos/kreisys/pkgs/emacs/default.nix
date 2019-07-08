{ emacsPackagesNgFor, emacsMacport, fetchpatch, runCommand, stdenv, ncurses, writeText }:

let
  xterm-24bit = runCommand "xterm-24bit" {
    buildInputs = [ ncurses ];
  } "tic -x -o $out ${./xterm-24bit.terminfo}";

  #emacs = (emacsPackagesNgFor emacsMacport).emacsWithPackages (_: []);

  patches = [
    (fetchpatch {
      name = "multi-tty.patch";
      url = https://bitbucket.org/ylluminarious/emacs-mac-multi-tty/commits/08874543cb806d0c2dc7b6b5c0f5f92836b7671a/raw;
      sha256 = "1qg0i5ap5nmrd13cxl3sbp2yhc0i88lbfqv6m5wggrzv8vzxvh50";
    })

    (fetchpatch {
      name = "natural-titlebar.patch";
      url = https://gist.github.com/lululau/f2e6314a14cc95586721272dd85a7c51/raw/f5a92d3e654cc41d0eab2b229a98ed63da82ee1c/emacs-mac-title-bar-7.4.patch;
      sha256 = "135ynj1ibxgf18x6njwgk25f8fyxsi7mbs2fcmfv2djgj5w81f2g";
    })
  ];

  emacsPkgs = _: [];

  emacs = let
    emacsMacportWithPatches = emacsMacport.overrideAttrs (o: {
      patches = o.patches ++ patches;
    });
    emacsMacportWithPkgs = (emacsPackagesNgFor emacsMacportWithPatches).emacsWithPackages emacsPkgs;
  in emacsMacportWithPkgs;

in emacs

#in runCommand emacs.name {
#  inherit (emacs) meta;
#} ''
#  cp -a ${emacs} $out

#  cd $out

#  chmod -R +w Applications
#  cp ${./Emacs.icns} $_/Emacs.app/Contents/Resources/Emacs.icns

#  cd bin

#  chmod +w .

#  for f in emacs{,client}; do
#    chmod +w $f
#    (head -n1 $f ; cat ${writeText "emacs-wrapper-patch" ''
#      export LANG=en_CA.UTF-8
#      export TERMINFO_DIRS=${xterm-24bit}
#      export TERM=xterm-24bit
#    ''} ; tail -n+2 $f) > $f.fixed
#    mv $f.fixed $f
#    chmod +x $f
#  done

#''
