{
  description = "Iago's flake template for miscellaneous projects";
  
  outputs = ({ self, ...}@inputs:
    let
      templates = import ./templates;
      pkgs = import ./nur.nix;
    in
    {
      templates = templates.templates;
      defaultTemplate = templates.default;
      overlay = (pkgs { pkgs = null; }).overlays.all;
      nixosModules = pkgs.modules;
    }
  );
}
