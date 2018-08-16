with builtins;
action: dir:
  let
    list = readDir dir;
  in listToAttrs (map
    (name: {
      name = replaceStrings [".nix"] [""] name;
      value = action (dir + ("/" + name));
    })
    (attrNames list))

