{
  withSystem,
  self,
  inputs,
  ...
}@args:
let
  inherit (builtins) readFile fromTOML attrNames;
  inherit (self.lib) genAttrs;
  hosts = (./sum.toml |> readFile |> fromTOML |> (i: i.node) |> attrNames) ++ [
    "bootstrap"
    # "livecd"
  ];
in
{
  flake.nixosConfigurations = genAttrs hosts (
    n: import ./${n} args # TODO: weird.. @ pattern not work here
  );
}
