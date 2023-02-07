{ hostName ? "" }:
let machineId = builtins.hashString "md5" hostName;
in machineId
