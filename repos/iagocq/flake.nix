{
  description = "Iago's flake templates, overlay and NixOS modules";

  outputs = { self, ... }@inputs:
    let
      templates = import ./templates;
      nur-no-pkgs = import ./nur.nix { pkgs = null; };
    in
    {
      templates = templates.templates;
      defaultTemplate = templates.default;
      overlay = nur-no-pkgs.overlays.merged;
      nixosModules = nur-no-pkgs.modules;
    };
}
