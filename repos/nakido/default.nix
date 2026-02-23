{
  pkgs ? import <nixpkgs> { },
}:

# `(import ./dependencies/flake-compat-ff81ac966bb2cae68946d5ed5fc4994f96d0ffec { src = ./.; }).outputs.legacyPackages.${pkgs.stdenv.system}`
# error: access to URI 'git+file:///path/to/this?exportIgnore=1' is forbidden in restricted mode
# `(builtins.getFlake "path:${./.}").outputs.legacyPackages.${pkgs.stdenv.system}`
# error: the string 'path:/nix/store/8r5nw74maswcsbgb9h4j7gkw61w946wi-nurpkgs' is not allowed to refer to a store path (such as '8r││5nw74maswcsbgb9h4j7gkw61w946wi-nurpkgs')

let
  mylib = import ./lib { inherit (pkgs) lib; };
in
builtins.listToAttrs (
  map (file: {
    name = mylib.getFilenameNoSuffix file;
    value = pkgs.callPackage file { };
  }) (mylib.globPackages ./pkgs)
)