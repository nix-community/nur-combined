{
  buildLinux,
  fetchFromGitLab,
  lib,
#v nixpkgs calls `.override` on the kernel to configure additional things
  features ? {},
  kernelPatches ? null,
  randstructSeed ? "",
  structuredExtraConfig ? {},
  ...
}:
buildLinux ({
  src = fetchFromGitLab {
    owner = "exynos5-mainline";
    repo = "linux";
    rev = "20e7d0fbd9213858325dfeb9be0da1a3756744a1";
    hash = "sha256-tbNYuOk4XHRH12B3EdMCgO7EUKaAs6Q7G+/r3r35ZFY=";
  };
  version = "6.8.0-rc2";
  # modDirVersion = "6.8.0-rc2";
  modDirVersion = "6.8.0-rc2-next-20240201-postmarketos-exynos5";
  extraMeta.branch = "6.8";

  defconfig = "exynos5_defconfig";
  autoModules = false;
  # preferBuiltin = false;

  inherit features randstructSeed structuredExtraConfig;
} // lib.optionalAttrs (builtins.isList kernelPatches) {
  # callPackage mucks with `kernelPatches`: only forward this argument if it's a list,
  # as expected by `buildLinux`
  inherit kernelPatches;
})
