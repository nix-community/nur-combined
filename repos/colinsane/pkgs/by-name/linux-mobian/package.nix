# for now, export just the patches;
# i can write a kernel package later if they prove to be good.
{
  callPackage
}: {
  patches = callPackage ./patches.nix { };
}
