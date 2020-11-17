self: super: let
  callLibs = file: import file { inherit self super; };
in with self; {
  scope = callLibs ./scope.nix;
  inherit (scope) nixPathImport nixPathScopedImport nixPathList;

  # is a string a path?
  # (note: true for paths and strings that look like paths)
  isPath = types.path.check;

  isFloat = super.isFloat or builtins.isFloat or (f:
    (builtins.tryEval (builtins.match "[0-9]*\\.[0-9]+" (toString f) != null)).value
  );

  # Coerce into a Path type if appropriate, otherwise copy contents to store first
  # (this really should just be a module data type, like either path lines)
  asPath = name: contentsOrPath:
    # undocumented behaviour (https://github.com/NixOS/nix/issues/200)
    if isDerivation contentsOrPath || (isStorePath contentsOrPath && !builtins.pathExists contentsOrPath) then contentsOrPath
    else if isStorePath contentsOrPath then builtins.storePath contentsOrPath # nix will re-copy a store path without this, and that's silly
    else if isPath contentsOrPath then /. + contentsOrPath
    else builtins.toFile name contentsOrPath;

  # Return path-like strings as-is, otherwise copy contents to store first
  # (asPath except no requirement on being a path type or found in the store)
  asFile = name: contentsOrPath:
    if isPath contentsOrPath then contentsOrPath
    else builtins.toFile name contentsOrPath;

  # named // operator
  update = a: b: a // b;

  unlessNull = item: alt:
    if item == null then alt else item;
  coalesce = foldl unlessNull null;

  # alias in lib, syntax is removeAttrs attrs [ "blacklist" ]
  removeAttrs = builtins.removeAttrs;

  # the inverse of removeAttrs
  retainAttrs = attrs: whitelist: let
    attrlist = genAttrs whitelist (_: null);
  in filterAttrs (k: _: attrlist ? ${k}) attrs;

  bitShl = sh: v:
    assert isInt sh; assert isInt v;
    if sh == 0 then v
    else bitShl (sh - 1) (v * 2);

  bitShr = sh: v:
    assert isInt sh; assert isInt v;
    if sh == 0 then v
    else bitShr (sh - 1) (v / 2);

  # https://stackoverflow.com/a/42936293
  # example: (parseTime builtins.currentTime).y
  parseTime = s: let
    z = s / 86400 + 719468;
    era = (if z >= 0 then z else z - 146096) / 146097;
    doe = z - era * 146097;
    yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    y = yoe + era * 400;
    doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    mp = (5 * doy + 2) / 153;
    d = doy - (153 * mp + 2) / 5 + 1;
    m = mp + (if mp < 10 then 3 else -9);
  in {
    inherit doy d m;
    y = y + (if m <= 2 then 1 else 0);
  };

  # hexadecimal
  hexChars = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f" ];
  hexCharToInt = char: let
    pairs = imap0 (flip nameValuePair) hexChars;
    idx = listToAttrs pairs;
  in idx.${toLower char};
  hexToInt = str:
    foldr (chr: value: value * 16 + hexCharToInt chr) 0 (stringToCharacters str);
  toHex = toHexLower;
  toHexLower = int: let
    rest = int / 16;
  in optionalString (int > 16) (toHexLower (int / 16)) + elemAt hexChars (mod int 16);
  toHexUpper = int: toUpper (toHexLower int);

  concatImap0Strings = f: list: concatStrings (imap0 f list);
  concatImap1Strings = concatImapStrings;

  # attrset to list of { name, value } pairs
  attrNameValues = mapAttrsToList nameValuePair;

  mapListToAttrs = f: l: listToAttrs (map f l);

  # merge list of attrsets left to right
  foldAttrList = foldl update {};

  # recursive attrset merge
  foldAttrListRecursive = foldl recursiveUpdate {};

  # turns { a.z = 1; b.z = 2; } into { z = { a = 1; b = 2; }; }
  # only goes one level deep, and strips out all non-attrset values
  invertAttrs = attrs: foldAttrListRecursive (mapAttrsToList (k: v:
    if isAttrs v then mapAttrs (_: v: { ${k} = v; }) v
    else { }
  ) attrs);

  moduleValue = config: builtins.removeAttrs config ["_module"]; # wh-what was this for..?

  # .extend for extensible attrsets that may not exist yet
  makeOrExtend = attrs: attr: overlay: let
    overlay' = if isAttrs overlay then (_: _: overlay) else overlay;
  in if attrs ? ${attr}.extend then attrs.${attr}.extend overlay'
    else makeExtensible (flip overlay' attrs.${attr} or { });

  # NOTE: a very basic/incomplete parser
  fromYAML = import ./from-yaml.nix self;
  importYAML = path: fromYAML (builtins.readFile path);

  inherit (import ./toml.nix self) toTOML;

  # copy function signature
  copyFunctionArgs = src: dst: setFunctionArgs dst (functionArgs src);

  # non-overridable callPackageWith
  callWith = autoArgs: fn: args: let
    f = if isFunction fn then fn else import fn;
  in f (callWithArgs autoArgs f args);

  # intersection of autoArgs and args for fn
  callWithArgs = autoArgs: fn: args: let
    f = if isFunction fn then fn else import fn;
    auto = builtins.intersectAttrs (functionArgs f) autoArgs;
  in auto // args;

  /* I don't really know what I want out of this okay damn
  # callPackgeWith for functions that return functions
  callFunctionWith = autoArgs: fn: args: let
    f = if isFunction fn then fn else import fn;
    auto = autoArgs // args;
    fargs = callWithArgs auto f { };
    f' = makeOverridable f fargs;
    f'' = args: callFunctionWith args f' { };
  in if isFunction f'
    then makeOverridable f'' auto;
    else f';

  #callFunctionWith for attrsets
  callFunctionsWith = autoArgs: fn: args: let
    res = callPackageWith autoArgs fn args;
  in if isFunction fn || (!isAttrs fn && isPath fn) then
    (if isFunction res
      then callFunctionWith autoArgs res args
      else res)
    else if isAttrs fn then
      mapAttrs (_: p: callFunctionWith autoArgs p args) fn
    else builtins.trace fn (throw "expected package function");*/

  isRust2018 = rustPlatform: rustVersionAtLeast rustPlatform "1.31";
  rustVersionAtLeast = rustPlatform: versionAtLeast rustPlatform.rust.rustc.version;

  # derivations that can reference their own (potentially overridden) attributes
  drvRec = fn: let
    drv = fn drv;
    passthru = {
      override = f: drvRec (drv: (fn drv).override f);
      overrideDerivation = f: drvRec (drv: (fn drv).overrideDerivation f);
      overrideAttrs = f: drvRec (drv: (fn drv).overrideAttrs f);
    };
  in extendDerivation true passthru drv;

  # add persistent passthru attributes that can refer to the derivation
  drvPassthru = fn: drv: if isFunction drv # allow chaining with mkDerivation
    then attrs: drvPassthru fn (drv attrs)
    else drvRec (dself: drv.overrideAttrs (old: { passthru = old.passthru or {} // fn dself; }));

  # add a .exec attribute to a derivation with the absolute path of its main binary
  drvExec = relPath: drvPassthru (drv: {
    exec =
      if relPath == "" then "${drv}"
      else "${drv}/${relPath}${drv.stdenv.hostPlatform.extensions.executable}";
  });

  # getEnv or default fallback
  getEnvOr = env: fallback: let
    val = builtins.getEnv env;
  in if val != "" then val else fallback;

  # map environment variable, or fallback (already mapped)
  mapEnv = fn: fallback: env: let
    val = builtins.getEnv env;
  in if val != "" then fn val else fallback;

  # create a url and omit explicit ports if default
  genUrl = protocol: domain: port: let
    portDefaults = {
      http = 80;
      https = 443;
    };
    portStr = if port == null || (portDefaults.${protocol} or 0) == port
      then ""
      else ":${toString port}";
  in "${protocol}://${domain}${portStr}";

  # Retrieve a channel from NIX_PATH (or via overlaid attr), falling back to a pinned url if it can't be found.
  channelOrPin = { name, imp, url, sha256, check ? (_: null) }: let
    hasPath = builtins.filter ({ prefix, ... }: prefix == name) builtins.nixPath != [];
    channel =
      if hasPath
      then builtins.findFile builtins.nixPath name
      else builtins.fetchTarball {
        name = "source";
        inherit url sha256;
      };
  in pkgs: if check pkgs != null
    then check pkgs
    else imp channel pkgs;

  nixpkgsVersionStable = "20.09";
  nixpkgsVersionUnstable = "21.03";
  isNixpkgsStable = versionOlder version "${nixpkgsVersionUnstable}pre";
  isNixpkgsUnstable = !isNixpkgsStable;
}
