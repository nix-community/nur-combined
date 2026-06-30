{
  sniffnet,
}:

sniffnet.overrideAttrs (oldAttrs: {
  pname = "sniffnet-patched";

  patches = (oldAttrs.patches or [ ]) ++ [
    ../../patches/sniffnet-no-animations.patch
  ];
})
