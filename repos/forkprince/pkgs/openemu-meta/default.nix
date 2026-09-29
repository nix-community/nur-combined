{
  openemu-silicon,
  stdenvNoCC,
  openemu,
}:
if stdenvNoCC.hostPlatform.isAarch64
then openemu-silicon
else openemu
