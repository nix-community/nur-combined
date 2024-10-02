{ ... }:

{
  imports = []
  ++
    map (n: "${./programs}/${n}") (builtins.attrNames (builtins.readDir ./programs))
  ++
    map (n: "${./services}/${n}") (builtins.attrNames (builtins.readDir ./services));
}
