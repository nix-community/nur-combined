# A reimplementation of stuff in nixpkgs/nixos/lib/testing/driver.nix
{
  name,
  lib,
  self,
  nixpkgs,
  ...
}:
let
  config = self.checks.x86_64-linux.${name}.config;

  vlans = map (
    m: (m.virtualisation.vlans ++ (lib.mapAttrsToList (_: v: v.vlan) m.virtualisation.interfaces))
  ) (lib.attrValues config.nodes);

  nodeHostNames =
    let
      nodesList = map (c: c.system.name) (lib.attrValues config.nodes);
    in
    nodesList ++ lib.optional (lib.length nodesList == 1 && !lib.elem "machine" nodesList) "machine";

  pythonizeName =
    name:
    let
      head = lib.substring 0 1 name;
      tail = lib.substring 1 (-1) name;
    in
    (if builtins.match "[A-z_]" head == null then "_" else head)
    + lib.stringAsChars (c: if builtins.match "[A-z0-9_]" c == null then "_" else c) tail;

  uniqueVlans = lib.unique (builtins.concatLists vlans);
  vlanNames = map (i: "vlan${toString i}: VLan;") uniqueVlans;
  pythonizedNames = map pythonizeName nodeHostNames;
  machineNames = map (name: "${name}: Machine;") pythonizedNames;
in
''
  ${builtins.readFile "${nixpkgs}/nixos/lib/test-script-prepend.py"}
  ${lib.concatLines machineNames}
  ${lib.concatLines vlanNames}
''
