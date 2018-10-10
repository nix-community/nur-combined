with builtins;
action: dir:
  let
    list = readDir dir;
    names = attrNames list;
    allowedName = baseName: !(
      # From lib/sources.nix, ignore editor backup/swap files
      builtins.match "^\\.sw[a-z]$" baseName != null ||
      builtins.match "^\\..*\\.sw[a-z]$" baseName != null ||
      # Otherwise it's good
      false);
    filteredNames = builtins.filter allowedName names;
  in listToAttrs (map
    (name: {
      name = replaceStrings [".nix"] [""] name;
      value = action (dir + ("/" + name));
    })
    filteredNames)
