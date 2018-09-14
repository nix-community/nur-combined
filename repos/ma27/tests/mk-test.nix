# inspired by <nixpkgs/lib/tests/release.nix>
{ stdenv, lib }: tests:

with lib;

let

  testResults = flatten tests;

  renderType = level: val:
    if level == 6
      then "<CODE>"
    else if builtins.isAttrs val
      then "{ ${builtins.concatStringsSep "; " (mapAttrsToList (k: v: "${k} = ${renderType (level + 1) v}") val) } }"
    else if builtins.isFunction val
      then "<<lambda>>"
    else if builtins.isList val
      then "[${builtins.concatStringsSep " " (map (renderType (level + 1)) val)}]"
    else
      toString val;

  render = testResults: builtins.concatStringsSep "\n" (flip map testResults (testResult: ''
    echo Test ${testResult.name} failed!
    echo
    echo " Expected: ${renderType 0 testResult.expected}"
    echo " Result:   ${renderType 0 testResult.result}"
    echo
  ''));

in

stdenv.mkDerivation {
  name = "library-tests";
  src = null;

  buildCommand = ''
    ${builtins.concatStringsSep "\n" (flip map tests (result: ''
      ${if result == [] then "echo Tests passed" else "${render result}\nexit 1"}
    ''))}

    touch $out
  '';
}
