{

  flake.modules.nixos.scx =
    {
      pkgs,
      lib,
      ...
    }:
    {

      services.scx = {
        enable = true;
        scheduler = "pandemonium";
        # scheduler = "scx_flow";
      };

    };
}
