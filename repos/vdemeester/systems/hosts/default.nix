inputs:

let
  inherit (inputs) self;

  sharedModules = [
    { _module.args = { inherit inputs; }; }
    #../modules/minimal.nix
    #../modules/security.nix
    inputs.home-manager.nixosModule
    {
      home-manager = {
        inherit (inputs.self.lib) extraSpecialArgs;
        useGlobalPkgs = true;
      };
    }
  ];

  inherit (self.lib) nixosSystem makeOverridable;
  # inherit (import "${self}/home/profiles" inputs) homeImports;
in
{
  # naruhodo
  naruhodo = nixosSystem {
    modules = [
      ./naruhodo.nix
    ] ++ sharedModules;
    system = "x86_64-linux";
  };
  # shikoku
  # aomi
  # wakasu
  # sakhalin
}
