{
  withSystem,
  self,
  inputs,
  ...
}@args:
let
  inherit (builtins) readFile fromTOML;
  inherit (self.lib) pipe genAttrs;
  hosts = (
    pipe ./sum.toml [
      readFile
      fromTOML
      (i: i.host)
      (map (i: i.name))
    ]
  );
in
{
  flake.nixosConfigurations = genAttrs hosts (
    n: import ./${n} args # TODO: weird.. @ pattern not work here
  );
}
