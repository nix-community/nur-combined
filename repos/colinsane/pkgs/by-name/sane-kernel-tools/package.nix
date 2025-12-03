{
  lib,
  newScope,
}:
lib.makeScope newScope (self: with self; {
  # maps `CONFIG_FOO=y` to `[ { CONFIG_FOO = "y"; }]`
  # maps `# CONFIG_FOO is not set` to `[]`
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
  # this is not meant for `structuredExtraConfig`, but stuff further downstream.
  # results are like ` { CONFIG_FOO = "y"; CONFIG_FOO_BAR = "128"; }`
  parseDefconfig = wholeStr: let
    lines = lib.splitString "\n" wholeStr;
    parsedItems = lib.concatMap parseDefconfigLine lines;
  in
    lib.listToAttrs parsedItems;

  parseDefconfigStructured = wholeStr: let
    asKV = parseDefconfig wholeStr;
  in lib.mapAttrs' (k: v: {
    name = lib.removePrefix "CONFIG_" k;
    value = with lib.kernel;
      if v == "y" then yes
      else if v == "n" then no
      else if v == "m" then module
      else if lib.hasPrefix ''"'' v && lib.hasSuffix ''"'' v then freeform (builtins.fromJSON v)
      else freeform v
    ;
  }) asKV;

  # configs like `CONFIG_LOCALVERSION=""`, transformed into `LOCALVERSION = freeform ""`,
  # can confuse the kernel build process. remove those empty strings.
  parseDefconfigStructuredNonempty = wholeStr: let
    asAttrs = parseDefconfigStructured wholeStr;
  in lib.filterAttrs (k: v: v != lib.kernel.freeform "") asAttrs;
})
