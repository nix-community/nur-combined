{ lib }:

let
  inherit (builtins) tryEval;
  inherit (lib)
    filter
    elemAt
    assertMsg
    nameValuePair
    listToAttrs
    ;
  inherit (lib.strings) splitString hasPrefix match;
  inherit (lib.lists) map;
in
/*
  Parse Linux Kernel Config text to an attribute set.

   Example:
     parseLinuxConfig {
      configText = ''
        # Kernel config
        #

        CONFIG_A=y
        CONFIG_B=m
        CONFIG_C="text"
        CONFIG_D is not set
      '';
      relaxed = true;
     }
     => {
       CONFIG_A = "y";
       CONFIG_B = "m";
       CONFIG_C = "text";
     }
*/
{
  configText,
  # skip ill-formed lines
  relaxed ? false,
}:

let
  rawLines = splitString "\n" configText;
  nonEmptyLines = filter (line: line != "") rawLines;
  configLines = filter (line: !(hasPrefix "#" line)) nonEmptyLines;
  parseConfigLine =
    line:
    let
      parsed = parseConfigLineUnquoted line;
    in
    parsed // { value = removeQuote parsed.value; };
  parseConfigLineUnquoted =
    line:
    let
      parsed = match "(CONFIG_[^=]+)=(.*)$" line;
    in
    assert assertMsg (parsed != null) "failed to parse kernel config line '${line}'";
    nameValuePair (elemAt parsed 0) (elemAt parsed 1);
  removeQuote =
    value:
    let
      quoteMatch = match ''"(.*)"'' value;
    in
    if quoteMatch == null then value else elemAt quoteMatch 0;
  tryParseConfigLine = line: tryEval (parseConfigLine line);
in
if relaxed then
  listToAttrs (
    map (result: result.value) (filter (result: result.success) (map tryParseConfigLine configLines))
  )
else
  listToAttrs (map parseConfigLine configLines)
