lib:

let
  inherit (lib)
    concatStringsSep
    optional
    optionalString
    boolToYesNo
    mapAttrsToList
    elem
    concatMap
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
      boolToYesNo v
    else if builtins.isList v then
      concatStringsSep "," (builtins.filter (x: x != null) (map renderValue v))
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

  attrsToEntries =
    attrs:
    mapAttrsToList (key: value: {
      type = "kv";
      sep = "=";
      inherit key value;
    }) attrs;

  normalizeEntries =
    what: x:
    if x == null then
      [ ]
    else if builtins.isList x then
      x
    else if builtins.isAttrs x then
      attrsToEntries x
    else
      die "${what} must be a list or attrset";

  renderEntries = entries: concatMap renderEntry entries;

  reservedSectionKeys = [
    "_options"
    "_template"
    "_inherits"
    "_append"
    "_entries"
    "_pre"
    "_post"
  ];

  sectionOptions =
    section:
    if section ? _options then
      section._options
    else
      optional (section._template or false) "!"
      ++ (section._inherits or [ ])
      ++ optional (section._append or false) "+";

  sectionEntries =
    section:
    let
      directAttrs = removeAttrs section reservedSectionKeys;

      pre = normalizeEntries "_pre" (section._pre or [ ]);
      direct = attrsToEntries directAttrs;
      extra = normalizeEntries "_entries" (section._entries or [ ]);
      post = normalizeEntries "_post" (section._post or [ ]);
    in
    pre ++ direct ++ extra ++ post;

  renderNamedSection =
    name: section:
    let
      sectionName = noNL "section name" name;
      opts = sectionOptions section;
      renderedOpts = optionalString (
        opts != [ ]
      ) "(${concatStringsSep "," (map (noNL "section option") opts)})";
      entries = renderEntries (sectionEntries section);
    in
    concatStringsSep "\n" ([ "[${sectionName}]${renderedOpts}" ] ++ entries);

  renderOldSection =
    section:
    let
      opts =
        if section ? options then
          section.options
        else
          optional (section.template or false) "!"
          ++ (section.inherits or [ ])
          ++ optional (section.append or false) "+";
    in
    renderNamedSection section.name {
      _options = opts;
      _entries = section.entries or [ ];
    };

  renderSections =
    sections:
    if sections == null then
      [ ]
    else if builtins.isList sections then
      map renderOldSection sections
    else if builtins.isAttrs sections then
      mapAttrsToList renderNamedSection sections
    else
      die "`sections` must be a list or attrset";

  render =
    cfg:
    let
      top = renderEntries (normalizeEntries "body" (cfg.body or [ ]));
      sections = renderSections (cfg.sections or { });

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

  # attrset-style helpers
  template =
    entries:
    if builtins.isAttrs entries then
      entries // { _template = true; }
    else
      {
        _template = true;
        _entries = entries;
      };

  use =
    inherits: entries:
    if builtins.isAttrs entries then
      entries // { _inherits = inherits; }
    else
      {
        _inherits = inherits;
        _entries = entries;
      };

  append =
    entries:
    if builtins.isAttrs entries then
      entries // { _append = true; }
    else
      {
        _append = true;
        _entries = entries;
      };

  attrs = attrsToEntries;

  section = name: entries: {
    ${name} = if builtins.isAttrs entries then entries else { _entries = entries; };
  };
}
