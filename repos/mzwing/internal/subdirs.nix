# Map each immediate subdirectory to its path; used by the module index files.
dir: let
  entries = builtins.readDir dir;
in
  builtins.listToAttrs (map (name: {
    inherit name;
    value = dir + "/${name}";
  }) (builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries)))
