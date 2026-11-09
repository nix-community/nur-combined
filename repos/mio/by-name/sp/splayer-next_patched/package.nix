{
  splayer-next,
}:

splayer-next.overrideAttrs (_oldAttrs: {
  dontCargoUseSystemLibs = true;
})
