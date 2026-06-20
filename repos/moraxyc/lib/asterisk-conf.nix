lib:

let
  inherit (lib)
    concatStringsSep
    optional
    optionalString
    mapAttrsToList
    elem
    ;

  die = msg: throw "asterisk-conf generator: ${msg}";

  noNL =
    what: x:
    let
      s = toString x;
    in
    if lib.hasInfix "\n" s || lib.hasInfix "\r" s then
      die "${what} must not contain newline: ${s}"
    else
      s;

  renderValue =
    v:
    if v == null then
      null
    else if builtins.isBool v then
      (if v then "yes" else "no")
    else if builtins.isList v then
      concatStringsSep "," (map renderValue v)
    else
      noNL "value" v;

  renderEntry =
    entry:
    if entry == null then
      [ ]
    else if builtins.isString entry then
      [ entry ]
    else
      let
        type = entry.type or "kv";
      in
      if type == "kv" then
        let
          sep = entry.sep or "=";
          key = noNL "key" entry.key;
          value = if entry ? value then renderValue entry.value else die "kv entry missing `value`";
          indent = entry.indent or "";
        in
        if value == null then
          [ ]
        else if
          !(elem sep [
            "="
            "=>"
          ])
        then
          die "unsupported separator: ${sep}"
        else
          [ "${indent}${key} ${sep} ${value}" ]

      else if type == "raw" then
        [ entry.text ]

      else if type == "comment" then
        [ "; ${noNL "comment" entry.text}" ]

      else if type == "blank" then
        [ "" ]

      else if type == "include" then
        [ "#include ${noNL "include path" entry.value}" ]

      else if type == "tryinclude" then
        [ "#tryinclude ${noNL "tryinclude path" entry.value}" ]

      else if type == "exec" then
        [ "#exec ${noNL "exec command" entry.value}" ]

      else
        die "unknown entry type: ${type}";

  renderEntries = entries: lib.concatMap renderEntry entries;

  headerOptions =
    section:
    if section ? options then
      section.options
    else
      optional (section.template or false) "!"
      ++ (section.inherits or [ ])
      ++ optional (section.append or false) "+";

  renderSection =
    section:
    let
      name = noNL "section name" section.name;
      opts = headerOptions section;
      renderedOpts = optionalString (
        opts != [ ]
      ) "(${concatStringsSep "," (map (noNL "section option") opts)})";
      entries = renderEntries (section.entries or [ ]);
    in
    concatStringsSep "\n" ([ "[${name}]${renderedOpts}" ] ++ entries);

  render =
    cfg:
    let
      top = renderEntries (cfg.body or [ ]);
      sections = map renderSection (cfg.sections or [ ]);
      blocks = optional (top != [ ]) (concatStringsSep "\n" top) ++ sections;
    in
    concatStringsSep "\n\n" blocks + "\n";

in
{
  inherit render;

  kv = key: value: {
    type = "kv";
    sep = "=";
    inherit key value;
  };

  arrow = key: value: {
    type = "kv";
    sep = "=>";
    inherit key value;
  };

  raw = text: {
    type = "raw";
    inherit text;
  };

  comment = text: {
    type = "comment";
    inherit text;
  };

  blank = {
    type = "blank";
  };

  include = file: {
    type = "include";
    value = file;
  };

  tryinclude = file: {
    type = "tryinclude";
    value = file;
  };

  exec = command: {
    type = "exec";
    value = command;
  };

  section = name: entries: {
    inherit name entries;
  };

  template = name: entries: {
    inherit name entries;
    template = true;
  };

  use = name: inherits: entries: {
    inherit name inherits entries;
  };

  append = name: entries: {
    inherit name entries;
    append = true;
  };

  attrs =
    attrs:
    mapAttrsToList (key: value: {
      type = "kv";
      sep = "=";
      inherit key value;
    }) attrs;
}
