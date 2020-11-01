/*
  Produces an attrset representing the tree of modules in this folder
  and in subfolders.

  So the path `modules/home-manager/deadd-notification-center.nix` would become
  {
    home-manager = {
      deadd-notification-center = ./home-manager/deadd-notification-center;
    };
  }
*/
with builtins;

let
  removeExtension = replaceStrings [ ".nix" ] [ "" ];

  mapAttrs' = fn: attrs:
    foldl' (acc: x:
      let attr = fn x (getAttr x attrs); in
      acc // { "${attr.name}" = attr.value; }
    ) { } (attrNames attrs);

  filterAttrs = fn: attrs:
    foldl' (acc: x:
      if fn x (getAttr x attrs) then
        (acc // { "${x}" = getAttr x attrs; })
      else
        acc
    ) { } (attrNames attrs);

  isNixFile = n: match ".+?\.nix$" n != null;

  notDefault = n: v: !(v == "regular" && n == "default.nix");

  filterFiles = filterAttrs (n: v: v == "directory" || (isNixFile n && notDefault n v));

  files = directory:
    mapAttrs' (n: v:
      if v == "directory" then {
        name = n;
        value = files (directory + "/${n}");
      }
      else {
        name = removeExtension n;
        value = directory + "/${n}";
      }
    ) (filterFiles (readDir directory));
in
files ./.
