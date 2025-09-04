{
  imports = (
    builtins.map (modules: ./. + "/${modules}") (
      builtins.filter (x: x != "default.nix") (builtins.attrNames (builtins.readDir ./.))
    )
  );
}
