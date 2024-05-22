{ lib }:

let

  # parse a subset of YAML

  # this assumes that the YAML ...
  #   is indented with two spaces
  #   does not contain \r characters
  #   has comments only on the start of lines

  # example input: test/test.yaml

  # a generic YAML parser would require a GLR parser-generator for nix
  # see doc/parser-generators.txt

  # nix has no native YAML support
  # https://github.com/NixOS/nix/pull/7340 - add support for YAML
  # probably that PR will be merged in a million years ...
  # im not waiting for it

  fromYAML = (input:
    #builtins.trace "fromYAML input ${builtins.toJSON input}"
    (
    let
      #blocks = lib.flatten (builtins.split "\n\n" input); # wrong
      lines1 = lib.flatten (builtins.split "\n" input);
      # remove empty lines # TODO escape and preserve empty lines
      lines2 = builtins.filter (line: line != "") lines1;
      # remove comment lines
      lines3 = builtins.filter (line: (builtins.substring 0 1 line) != "#") lines2;
      input2 = builtins.concatStringsSep "\n" lines3;
      # escape indents of sub-blocks
      input3 = builtins.replaceStrings ["\n  "] ["\r  "] input2;
      # split blocks
      blocks1 = lib.flatten (builtins.split "\n" input3);
      # unescape indents of sub-blocks
      blocks2 = map (input: builtins.replaceStrings ["\r  "] ["\n  "] input) blocks1;

      dedent = input: builtins.replaceStrings ["\n  "] ["\n"] input;

      parseList = (blocks:
        map (input: fromYAML (builtins.substring 1 9999999 input)) blocks
      );

      parseMap = (blocks:
        builtins.listToAttrs (builtins.filter (x: x != null) (map parseItem blocks))
      );

      parseInlineMap = (input:
        #builtins.trace "parseInlineMap input ${builtins.toJSON input}"
        parseMap (lib.flatten (builtins.split ", " input))
      );

      parseItem = input: (
        #builtins.trace "parseItem input ${builtins.toJSON input}"
        (
        let
          name1 = builtins.head (builtins.split ":" input); # wasteful...
          name2 = parseString name1;
          value1 = builtins.substring ((builtins.stringLength name1) + 1) 999999 input;
        in
        { name = name2; value = fromYAML (dedent value1); }
        )
      );

      toFloat = (s:
        if builtins.match "[[:space:]]*(-?([[:digit:]]+\.[[:digit:]]*|[[:digit:]]*\.[[:digit:]]+)([eE][[:digit:]]+)?)[[:space:]]*" s == null
        then throw "toFloat: not a number: ${builtins.toJSON s}" else
        builtins.fromJSON s
      );

      # TODO why is tryEval not working here
      # nix-repl> let toFloat = s: let r = builtins.tryEval (builtins.fromJSON s); in if (r.success == false || (builtins.typeOf r.value != "float" && builtins.typeOf r.value != "int")) then throw "not a number: ${builtins.toJSON s}" else r.value; in toFloat "1.23x"

      parseValue = (input:
        #builtins.trace "parseValue input ${builtins.toJSON input}"
        (
        #if input == "true" then true else
        #if input == "false" then false else
        let
          spaceMatches = builtins.match "[[:space:]]*" input;
          trueMatches = builtins.match "[[:space:]]*true[[:space:]]*" input;
          falseMatches = builtins.match "[[:space:]]*false[[:space:]]*" input;
          intMatches = builtins.match "[[:space:]]*(-?[[:digit:]]+)[[:space:]]*" input;
          floatMatches = builtins.match "[[:space:]]*(-?([[:digit:]]+\\.[[:digit:]]*|[[:digit:]]*\\.[[:digit:]]+|[[:digit:]]+)([eE][[:digit:]]+)?)[[:space:]]*" input;
        in
        if spaceMatches != null then null else
        if trueMatches != null then true else
        if falseMatches != null then false else
        if intMatches != null then builtins.fromJSON input else
        if floatMatches != null then builtins.fromJSON input else
        parseString input
        )
      );

      # TODO decode backslash escapes \" \' \n \\ ...
      parseString = (input:
        let
          matches1 = builtins.match "[[:space:]]*'(.*)'[[:space:]]*" input;
          matches2 = builtins.match "[[:space:]]*\"(.*)\"[[:space:]]*" input;
          matches3 = builtins.match "[[:space:]]*(.*[^[:space:]])[[:space:]]*" input;
        in
        if matches1 != null then builtins.head matches1 else
        if matches2 != null then builtins.head matches2 else
        if matches3 != null then builtins.head matches3 else
        input
      );

      firstLine = builtins.head lines3;

      inlineMapMatches = builtins.match "[[:space:]]*[{](.*)[}][[:space:]]*" firstLine;

    in
    (
      if (builtins.substring 0 1 input2) == "-" then parseList blocks2 else
      if (inlineMapMatches != null) then parseInlineMap (builtins.head inlineMapMatches) else
      if (
        builtins.match ".*:" firstLine != null ||
        builtins.length (builtins.split ": " firstLine) > 1
      ) then parseMap blocks2 else
      parseValue input
    )
    )
  );

in

fromYAML
