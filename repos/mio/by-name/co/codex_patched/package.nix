{
  codex,
}:

codex.overrideAttrs (_oldAttrs: {
  dontCargoUseSystemLibs = true;
})
