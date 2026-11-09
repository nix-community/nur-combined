{
  sniffnet,
}:

sniffnet.overrideAttrs (oldAttrs: {
  dontCargoUseSystemLibs = true;
  patches = (oldAttrs.patches or [ ]) ++ [
    ./sniffnet-no-animations.patch
  ];
})
