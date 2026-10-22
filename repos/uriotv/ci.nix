# One policy for all package exports: build everything supported; publish only
# explicitly redistributable packages. preferLocalBuild is a scheduling hint,
# not a build exclusion or a redistribution restriction.
# Exception: meta.ciBuild = false marks a package built out of band by its own
# workflow (currently the CachyOS kernel, on the self-hosted builder). It is then
# neither built in tests nor published by build.yml, and it does not block test-gate.
{
  pkgs ? import <nixpkgs> { config.allowUnfree = true; },
  packages ? import ./pkgs { inherit pkgs; },
}:
let
  policy = import ./lib/ci-policy.nix;
  supported = p: pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform p;
  buildable = p: supported p && !(p.meta.broken or false) && (p.meta.ciBuild or true);
  cacheable = p: buildable p && policy.redistributable (p.meta.license or [ ]);
  outputsOf = p: map (name: p.${name}) p.outputs;
  buildPackages = pkgs.lib.filterAttrs (_: buildable) packages;
  cachePackages = pkgs.lib.filterAttrs (_: cacheable) packages;
in
rec {
  inherit packages buildPackages cachePackages;
  # Evaluation only: cache identity and real NixOS kernel override regression.
  kernelTests = import ./tests/cachyos-eval.nix { inherit pkgs packages; };
  kernelLicenseManifests = pkgs.lib.genAttrs [
    "linux-cachyos-latest-x86_64-v3"
    "linux-cachyos-bore-x86_64-v3"
  ] (name: import ./lib/cachyos/license-manifest.nix { inherit pkgs; kernel = packages.${name}; });
  # Legacy entry points remain available, but are no longer conflated in CI.
  buildPkgs = builtins.attrValues buildPackages;
  cachePkgs = builtins.attrValues cachePackages;
  buildOutputs = builtins.concatMap outputsOf buildPkgs;
  cacheOutputs = builtins.concatMap outputsOf cachePkgs;
  manifest = pkgs.lib.mapAttrsToList (name: p: {
    inherit name;
    version = p.version or "unknown";
    buildable = buildable p;
    cacheable = cacheable p;
    reason =
      if !(supported p) then
        "unsupported platform"
      else if p.meta.broken or false then
        "marked broken"
      else if !(p.meta.ciBuild or true) then
        "built out of band (meta.ciBuild = false)"
      else if !policy.redistributable (p.meta.license or [ ]) then
        "license does not explicitly permit redistribution"
      else
        "redistributable license";
    outputs = if buildable p then map (o: toString o) (outputsOf p) else [ ];
  }) packages;
}
