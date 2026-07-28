{ ... }:
let
  inherit (builtins)
    isBool
    isInt
    all
    attrNames
    attrValues
    ;
  prependIf =
    cond: element: list:
    if cond then [ element ] ++ list else list;
  optionalString = condition: s: if condition then s else "";
  optionalInt = condition: i: if condition then i else 0;
  pipe = builtins.foldl' (x: f: f x);
  isForbidAllow = val: builtins.isString val && (val == "forbid" || val == "allow");

  singleNothingMode = {
    read = false;
    write = false;
    execute = false;
  };
  expandSingleMode =
    val:
    let
      expanded = singleNothingMode // val;
    in
    assert builtins.isString val || builtins.isAttrs val;
    assert (builtins.isString val) -> (val == "all" || val == "rw" || val == "none");
    assert
      (builtins.isAttrs val)
      ->
        [
          "execute"
          "read"
          "write"
        ] == (attrNames expanded);
    assert (builtins.isAttrs val) -> all isBool (attrValues val);
    if val == "all" then
      {
        read = true;
        write = true;
        execute = true;
      }
    else if val == "rw" then
      {
        read = true;
        write = true;
        execute = false;
      }
    else if val == "none" then
      {
        read = false;
        write = false;
        execute = false;
      }
    else
      expanded;
  singleModeToInt =
    {
      read,
      write,
      execute,
    }:
    0 + (optionalInt read 4) + (optionalInt write 2) + (optionalInt execute 1);
  singleModeToSymbolic =
    {
      read,
      write,
      execute,
    }:
    "" + (optionalString read "r") + (optionalString write "w") + (optionalString execute "x");
  accessModeToOctalString =
    {
      user,
      group,
      other,
      suid,
      sgid,
      sticky,
      _type,
      octalLength,
      ...
    }:
    assert _type == "com.shelvacu.nix.fileAccessMode";
    let
      firstDigit = 0 + (optionalInt suid 4) + (optionalInt sgid 2) + (optionalInt sticky 1);
    in
    pipe
      [ user group other ]
      [
        (map singleModeToInt)
        (prependIf (octalLength == 4) firstDigit)
        (map toString)
        (builtins.concatStringsSep "")
      ];
  accessModeToSymbolicString =
    {
      user,
      group,
      other,
      suid,
      sgid,
      sticky,
      _type,
      ...
    }:
    assert _type == "com.shelvacu.nix.fileAccessMode";
    builtins.concatStringsSep "," [
      "u=${singleModeToSymbolic user}${optionalString suid "s"}"
      "g=${singleModeToSymbolic group}${optionalString sgid "s"}"
      "o=${singleModeToSymbolic other}${optionalString sticky "t"}"
    ];
  expandSingleMaskMode =
    val:
    let
      expanded = {
        read = "forbid";
        write = "forbid";
        execute = "forbid";
      }
      // val;
    in
    assert builtins.isString val || builtins.isAttrs val;
    assert (builtins.isString val) -> isForbidAllow val;
    assert
      (builtins.isAttrs val)
      ->
        (attrNames expanded) == [
          "execute"
          "read"
          "write"
        ];
    assert (builtins.isAttrs val) -> all isForbidAllow (attrValues val);
    if builtins.isString val then
      {
        read = val;
        write = val;
        execute = val;
      }
    else
      expanded;
  singleMaskModeToInt =
    {
      read,
      write,
      execute,
    }:
    0
    + (optionalInt (read == "forbid") 4)
    + (optionalInt (write == "forbid") 2)
    + (optionalInt (execute == "forbid") 1);
  maskModeToOctalString =
    {
      user,
      group,
      other,
      _type,
      octalLength,
      ...
    }:
    assert _type == "com.shelvacu.nix.fileMaskMode";
    pipe
      [ user group other ]
      [
        (map singleMaskModeToInt)
        (prependIf (octalLength == 4) 0)
        (map toString)
        (builtins.concatStringsSep "")
      ];
in
rec {
  accessMode =
    {
      all ? { },
      user ? null,
      group ? null,
      other ? null,
      suid ? false,
      sgid ? false,
      sticky ? false,
      octalLength ? 4,
    }:
    let
      singles = { inherit user group other; };
      self = {
        _type = "com.shelvacu.nix.fileAccessMode";
        inherit
          suid
          sgid
          sticky
          octalLength
          ;
        __toString = accessModeToOctalString;
        octalString = accessModeToOctalString self;
        symbolicString = accessModeToSymbolicString self;
      }
      // (builtins.mapAttrs (_: val: expandSingleMode (if val != null then val else all)) singles);
    in
    assert isBool suid;
    assert isBool sgid;
    assert isBool sticky;
    assert isInt octalLength;
    assert octalLength == 3 || octalLength == 4;
    assert octalLength == 3 -> suid == false && sgid == false && sticky == false;
    self;
  _tests.accessMode.all =
    let
      res = accessMode { all = "all"; };
    in
    {
      octal = (
        assert res.octalString == "0777";
        true
      );
      symbolic = (
        assert res.symbolicString == "u=rwx,g=rwx,o=rwx";
        true
      );
    };
  _tests.accessMode.allWithSpecial =
    let
      res = accessMode {
        all = "all";
        suid = true;
        sgid = true;
        sticky = true;
      };
    in
    {
      octal = (
        assert res.octalString == "7777";
        true
      );
      symbolic = (
        assert res.symbolicString == "u=rwxs,g=rwxs,o=rwxt";
        true
      );
    };
  _tests.accessMode.none =
    let
      res = accessMode { all = "none"; };
    in
    {
      octal = (
        assert res.octalString == "0000";
        true
      );
      symbolic = (
        assert res.symbolicString == "u=,g=,o=";
        true
      );
    };
  _tests.accessMode.octalLength3 =
    assert
      (accessMode {
        all = "all";
        octalLength = 3;
      }).octalString == "777";
    true;
  accessModeStr = args: "${accessMode args}";

  mask =
    {
      all ? "forbid",
      user ? null,
      group ? null,
      other ? null,
      octalLength ? 4,
    }:
    let
      singles = { inherit user group other; };
      self = {
        inherit octalLength;
        _type = "com.shelvacu.nix.fileMaskMode";
        __toString = maskModeToOctalString;
        octalString = maskModeToOctalString self;
      }
      // (builtins.mapAttrs (_: val: expandSingleMaskMode (if val != null then val else all)) singles);
    in
    assert isInt octalLength;
    assert octalLength == 3 || octalLength == 4;
    self;
  maskStr = args: "${mask args}";
  _tests.maskStr.forbidAll =
    assert (maskStr { all = "forbid"; }) == "0777";
    true;
  _tests.maskStr.allowAll =
    assert (maskStr { all = "allow"; }) == "0000";
    true;
  _tests.maskStr.octalLength3 =
    assert
      (maskStr {
        all = "forbid";
        octalLength = 3;
      }) == "777";
    true;
}
