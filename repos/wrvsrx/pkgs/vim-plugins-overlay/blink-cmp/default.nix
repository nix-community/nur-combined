{
  blink-cmp,
  fetchpatch,
}:
blink-cmp.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/blink.cmp/commit/6115aaf11710ba9c6ebf552fdea18d4bdbd6f9c1.patch";
      hash = "sha256-nDkcWdHYUVYhPB+h69N40MWXlfQjxspN553otoyhIGM=";
    })
    # Backport to 1.10.2: keep cached edits in the LSP client's position encoding.
    # https://github.com/saghen/blink.cmp/pull/2651
    (fetchpatch {
      url = "https://github.com/wrvsrx/blink.cmp/compare/v1.10.2+completion-encoding.1~1..v1.10.2+completion-encoding.1.diff";
      hash = "sha256-ST9WmClrGhjqht8EeUQSMV6FThxvwu2O6+sFC534sdQ=";
    })
  ];
})
