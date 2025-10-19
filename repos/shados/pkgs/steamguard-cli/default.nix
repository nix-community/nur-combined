{
  lib,
  naersk,
  pins,
}:
naersk.buildPackage {
  src = pins.steamguard-cli.outPath;
}
