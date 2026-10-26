{ lib }:
let
  empty = {
    services = { };
    sockets = { };
    userGroups = { };
    users = { };
    tmpfiles = [ ];
    registrations = { };
    publications = { };
    assertions = [ ];
  };
  merge = records: {
    services = lib.mkMerge (map (r: r.services) records);
    sockets = lib.mkMerge (map (r: r.sockets) records);
    userGroups = lib.mkMerge (map (r: r.userGroups) records);
    users = lib.mkMerge (map (r: r.users) records);
    tmpfiles = lib.concatMap (r: r.tmpfiles) records;
    registrations = lib.mkMerge (map (r: r.registrations) records);
    publications = lib.mkMerge (map (r: r.publications) records);
    assertions = lib.concatMap (r: r.assertions) records;
  };
in
{
  inherit empty merge;
}
