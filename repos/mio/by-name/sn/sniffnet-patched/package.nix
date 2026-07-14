{
  sniffnet,
}:

sniffnet.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    ./sniffnet-no-animations.patch
  ];
})
