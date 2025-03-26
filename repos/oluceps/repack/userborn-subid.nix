{
  reIf,
  config,
  lib,
  ...
}:
let
  entries =
    kindLetter:
    lib.concatLists (
      lib.mapAttrsToList (
        _: userCfg:
        lib.lists.map (
          rangeCfg: "${userCfg.name}:${toString rangeCfg."start${kindLetter}id"}:${toString rangeCfg.count}"
        ) userCfg."sub${kindLetter}idRanges"
      ) config.users.users
    );
  mkIdRangeFile = kindLetter: lib.concatStringsSep "\n" (entries kindLetter) + "\n";
  commonSettings = {
    mode = "0644"; # newuidmap open files using O_NOFOLLOW
  };
in
reIf {
  environment.etc."subuid" = commonSettings // {
    text = mkIdRangeFile "U";
  };
  environment.etc."subgid" = commonSettings // {
    text = mkIdRangeFile "G";
  };
}
