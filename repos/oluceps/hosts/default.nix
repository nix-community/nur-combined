# let

#   /*
#     "hastur" # homeserver    # network censored
#     "azasos" # tencent cloud # network censored
#     "nodens" # digital ocean
#     "yidhra" # aws lightsail
#     "abhoth" # alicloud      # network censored
#     "colour" # azure
#     "eihort" # C222          # network censored
#   */
#   generalHost = with builtins; fromJSON (readFile ./host.json);
# in
{
  withSystem,
  self,
  inputs,
  ...
}:
let
  regularHosts = with builtins; (fromTOML (readFile ./sum.toml)).hosts;
in
{
  flake.nixosConfigurations = self.lib.genAttrs regularHosts (
    n: import ./${n} { inherit withSystem self inputs; } # TODO: weird.. @ pattern not work here
  );
}
