{ self, inputs, ... }:
{
  flake = _:
    let
      lib = inputs.nixpkgs.lib;
      nixlib = lib;
      inherit (inputs) systems;
      pkgsFor = lib.genAttrs (import systems) (system:
          import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          }
      );
      forEachLinuxSystem = f: lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: f pkgsFor.${system});
      packageSet = lib.recursiveUpdate
        (forEachLinuxSystem (pkgs: import "${self}/pkgs/obsidian" { inherit self nixlib pkgs; }))
        (forEachLinuxSystem (pkgs: import "${self}/pkgs/general" { inherit self nixlib pkgs; }));
    in
    {
      packages = packageSet;
    };
}
