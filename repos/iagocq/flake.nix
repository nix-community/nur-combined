{
  description = "Iago's flake templates, overlay and NixOS modules";

  outputs = { self, nixpkgs }:
    let
      templates = import ./templates;
      nur-no-pkgs = import ./nur.nix { pkgs = null; };
      nur-pkgs = system: import ./nur.nix { pkgs = nixpkgs.legacyPackages.${system}; };
      allSystems = x: builtins.foldl' (acc: system: acc // { ${system} = x system; }) { } systems;
      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      templates = templates.templates;
      defaultTemplate = templates.default;
      overlay = nur-no-pkgs.overlays.merged;
      overlays = nur-no-pkgs.overlays;
      nixosModules = nur-no-pkgs.modules;
      legacyPackages = allSystems nur-pkgs;
    };
}
