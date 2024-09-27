{
  withSystem,
  self,
  inputs,
  ...
}:
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
    n: import ./${n} { inherit withSystem self inputs; } # TODO: weird.. @ pattern not work here
  );
}
