{
  lib,
  makeSetupHook,
  esbuild,
  nodejs,
}:

makeSetupHook {
  name = "pi-bundle-hook";
  propagatedBuildInputs = [
    esbuild
    nodejs
  ];
  substitutions = {
    nodeMajor = lib.versions.major nodejs.version;
    bundleScript = ./pi-bundle-hook.mjs;
  };
} ./pi-bundle-hook.sh
