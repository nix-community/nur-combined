let {
  body = lib;

  lib = nixpkgs.lib // builtins // (with lib; {
    genAttrs' = names: f: listToAttrs (map f names);
    getAttrs = names: set:
      listToAttrs (map (name: nameValuePair name set.${name})
                       (filter (flip hasAttr set) names));
    toC = x: let
      type = typeOf x;
      reject = throw "cannot convert ${type}";
    in {
      list = "{ ${concatStringsSep ", " (map toC x)} }";
      null = "NULL";
      set = if isDerivation x then toJSON x else reject;
      string = toJSON x; # close enough
    }.${type} or reject;
    test = re: x: isString x && testString re x;
    testString = re: x: match re x != null;
    types = nixpkgs.lib.types // import ./types.nix { lib = body; };
  });

  nixpkgs.lib = import <nixpkgs/lib>;
}
