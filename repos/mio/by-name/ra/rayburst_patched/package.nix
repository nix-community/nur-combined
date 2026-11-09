{
  rayburst,
}:

rayburst.overrideAttrs (_oldAttrs: {
  dontCargoUseSystemLibs = true;
})
