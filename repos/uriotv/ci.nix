# One policy for all package exports: build everything supported; publish only
# explicitly redistributable packages. preferLocalBuild is a scheduling hint,
# not a build exclusion or a redistribution restriction.
{
  pkgs ? import <nixpkgs> { config.allowUnfree = true; },
  packages ? import ./pkgs { inherit pkgs; },
}:
let
  policy = import ./lib/ci-policy.nix;
  supported = p: pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform p;
  buildable = p: supported p && !(p.meta.broken or false);
  cacheable = p: buildable p && policy.redistributable (p.meta.license or [ ]);
  outputsOf = p: map (name: p.${name}) p.outputs;
  buildPackages = pkgs.lib.filterAttrs (_: buildable) packages;
  cachePackages = pkgs.lib.filterAttrs (_: cacheable) packages;
in
rec {
  inherit packages buildPackages cachePackages;
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
      else if !policy.redistributable (p.meta.license or [ ]) then
        "license does not explicitly permit redistribution"
      else
        "redistributable license";
    outputs = if buildable p then map (o: toString o) (outputsOf p) else [ ];
  }) packages;
}
