{ lib, vaculib, ... }:
let
  inherit (builtins) stringLength substring;
  noEval = throw "this should not be evaluated";
in
rec {
  # aka startsWith but hopefully clear from the name what order the arguments go
  isPrefixOf =
    prefix: s:
    let
      prefixl = stringLength prefix;
      sl = stringLength s;
    in
    (sl >= prefixl) && (substring 0 prefixl s) == prefix;

  isSuffixOf =
    suffix: s:
    let
      suffixl = stringLength suffix;
      sl = stringLength s;
      suffixStartIdx = sl - suffixl - 1;
      testSuffix = substring suffixStartIdx (-1) s;
    in
    (sl >= suffixl) && testSuffix == suffix;

  # Guess if x is the right type for `"${x}"` (stringify)
  # Note that in the case of attrsets with `__toString` or `outPath`, they are not deeply evaluated, so it's possible for this to return true for a value that will give a type error
  # ```
  # nix-repl> bad_attrset = { __toString = _: {}; }
  # nix-repl> isStringish bad_attrset
  # true
  # nix-repl> "${bad_attrset}"
  # error: cannot coerce a set to a string: { }
  # ```
  isStringish =
    x:
    builtins.isString x || builtins.isPath x || (builtins.isAttrs x && (x ? __toString || x ? outPath));

  _tests.isStringish = [
    (true == isStringish "a")
    (true == isStringish /a)
    (true == isStringish { outPath = noEval; })
    (true == isStringish { __toString = noEval; })
    (false == isStringish { })
    (false == isStringish 5)
    (false == isStringish true)
    (false == isStringish false)
    (false == isStringish null)
  ];

  isStringishDeep =
    x:
    builtins.any (v: v) [
      (builtins.isString x)
      (builtins.isPath x)
      (
        builtins.isAttrs x
        && (
          if x ? __toString then
            vaculib.isCallable x.__toString && isStringishDeep (x.__toString x)
          else if x ? outPath then
            isStringishDeep x.outPath
          else
            false
        )
      )
    ];

  _tests.isStringishDeep = [
    # the easy cases
    (true == isStringishDeep "a")
    (true == isStringishDeep /a)
    (true == isStringishDeep { outPath = "a"; })
    (true == isStringishDeep { __toString = _: "a"; })
    (false == isStringishDeep { })
    (false == isStringishDeep 5)
    (false == isStringishDeep true)
    (false == isStringishDeep false)
    (false == isStringishDeep null)

    # the harder ones...

    # they can be nested
    (
      true == isStringishDeep {
        outPath = {
          __toString = _: "a";
        };
      }
    )
    # __toString is preferred over outPath
    (
      true == isStringishDeep {
        outPath = noEval;
        __toString = _: "a";
      }
    )
    # return false, rather than err, if __toString is not callable
    (false == isStringishDeep { __toString = false; })
  ];

  # Just does `"${x}"`
  # for when `toString` doesn't work because you *don't* want integers, lists, bools, or null to be valid input
  stringify = x: "${x}";

  # same as builtins.tryEval. returns either:
  # - `{ success = true;  value = "<the converted string>"; }
  # - `{ success = false; value = false; }
  tryStringify =
    x:
    let
      s = "${x}";
    in
    builtins.tryEval (builtins.deepSeq s s);

  versionCompare =
    l: operator: r:
    let
      res = builtins.compareVersions l r;
      byOperator = {
        "<" = res == -1;
        "<=" = (res == -1) || (res == 0);
        "=" = res == 0;
        "==" = res == 0;
        ">=" = (res == 1) || (res == 0);
        ">" = res == 1;
      };
    in
    byOperator.${operator} or (throw "invalid operator '${operator}' for versionCompare");

  justify =
    {
      totalLength,
      dir, # exactly "l" or "r"
      char ? " ",
      errorOnLonger ? false,
    }:
    s:
    let
      remaining = totalLength - (stringLength s);
      filler =
        if remaining <= 0 then "" else builtins.concatStringsSep "" (builtins.genList (_: char) remaining);
    in
    assert builtins.isInt totalLength;
    assert dir == "l" || dir == "r";
    assert builtins.isString char;
    assert (stringLength char) == 1;
    assert builtins.isBool errorOnLonger;
    assert !errorOnLonger || remaining >= 0;
    if dir == "l" then
      s + filler
    else if dir == "r" then
      filler + s
    else
      throw "invalid dir, must be `l` or `r`";

  lJustify =
    {
      totalLength,
      char ? " ",
      errorOnLonger ? false,
    }:
    justify {
      dir = "l";
      inherit totalLength char errorOnLonger;
    };

  rJustify =
    {
      totalLength,
      char ? " ",
      errorOnLonger ? false,
    }:
    justify {
      dir = "r";
      inherit totalLength char errorOnLonger;
    };

  numToComparableString =
    n:
    # can't make negative ints sortable
    assert (builtins.isInt n) -> n >= 0;
    assert (builtins.isString n) -> (builtins.match "[0-9]{1,19}" n) != null;
    rJustify {
      # https://github.com/NixOS/nix/issues/7696
      # nix integers are int64_t, so they have a max of (2^63)-1, which is 19 digits in base 10
      totalLength = 19;
      char = "0";
      errorOnLonger = false; # handled by the match
    } (toString n);

  _tests.justify = {
    exceedsLength = lJustify { totalLength = 1; } "abc" == "abc";
    simpleL = lJustify { totalLength = 3; } "a" == "a  ";
    simpleR = rJustify { totalLength = 3; } "a" == "  a";
    sortEquivalent =
      let
        ints = [
          0
          1
          2
          10
          11
          20
          99
        ];
      in
      (lib.sort ints) == (lib.sortBy numToComparableString ints);
    foo = false;
  };
}
