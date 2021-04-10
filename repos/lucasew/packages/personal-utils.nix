{pkgs ? import <nixpkgs> {}, ...}:
pkgs.symlinkJoin {
  name = "personal-utils";
  paths = [
    (pkgs.writeShellScriptBin "todo" ''
      ${pkgs.todoist}/bin/todoist add -p 2 -d today "$*"
    '')
    (pkgs.writeShellScriptBin "today" ''
      ${pkgs.todoist}/bin/todoist --color list --filter 'today & p1'
      ${pkgs.todoist}/bin/todoist --color list --filter 'today & p2'
      ${pkgs.todoist}/bin/todoist --color list --filter 'today & p3'
      # ${pkgs.todoist}/bin/todoist --color list --filter p2
    '')
  ];
}
