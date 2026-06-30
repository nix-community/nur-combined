{
  sniffnet,
}:

sniffnet.overrideAttrs (oldAttrs: {
  pname = "sniffnet-patched";

  patches = (oldAttrs.patches or [ ]) ++ [
    ./sniffnet-no-animations.patch
  ];
})
