{ allInputs, mkCommon, vacuRoot, ... }:
{
  perSystem = { system, ... }:
  let
    mkNixvim =
      { unstable, minimal }:
      let
        common = mkCommon {
          inherit unstable system;
          vacuModuleType = "nixvim";
        };
        nixvim-input = if unstable then allInputs.nixvim-unstable else allInputs.nixvim;
      in
      nixvim-input.legacyPackages.${system}.makeNixvimWithModule {
        module =  /${vacuRoot}/nixvim;
        extraSpecialArgs = common.specialArgs // {
          inherit minimal;
        };
      };
  in
  {
    packages = {
      nixvim = mkNixvim {
        unstable = false;
        minimal = false;
      };
      nixvim-unstable = mkNixvim {
        unstable = true;
        minimal = false;
      };
      nixvim-minimal = mkNixvim {
        unstable = false;
        minimal = true;
      };
      nixvim-unstable-minimal = mkNixvim {
        unstable = true;
        minimal = true;
      };
    };
  };
}
