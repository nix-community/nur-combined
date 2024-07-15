{ lib
, newScope
}:
lib.makeScope newScope (self: with self; {
  parseDefconfigLine = line: let
    pieces = lib.splitString "=" line;
  in
    if lib.hasPrefix "#" (lib.head pieces) then [
      # this line is a comment.
      # N.B.: this could be like `# CONFIG_FOO is not set`, which i might want to report as `n`
    ] else if lib.length pieces == 1 then [
      # no equals sign: this is probably a blank line
    ] else [{
      name = lib.head pieces;
      # nixpkgs kernel config is some real fucking bullshit: it wants a plain string here instead of the structured config it demands eeeeeeverywhere else.
      value = lib.concatStringsSep "=" (lib.tail pieces);
    }]
  ;
  # parseDefconfig: given the entire text of a defconfig file
  # parse it into an attrset usable by the nixpkgs kernel config tools.
  parseDefconfig = wholeStr: let
    lines = lib.splitString "\n" wholeStr;
    parsedItems = lib.concatMap parseDefconfigLine lines;
  in
    lib.listToAttrs parsedItems;
})
