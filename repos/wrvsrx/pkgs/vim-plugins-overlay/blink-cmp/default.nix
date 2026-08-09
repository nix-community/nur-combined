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
  ];
})
