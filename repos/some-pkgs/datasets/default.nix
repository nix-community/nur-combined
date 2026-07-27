{ lib, pkgs }:

lib.evalModules {
  modules = [
    { _module.args = { inherit pkgs; }; }
    ./modules/models.nix
    ./modules/datasets.nix
    {
      config.models.co-tracker = import ../python-packages/by-name/co/co-tracker/data_config.nix;
      config.models.flownet2 = { inherit (pkgs.some-pkgs.some-pkgs-py.flownet2) weights; };
    }
  ] ++ map (x: "${./configs}/${x}") (builtins.attrNames (builtins.readDir ./configs));
}
