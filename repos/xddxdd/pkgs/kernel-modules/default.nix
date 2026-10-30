{
  loadPackages,
  ...
}:
let
  packages = loadPackages ./. { };
in
packages
// {
  gpu-unlock-firmware = packages.gpu-unlock.firmware;
}
