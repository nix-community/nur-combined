{ pkgs }: {
    color = pkgs.callPackage ./color.nix {};
    columns = pkgs.callPackage ./columns.nix {};
    comment = pkgs.callPackage ./comment.nix {};
    ditaa = pkgs.callPackage ./ditaa.nix {};
    edittable = pkgs.callPackage ./edittable.nix {};
    graphviz = pkgs.callPackage ./graphviz.nix {};
    mathjax = pkgs.callPackage ./mathjax.nix {};
    move = pkgs.callPackage ./move.nix {};
    note = pkgs.callPackage ./note.nix {};
    wrap = pkgs.callPackage ./wrap.nix {};
    blockquote = pkgs.callPackage ./blockquote.nix {};
}
