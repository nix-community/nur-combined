# borrowed from https://github.com/Misterio77/nix-colors/blob/b01f024090d2c4fc3152cd0cf12027a7b8453ba1/lib/core/conversions.nix
{ lib, vaculib, ... }:
let
  hexToIntMap = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
  };

  intToHexList = builtins.attrNames hexToIntMap;

  /*
    Conversion from base 16 to base 10 with a exponent. Is of the form
    scalar * 16 ** exponent.

    Type: base16To10 :: int -> int -> int

    Args:
      exponent: The exponent for the base, 16.
      scalar: The value to multiple to the exponentiated base.

    Example:
      base16To10 0 11
      => 11
      base16To10 1 3
      => 48
      base16To10 2 7
      1792
      base16To10 3 14
      57344
  */
  base16To10 = exponent: scalar: scalar * vaculib.pow 16 exponent;

  /*
    Converts a hexadecimal character to decimal.
    Only takes a string of length 1.

    Type: hexCharToDec :: string -> int

    Args:
      hex: A hexadecimal character.

    Example:
      hexCharToInt "5"
      => 5
      hexCharToInt "e"
      => 14
      hexCharToInt "A"
      => 10
  */
  hexCharToInt =
    hex:
    let
      lowerHex = lib.toLower hex;
    in
    if builtins.stringLength hex != 1 then
      throw "Function only accepts a single character."
    else if hexToIntMap ? ${lowerHex} then
      hexToIntMap."${lowerHex}"
    else
      throw "Character ${hex} is not a hexadecimal value.";
in
rec {
  /*
    Converts from hexadecimal to decimal.

    Type: hexToInt :: string -> int

    Args:
      hex: A hexadecimal string.

    Example:
      hexToInt "12"
      => 18
      hexToInt "FF"
      => 255
      hexToInt "abcdef"
      => 11259375
  */
  hexToInt =
    hex:
    let
      decimals = builtins.map hexCharToInt (lib.stringToCharacters hex);
      decimalsAscending = lib.reverseList decimals;
      decimalsPowered = lib.imap0 base16To10 decimalsAscending;
    in
    lib.foldl builtins.add 0 decimalsPowered;

  _tests.hexToInt = [
    (
      assert (hexToInt "12") == 18;
      true
    )
    (
      assert (hexToInt "FF") == 255;
      true
    )
    (
      assert (hexToInt "abcdef") == 11259375;
      true
    )
    (
      assert (hexToInt "0000f") == 15;
      true
    )
  ];

  /**
    Converts an integer to a hexadecimal string

    # Type

    ```
    intToHex :: Int -> String
    ```

    # Examples
    :::{.example}
    ## `vaculib.intToHex` usage example

    ```nix
    intToHex 0
    => "0"
    intToHex 15
    => "f"
    intToHex 16
    => "10"
    ```

    :::
  */
  intToHex =
    i:
    assert builtins.isInt i;
    let
      a = vaculib.divrem i 16;
      prefix = if a.quotient == 0 then "" else intToHex a.quotient;
      digit = builtins.elemAt intToHexList a.remainder;
    in
    prefix + digit;

  _tests.intToHex = [
    (
      assert (intToHex 0) == "0";
      true
    )
    (
      assert (intToHex 15) == "f";
      true
    )
    (
      assert (intToHex 16) == "10";
      true
    )
  ];
}
