{ inputs, ... }:

{
  perSystem =
    {
      config,
      self',
      inputs',
      pkgs,
      system,
      lib,
      ...
    }:
    {
      formatter = pkgs.nixfmt-rfc-style;
    };
}
