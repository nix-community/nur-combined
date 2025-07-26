{
  withSystem,
  self,
  inputs,
  ...
}@args:
let
  inherit (self.lib) genAttrs;
  hosts = (self.lib.data.node |> builtins.attrNames) ++ [
    # "bootstrap"
    # "livecd"
  ];
in
{
  flake.nixosConfigurations = genAttrs hosts (
    n: import ./${n} args # TODO: weird.. @ pattern not work here
  );
}
