{
  inputs,
  localLib,
  hostname,
  ...
}:

{
  imports = [
    ./configuration.nix

    "${inputs.self}/system/profiles/base.nix"
  ]
  ++ localLib.importSystemUsers [ "root" ] hostname;
}
