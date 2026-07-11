{
  inputs,
  ...
}:

{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system};
    };
}
