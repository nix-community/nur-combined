{
  lib,
  allInputs,
  mkCommon,
  vacuRoot,
  ...
}:
let
  variables = {
    unstable = [
      false
      true
    ];
    minimal = [
      false
      true
    ];
  };
  nixvimName =
    { unstable, minimal }:
    "nixvim" + (lib.optionalString unstable "-unstable") + (lib.optionalString minimal "-minimal");
in
{
  perSystem =
    { system, ... }:
    let
      mkNixvim =
        { unstable, minimal }:
        let
          common = mkCommon {
            inherit unstable system;
            vacuModuleType = "nixvim";
          };
          nixvim-input = if unstable then allInputs.nixvim-unstable else allInputs.nixvim;
          nixvim-eval = nixvim-input.lib.evalNixvim {
            modules = [
              /${vacuRoot}/nixvim
              { nixpkgs.source = common.pkgs.path; }
            ];
            extraSpecialArgs = common.specialArgs // {
              inherit (common) pkgs;
              inherit minimal;
            };
          };
        in
        nixvim-eval.config.build.package // { inherit (nixvim-eval) config; };
    in
    {
      vacuBuildDerivations = lib.pipe variables [
        (lib.mapCartesianProduct (attrs: lib.nameValuePair (nixvimName attrs) (mkNixvim attrs)))
        builtins.listToAttrs
      ];
    };
  vacuBuilds = lib.mkMerge [
    (lib.pipe variables [
      (lib.mapCartesianProduct nixvimName)
      (map (name: lib.nameValuePair name { putInPackages = true; }))
      builtins.listToAttrs
    ])
    { nixvim.aliases = [ "nvim" ]; }
  ];
}
