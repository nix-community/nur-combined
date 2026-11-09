{
  polarity,
}:

polarity.overrideAttrs (_oldAttrs: {
  dontCargoUseSystemLibs = true;
})
