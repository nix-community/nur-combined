# Populate agenix keys from a central location
let
  inherit (builtins)
    mapAttrs
    readDir
    readFile
    stringLength
    substring
    ;

  removeSuffix = suffix: str:
    let
      sufLen = stringLength suffix;
      sLen = stringLength str;
    in
    if sufLen <= sLen && suffix == substring (sLen - sufLen) sufLen str then
      substring 0 (sLen - sufLen) str
    else
      str;


  readKeys = dir:
    let
      files = readDir dir;
      readNoNewlines = f: removeSuffix "\n" (readFile f);
      readKey = name: readNoNewlines (dir + "/${name}");
    in
    mapAttrs (n: _: readKey n) files;

  hosts = readKeys ./hosts;
  users = readKeys ./users;
in
{
  inherit
    hosts
    users;

  all = (builtins.attrValues hosts) ++ (builtins.attrValues users);
}
