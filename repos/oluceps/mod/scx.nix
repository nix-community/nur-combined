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
        scheduler = "scx_pandemonium";
        # scheduler = "scx_flow";
      };

    };
}
